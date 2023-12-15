use std::fmt;

pub fn input() -> &'static str {
    include_str!("../../input/day15.txt")
}

pub fn test_input() -> &'static str {
    include_str!("../../input/tests/day15.txt")
}

const BOXES: usize = 256;
const EMPTY_BOX: Vec<Lens> = Vec::new();

fn process(step: &str) -> usize {
    let mut value = 0;
    for ch in step.bytes() {
        value += usize::from(ch);
        value *= 17;
        value %= 256;
    }
    value
}

#[derive(Copy, Clone)]
struct Lens {
    which: usize,
    label: &'static str,
    action: char,
    focal: Option<usize>,
}

impl fmt::Debug for Lens {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self.action {
                '-' => format!("{}-", self.label),
                '=' => format!("{}={}", self.label, self.focal.unwrap()),
                _ => panic!("unknown action"),
            }
        )
    }
}

impl Lens {
    fn new(raw: &str) -> Self {
        let label: String = raw
            .chars()
            .take_while(|ch| !matches!(ch, '=' | '-'))
            .collect();
        let which = process(&label);
        let action = if raw.contains('-') { '-' } else { '=' };
        let focal = raw.split_once('=').map(|(_, focal)| focal.parse().unwrap());
        Self {
            label: label.leak(),
            which,
            action,
            focal,
        }
    }
}

struct Arrangement([Vec<Lens>; BOXES]);

impl Arrangement {
    fn new() -> Self {
        Self([EMPTY_BOX; BOXES])
    }

    fn process(&mut self, step: Lens) {
        let b = &mut self.0[step.which];
        let index = b.iter().position(|lens| lens.label == step.label);
        match (step.action, index) {
            ('=', Some(index)) => b[index] = step,
            ('=', None) => b.push(step),
            ('-', Some(index)) => {
                b.remove(index);
            }
            _ => {}
        }
    }

    fn power(&self) -> usize {
        self.0
            .iter()
            .enumerate()
            .flat_map(|(i, b)| {
                b.iter()
                    .enumerate()
                    .map(move |(j, lens)| (i + 1) * (j + 1) * lens.focal.unwrap())
            })
            .sum()
    }
}

pub fn solve(input: &str) -> (usize, usize) {
    let verification = input.split(',').map(process).sum();
    let mut arrangement = Arrangement::new();
    input
        .split(',')
        .map(Lens::new)
        .for_each(|lens| arrangement.process(lens));
    (verification, arrangement.power())
}

common::test!(day15, (1320, 145), (520500, 213097));
