fn find_duplicate(s: &str) -> char {
    let mut seen = [false; 52];
    for c in s.chars().take(s.len() / 2) {
        seen[priority(c) as usize - 1] = true;
    }

    for c in s.chars().skip(s.len() / 2) {
        if seen[priority(c) as usize - 1] {
            return c;
        }
    }

    unreachable!();
}

fn priority(c: char) -> u32 {
    match c {
        'a'..='z' => c as u32 - 'a' as u32 + 1,
        'A'..='Z' => c as u32 - 'A' as u32 + 27,
        _ => unreachable!(),
    }
}

fn main() {
    let input = include_str!("../input.txt");
    let p1: u32 = input
        .split_terminator('\n')
        .map(find_duplicate)
        .map(priority)
        .sum();
    let p2: u32 = {
        let mut sum = 0;
        let mut counts = [0; 52];
        for (i, line) in input.split_terminator('\n').enumerate() {
            let mut seen = [false; 52];
            for c in line.chars() {
                if !seen[priority(c) as usize - 1] {
                    counts[priority(c) as usize -  1] += 1;
                }
                seen[priority(c) as usize - 1] = true;
            }

            if i % 3 == 2 {
                sum += counts.iter().position(|&v| v == 3).unwrap() as u32 + 1;
                for v in &mut counts {
                    *v = 0;
                }
            }
        }
        sum
    };
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
