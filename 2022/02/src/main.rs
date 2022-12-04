enum Choice {
    Rock = 1,
    Paper = 2,
    Scissors = 3,
}

enum Outcome {
    Win = 6,
    Draw = 3,
    Loss = 0,
}

fn result(them: char, me: char) -> (u32, u32) {
    use Outcome::*;
    use Choice::*;
    let p1 = match (them, me) {
        ('A', 'Y') | ('B', 'Z') | ('C', 'X') => Win as u32,
        ('A', 'X') | ('B', 'Y') | ('C', 'Z') => Draw as u32,
        ('A', 'Z') | ('B', 'X') | ('C', 'Y') => Loss as u32,
        _ => unreachable!(),
    };

    let p2 = match me {
        'X' => Loss as u32 + match them {
            'A' => Scissors as u32,
            'B' => Rock as u32,
            'C' => Paper as u32,
            _ => unreachable!(),
        },
        'Y' => Draw as u32 + match them {
            'A' => Rock as u32,
            'B' => Paper as u32,
            'C' => Scissors as u32,
            _ => unreachable!(),
        },
        'Z' => Win as u32 + match them {
            'A' => Paper as u32,
            'B' => Scissors as u32,
            'C' => Rock as u32,
            _ => unreachable!(),
        },
        _ => unreachable!(),
    };

    (p1 + me as u32 - 'W' as u32, p2)
}
fn main() {
    let input = include_str!("../input.txt");
    let mut p1 = 0;
    let mut p2 = 0;
    for line in input.split('\n') {
        let mut chars = line.chars();
        let them = match chars.next() {
            Some(c) => c,
            None => break,
        };
        _ = chars.next();
        let me = chars.next().unwrap();
        let (t1, t2) = result(them, me);
        p1 += t1;
        p2 += t2;
    }
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
