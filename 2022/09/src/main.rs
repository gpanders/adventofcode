use std::collections::HashSet;

fn traverse(instructions: &[char], tails: usize) -> usize {
    let mut map = HashSet::new();
    let mut ropes: Vec<(i32, i32)> = vec![(0, 0); tails + 1];

    map.insert(*ropes.last().unwrap());

    for inst in instructions {
        let head = ropes.first_mut().unwrap();
        match inst {
            'R' => head.0 += 1,
            'L' => head.0 -= 1,
            'U' => head.1 += 1,
            'D' => head.1 -= 1,
            _ => unreachable!(),
        }

        for j in 1..ropes.len() {
            let parent = ropes[j - 1];
            let knot = &mut ropes[j];
            let distance = (parent.0 - knot.0, parent.1 - knot.1);

            if distance.0.abs() == 2 || distance.1.abs() == 2 {
                knot.0 += distance.0.signum();
                knot.1 += distance.1.signum();
            }
        }

        map.insert(*ropes.last().unwrap());
    }

    map.len()
}

fn main() {
    let input = include_str!("../input.txt");
    let mut instructions = vec![];
    for line in input.split_terminator('\n') {
        let mut it = line.split(' ');
        let dir = it.next().unwrap().chars().next().unwrap();
        let count = it.next().unwrap().parse().unwrap();
        for _ in 0..count {
            instructions.push(dir);
        }
    }

    println!("Part 1: {}", traverse(&instructions, 1));
    println!("Part 2: {}", traverse(&instructions, 9));
}
