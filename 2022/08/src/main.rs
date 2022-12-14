fn main() {
    let input = include_str!("../input.txt");
    let lines: Vec<_> = input.split_terminator('\n').collect();
    let size = lines[0].len();
    let mut visible = vec![vec![false; size]; size];
    for (row, line) in lines.iter().enumerate() {
        if row == 0 || row == size - 1 {
            visible[row].iter_mut().for_each(|b| *b = true);
            continue;
        }

        visible[row][0] = true;
        visible[row][size - 1] = true;

        let mut k = 0;
        let mut tallest = 0;
        let line_bytes = line.as_bytes();
        for col in 0..size {
            let height = line_bytes[col] - '0' as u8;
            if height > tallest {
                visible[row][col] = true;
                tallest = height;
                k = col;
            }
        }

        tallest = 0;
        for col in (k+1..size).rev() {
            let height = line_bytes[col] - '0' as u8;
            if height > tallest {
                visible[row][col] = true;
                tallest = height;
            }
        }
    }

    for col in 1..size - 1 {
        let mut k = 0;
        let mut tallest = 0;
        for row in 0..size {
            let height = lines[row].as_bytes()[col] - '0' as u8;
            if height > tallest {
                visible[row][col] = true;
                tallest = height;
                k = row;
            }
        }

        tallest = 0;
        for row in (k+1..size).rev() {
            let height = lines[row].as_bytes()[col] - '0' as u8;
            if height > tallest {
                visible[row][col] = true;
                tallest = height;
            }
        }
    }

    let p1 = visible.iter().flatten().filter(|&&b| b).count();

    println!("Part 1: {}", p1);
}
