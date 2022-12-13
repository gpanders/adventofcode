enum Command<'a> {
    Ls,
    Cd(&'a str),
}

enum Kind {
    File,
    Dir,
}

struct Entry<'a> {
    name: &'a str,
    size: Option<usize>,
    kind: Kind,
}

enum Line<'a> {
    Command(Command<'a>),
    Entry(Entry<'a>),
}

struct Node<'a> {
    entry: Entry<'a>,
    parent: Option<usize>,
    children: Vec<usize>,
}

impl<'a> Node<'a> {
    fn size(&self, nodes: &'a [Node<'a>]) -> usize {
        match self.entry.kind {
            Kind::File => self.entry.size.unwrap(),
            Kind::Dir => match self.entry.size {
                Some(size) => size,
                None => {
                    let mut size = 0;
                    for &child in &self.children {
                        size += nodes[child].size(nodes);
                    }
                    size
                }
            },
        }
    }
}

fn parse<'a>(line: &'a str) -> Line<'a> {
    if let Some(dir) = line.strip_prefix("$ cd ") {
        Line::Command(Command::Cd(dir))
    } else if line.starts_with("$ ls") {
        Line::Command(Command::Ls)
    } else if let Some(dir) = line.strip_prefix("dir ") {
        Line::Entry(Entry {
            name: dir,
            size: None,
            kind: Kind::Dir,
        })
    } else {
        let mut it = line.split(' ');
        let size = it.next().unwrap().parse().ok();
        let name = it.next().unwrap();
        Line::Entry(Entry {
            name,
            size,
            kind: Kind::File,
        })
    }
}

fn main() {
    let input = include_str!("../input.txt");
    let lines: Vec<Line> = input.split_terminator('\n').map(parse).collect();

    let root = Node {
        entry: Entry {
            name: "/",
            size: None,
            kind: Kind::Dir,
        },
        parent: None,
        children: vec![],
    };

    let mut nodes = vec![root];
    let mut cur = 0;

    for line in lines {
        match line {
            Line::Command(cmd) => match cmd {
                Command::Cd(dir) => match dir {
                    "/" => cur = 0,
                    ".." => {
                        if let Some(parent) = nodes[cur].parent {
                            cur = parent;
                        }
                    }
                    _ => {
                        let mut found = None;
                        for &child in nodes[cur].children.iter() {
                            let entry = &nodes[child].entry;
                            if let Kind::Dir = entry.kind {
                                if dir == entry.name {
                                    found = Some(child);
                                    break;
                                }
                            }
                        }

                        cur = found.unwrap();
                    }
                },
                Command::Ls => {}
            },
            Line::Entry(entry) => {
                nodes.push(Node {
                    entry,
                    parent: Some(cur),
                    children: vec![],
                });
                let i = nodes.len() - 1;
                nodes[cur].children.push(i);
            }
        }
    }

    let p1: usize = (0..nodes.len())
        .rev()
        .filter_map(|i| {
            let node = &nodes[i];
            match node.entry.kind {
                Kind::Dir => {
                    let size = node.size(&nodes);
                    let mut node = &mut nodes[i];
                    node.entry.size = Some(size);
                    if size <= 100000 {
                        Some(size)
                    } else {
                        None
                    }
                }
                _ => None,
            }
        })
        .sum();

    let total_space = 70000000;
    let needed = 30000000;
    let diff = needed - (total_space - nodes[0].entry.size.unwrap());

    let p2 = nodes
        .iter()
        .filter_map(|n| {
            if let Kind::Dir = n.entry.kind {
                if let Some(size) = n.entry.size {
                    if size > diff {
                        return Some(size);
                    }
                }
            }

            None
        })
        .min()
        .unwrap();

    println!("Part one: {}", p1);
    println!("Part two: {}", p2);
}
