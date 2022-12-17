enum Instruction {
    Noop,
    Addx(i32),
}

#[derive(Debug)]
enum ParseError {
    InvalidLine,
    UnknownInstruction,
}

impl std::error::Error for ParseError {}

impl std::fmt::Display for ParseError {
    fn fmt(&self, fmt: &mut std::fmt::Formatter<'_>) -> Result<(), std::fmt::Error> {
        match self {
            ParseError::InvalidLine => write!(fmt, "Invalid line")?,
            ParseError::UnknownInstruction => write!(fmt, "Unknown instruction")?,
        }

        Ok(())
    }
}

impl TryFrom<&str> for Instruction {
    type Error = ParseError;
    fn try_from(s: &str) -> Result<Self, Self::Error> {
        let mut it = s.split(' ');
        match it.next() {
            Some(s) => match s {
                "noop" => Ok(Instruction::Noop),
                "addx" => Ok(Instruction::Addx(it.next().unwrap().parse().unwrap())),
                _ => Err(ParseError::UnknownInstruction),
            },
            _ => Err(ParseError::InvalidLine),
        }
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let input = include_str!("../input.txt");
    let mut instructions = input.split_terminator('\n').map(Instruction::try_from);

    let mut x: i32 = 1;
    let mut signal_strength = 0;
    let mut next_tick = 20;
    let mut stall = 0;
    let mut inst = Instruction::Noop;
    let mut cycle = 1;
    let mut crt = [['.'; 40]; 6];
    let mut beam = (0, 0);

    loop {
        if stall == 0 {
            if let Instruction::Addx(v) = inst {
                x += v;
            }

            inst = match instructions.next() {
                Some(i) => i?,
                None => break,
            };

            stall = match inst {
                Instruction::Addx(_) => 1,
                _ => 0,
            };
        } else {
            stall -= 1;
        }

        if cycle == next_tick {
            signal_strength += cycle * x;
            next_tick += 40;
        }

        if (beam.0 as i32 - x).abs() <= 1 {
            crt[beam.1][beam.0] = '#';
        }

        if beam.0 == crt[0].len() - 1 {
            beam.1 += 1;
            beam.0 = 0;
        } else {
            beam.0 += 1;
        }

        cycle += 1;
    }

    println!("Part 1: {}", signal_strength);
    println!("Part 2:");
    for row in crt.iter() {
        for col in row.iter() {
            print!("{}", col);
        }
        println!("");
    }

    Ok(())
}
