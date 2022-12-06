fn parse_line(line: &str) -> (u32, u32, u32, u32) {
    let mut it = line.split(&['-', ',']);
    let a = it.next().unwrap().parse().unwrap();
    let b = it.next().unwrap().parse().unwrap();
    let x = it.next().unwrap().parse().unwrap();
    let y = it.next().unwrap().parse().unwrap();
    (a, b, x, y)
}

fn main() {
    let input = include_str!("../input.txt");
    let mut p1 = 0;
    let mut p2 = 0;
    for (a, b, x, y) in input.split_terminator('\n').map(parse_line) {
        if (a <= x && b >= y) || (x <= a && y >= b) {
            p1 += 1;
        }

        if a <= y && b >= x {
            p2 += 1;
        }
    }

    println!("Part 1: {}", p1);
    println!("Part 2: {}", p2);
}
