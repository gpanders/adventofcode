struct Command {
    count: usize,
    from: usize,
    to: usize,
}

fn parse_input(s: &str) -> (Vec<Vec<char>>, Vec<Command>) {
    let mut it = s.split_terminator('\n').peekable();
    let mut stacks = {
        let line = it.peek().unwrap();
        let num_stacks = (line.len() + 1) / 4;
        println!("There are {} stacks", num_stacks);
        vec![vec![]; num_stacks]
    };

    while let Some(line) = it.next() {
        if line.len() == 0 {
            break;
        }

        let mut n = 0;
        let mut i = 0;
        while i < line.len() {
            let cr8 = &line[i..i + 3];
            if cr8.chars().nth(0) == Some('[') {
                stacks[n].push(cr8.chars().nth(1).unwrap());
            }
            i += 4;
            n += 1;
        }
    }

    for stack in &mut stacks {
        stack.reverse();
    }

    let commands = it
        .map(|line| {
            let mut words = line.split(' ');
            let count: usize = words.nth(1).unwrap().parse().unwrap();
            let from: usize = words.nth(1).unwrap().parse().unwrap();
            let to: usize = words.nth(1).unwrap().parse().unwrap();

            Command {
                count,
                from: from - 1,
                to: to - 1,
            }
        })
        .collect();

    (stacks, commands)
}

fn rearrange(stacks: &mut Vec<Vec<char>>, commands: Vec<Command>, reverse: bool) {
    for command in commands {
        if reverse {
            for _ in 0..command.count {
                let v = stacks[command.from].pop().unwrap();
                stacks[command.to].push(v);
            }
        } else {
            let len = stacks[command.from].len();
            let crates: Vec<char> = stacks[command.from]
                .drain((len - command.count)..)
                .collect();
            stacks[command.to].extend_from_slice(&crates);
        }
    }
}

fn main() {
    let input = include_str!("../input.txt");
    let (mut stacks, commands) = parse_input(input);

    let p1 = false;
    rearrange(&mut stacks, commands, p1);

    print!("Part {}: ", if p1 { "1" } else { "2" });
    for stack in stacks {
        print!("{}", stack.last().unwrap());
    }
    print!("\n");
}
