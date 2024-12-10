use std::collections::{BinaryHeap, HashMap};

#[derive(Eq)]
struct Node {
    pos: (usize, usize),
    cost: u32,
}

impl PartialEq for Node {
    fn eq(&self, other: &Self) -> bool {
        self.cost == other.cost
    }
}

impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.cost.cmp(&other.cost).reverse()
    }
}

fn length(map: &HashMap<(usize, usize), (usize, usize)>, dest: (usize, usize)) -> Option<usize> {
    let mut n = None;
    let mut cur = dest;
    while let Some(src) = map.get(&cur) {
        n = match n {
            None => Some(1),
            Some(n) => Some(n + 1),
        };
        cur = *src;
    }
    n
}

fn main() {
    let input = include_str!("../input.txt");

    let mut grid = vec![];
    let mut start = (0, 0);
    let mut end = (0, 0);
    for (row, line) in input.split_terminator('\n').enumerate() {
        if let Some(col) = line.chars().position(|c| c == 'S') {
            start = (col, row);
        }

        if let Some(col) = line.chars().position(|c| c == 'E') {
            end = (col, row);
        }

        grid.push(line.chars().collect::<Vec<char>>());
    }

    let mut queue = BinaryHeap::new();
    let mut came_from = HashMap::<(usize, usize), (usize, usize)>::new();
    let mut total_cost = HashMap::new();

    total_cost.insert(end, 0);

    queue.push(Node { pos: end, cost: 0 });

    while let Some(Node { pos, cost: _ }) = queue.pop() {
        let cur = match grid[pos.1][pos.0] {
            'S' => 'a',
            'E' => 'z',
            c => c,
        };

        let mut neighbors = vec![];
        if pos.0 > 0 {
            neighbors.push((pos.0 - 1, pos.1));
        }

        if pos.0 < grid[pos.1].len() - 1 {
            neighbors.push((pos.0 + 1, pos.1));
        }

        if pos.1 > 0 {
            neighbors.push((pos.0, pos.1 - 1));
        }

        if pos.1 < grid.len() - 1 {
            neighbors.push((pos.0, pos.1 + 1));
        }

        let current_cost = total_cost[&pos];
        for neighbor in neighbors.iter() {
            let char = match grid[neighbor.1][neighbor.0] {
                'S' => 'a',
                'E' => 'z',
                c => c,
            };

            let cost = if cur as i8 - char as i8 == 1 {
                0
            } else if cur <= char {
                char as u8 - cur as u8 + 1
            } else {
                continue;
            } as u32;

            let cost = current_cost + cost;
            if !total_cost.contains_key(neighbor) || cost < total_cost[neighbor] {
                total_cost.insert(*neighbor, cost);
                queue.push(Node {
                    pos: *neighbor,
                    cost,
                });
                came_from.insert(*neighbor, pos);
            }
        }
    }

    println!("Part 1: {}", length(&came_from, start).unwrap());

    let p2 = grid.iter().enumerate().filter_map(|(i, row)| {
        row.iter()
            .enumerate()
            .filter_map(|(j, ch)| {
                if *ch == 'S' || *ch == 'a' {
                    length(&came_from, (j, i))
                } else {
                    None
                }
            })
            .min()
    }).min().unwrap();

    println!("Part 2: {}", p2);
}
