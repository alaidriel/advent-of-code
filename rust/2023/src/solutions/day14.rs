pub fn input() -> &'static str {
    include_str!("../../input/day14.txt")
}

pub fn test_input() -> &'static str {
    include_str!("../../input/tests/day14.txt")
}

#[derive(Debug)]
struct Dish {
    platform: Vec<Vec<char>>,
}

impl Dish {
    fn new(input: &str) -> Self {
        let mut platform = vec![];
        for (r, line) in input.lines().enumerate() {
            platform.push(vec![]);
            for ch in line.chars() {
                platform[r].push(ch);
            }
        }
        Self { platform }
    }

    fn rocks(&self) -> Vec<(usize, usize)> {
        self.platform
            .iter()
            .enumerate()
            .flat_map(|(r, row)| {
                row.iter()
                    .enumerate()
                    .filter(|(_, &ch)| ch == 'O')
                    .map(move |(c, _)| (r, c))
            })
            .collect()
    }

    fn dist(&self, rock: (usize, usize)) -> usize {
        self.platform.len() - rock.0
    }

    fn north(&mut self, rock: (usize, usize)) {
        let (mut r, c) = rock;
        self.platform[r][c] = '.';
        while r > 0 && !matches!(self.platform[r - 1][c], 'O' | '#') {
            r -= 1;
        }
        self.platform[r][c] = 'O';
    }

    fn west(&mut self, rock: (usize, usize)) {
        let (r, mut c) = rock;
        self.platform[r][c] = '.';
        while c > 0 && !matches!(self.platform[r][c - 1], 'O' | '#') {
            c -= 1;
        }
        self.platform[r][c] = 'O';
    }

    fn east(&mut self, rock: (usize, usize)) {
        let (r, mut c) = rock;
        self.platform[r][c] = '.';
        while c < self.platform[r].len() - 1 && !matches!(self.platform[r][c + 1], 'O' | '#') {
            c += 1;
        }
        self.platform[r][c] = 'O';
    }

    fn south(&mut self, rock: (usize, usize)) {
        let (mut r, c) = rock;
        self.platform[r][c] = '.';
        while r < self.platform.len() - 1 && !matches!(self.platform[r + 1][c], 'O' | '#') {
            r += 1;
        }
        self.platform[r][c] = 'O';
    }
}

pub fn solve(input: &str) -> (usize, usize) {
    let mut dish = Dish::new(input);
    dish.rocks().iter().for_each(|&rock| dish.north(rock));
    let load = dish.rocks().iter().map(|&rock| dish.dist(rock)).sum();
    let mut dish = Dish::new(input);
    for _ in 0..1000 {
        dish.rocks().iter().for_each(|&rock| dish.north(rock));
        dish.rocks().iter().for_each(|&rock| dish.west(rock));
        dish.rocks().iter().rev().for_each(|&rock| dish.south(rock));
        dish.rocks().iter().rev().for_each(|&rock| dish.east(rock));
    }
    let cycled = dish.rocks().iter().map(|&rock| dish.dist(rock)).sum();
    (load, cycled)
}

common::test!(day14, (136, 64), (110779, 86069));
