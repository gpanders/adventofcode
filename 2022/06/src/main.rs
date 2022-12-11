fn marker(slice: &str) -> bool {
    let mut seen = [false; 26];
    for c in slice.chars() {
        let i = c as u8 - 'a' as u8;
        if seen[i as usize] {
            return false;
        }
        seen[i as usize] = true;
    }

    return true;
}

fn find_start(message: &str, len: usize) -> usize {
    let mut n = 0;
    while !marker(&message[n..n+len]) {
        n += 1;
    }

    n + len
}

fn main() {
    let input = include_str!("../sample.txt");

    let p1 = find_start(&input, 4);
    let p2 = find_start(&input, 14);
    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
