use std::collections::{HashSet, VecDeque};

pub fn input() -> &'static str {
    include_str!("../../input/day10.txt")
}

pub fn test_input_p1() -> &'static str {
    include_str!("../../input/tests/day10.txt")
}

pub fn test_input_p2() -> &'static str {
    include_str!("../../input/tests/day10.2.txt")
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
enum Tile {
    NorthSouth,
    EastWest,
    NorthEast,
    NorthWest,
    SouthWest,
    SouthEast,
    Ground,
    Start,
}

impl Tile {
    #[rustfmt::skip] // Surely there is an easier way
    fn neighbors(&self, north: bool, east: bool, vertical: bool) -> &[Self] {
        match self {
            Self::Start | Self::NorthWest | Self::NorthEast if vertical && north => &[Self::NorthSouth, Self::SouthEast, Self::SouthWest],
            Self::Start | Self::SouthWest | Self::SouthEast if vertical && !north => &[Self::NorthSouth, Self::NorthEast, Self::NorthWest],
            Self::NorthWest | Self::SouthWest if !vertical && !east => &[Self::EastWest, Self::NorthEast, Self::SouthEast],
            Self::NorthEast | Self::SouthEast if !vertical && east => &[Self::EastWest, Self::NorthWest, Self::SouthWest],
            Self::Start => match (vertical, north, east) {
                (false, false, true) => &[Self::EastWest, Self::NorthWest, Self::SouthWest],
                (false, false, false) => &[Self::EastWest, Self::NorthEast, Self::SouthEast],
                _ => &[],
            },
            Self::EastWest => match (vertical, east) {
                (false, true) => &[Self::EastWest, Self::NorthWest, Self::SouthWest],
                (false, false) => &[Self::EastWest, Self::NorthEast, Self::SouthEast],
                _ => &[],
            },
            Self::NorthSouth => match (vertical, north) {
                (true, true) => &[Self::NorthSouth, Self::SouthEast, Self::SouthWest],
                (true, false) => &[Self::NorthSouth, Self::NorthEast, Self::NorthWest],
                _ => &[],
            },
            _ => &[],
        }
    }
}

impl From<char> for Tile {
    fn from(value: char) -> Self {
        match value {
            '|' => Self::NorthSouth,
            '-' => Self::EastWest,
            'L' => Self::NorthEast,
            'J' => Self::NorthWest,
            '7' => Self::SouthWest,
            'F' => Self::SouthEast,
            '.' => Self::Ground,
            'S' => Self::Start,
            _ => panic!(),
        }
    }
}

#[derive(Debug)]
struct TileGrid {
    width: usize,
    height: usize,
    tiles: Vec<Vec<Tile>>,
}

impl From<&str> for TileGrid {
    fn from(value: &str) -> Self {
        let tiles: Vec<Vec<_>> = value
            .lines()
            .map(|line| line.chars().map(Tile::from).collect())
            .collect();
        Self {
            width: tiles[0].len(),
            height: tiles.len(),
            tiles,
        }
    }
}

impl TileGrid {
    fn neighbors(&self, (x, y): (usize, usize)) -> impl IntoIterator<Item = (usize, usize)> + '_ {
        common::grid::neighbors((self.width, self.height), (x, y), false)
            .into_iter()
            .filter(|&(x, y)| !matches!(self.tiles[y][x], Tile::Ground))
            .filter(move |&(dx, dy)| {
                self.tiles[y][x]
                    .neighbors(dy < y, dx > x, x == dx)
                    .contains(&self.tiles[dy][dx])
            })
    }

    fn start(&self) -> (usize, usize) {
        (0..self.width)
            .find_map(|x| {
                (0..self.height)
                    .find(|&y| matches!(&self.tiles[y][x], Tile::Start))
                    .map(|y| (x, y))
            })
            .unwrap()
    }

    fn bfs(&self) -> HashSet<(usize, usize)> {
        let (x, y) = self.start();
        let mut queue = VecDeque::new();
        let mut explored = HashSet::new();
        explored.insert((x, y));
        queue.push_back((x, y));
        while !queue.is_empty() {
            let (x, y) = queue.pop_front().unwrap();
            for neighbor in self.neighbors((x, y)) {
                if !explored.contains(&neighbor) {
                    explored.insert(neighbor);
                    queue.push_back(neighbor);
                }
            }
        }
        explored
    }
}

pub fn solve_p1(input: &str) -> usize {
    TileGrid::from(input).bfs().len() / 2
}

pub fn solve_p2(_: &str) -> usize {
    0
}

pub fn solve(input: &str) -> (usize, usize) {
    (solve_p1(input), solve_p2(input))
}

common::test_distinct!(day10, 8, 0, (6815, 0));
