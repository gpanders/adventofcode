fn answer(input: &str) -> (u32, u32) {
    let mut cals: Vec<u32> = input
        .split("\n\n")
        .map(|chunk| {
            chunk
                .split('\n')
                .map(|s| s.parse::<u32>().unwrap())
                .reduce(|acc, x| acc + x)
                .unwrap()
        })
        .collect();
    cals.sort();
    cals.reverse();
    let max = cals[0];
    let top_three: u32 = cals[0..3].into_iter().sum();
    (max, top_three)
}

fn main() {
    let input = include_str!("../input.txt");
    let (part1, part2) = answer(input);
    println!("{:#?}", part1);
    println!("{:#?}", part2);
}
