use std::collections::{HashMap, HashSet};

use common::graph::Graph;

pub fn input() -> &'static str {
    include_str!("../../input/day11.txt")
}

pub fn test_input() -> &'static str {
    include_str!("../../input/tests/day11.txt")
}

struct Image {
    pixels: Vec<Vec<usize>>,
    galaxies: Vec<(usize, usize)>,
    rows: HashMap<usize, bool>,
    cols: HashMap<usize, bool>,
}

impl Image {
    fn new(input: &str) -> Self {
        let mut pixels = vec![];
        let mut galaxies = vec![];
        for (r, row) in input.lines().enumerate() {
            pixels.push(vec![]);
            for (c, ch) in row.chars().enumerate() {
                pixels[r].push(ch as usize);
                if ch == '#' {
                    galaxies.push((r, c));
                }
            }
        }
        let (rows, cols) = Self::empty(&pixels);
        Self {
            pixels,
            galaxies,
            rows,
            cols,
        }
    }

    fn empty(pixels: &[Vec<usize>]) -> (HashMap<usize, bool>, HashMap<usize, bool>) {
        let mut rows = HashMap::new();
        for (i, row) in pixels.iter().enumerate() {
            if row.contains(&('#' as usize)) {
                rows.insert(i, true);
            }
        }
        let mut cols = HashMap::new();
        for col in 0..pixels[0].len() {
            for row in pixels {
                if row[col] == ('#' as usize) {
                    cols.insert(col, true);
                    break;
                }
            }
        }
        (rows, cols)
    }

    fn paths(&self, cost: usize) -> usize {
        let graph = Graph::new(&self.pixels, |_, (row, col), _| {
            if !self.rows.contains_key(&row) || !self.cols.contains_key(&col) {
                cost
            } else {
                1
            }
        });
        let width = self.pixels[0].len();
        let mut len = 0;
        let mut explored = HashSet::new();
        for galaxy in &self.galaxies {
            let (r, c) = galaxy;
            for other in self.galaxies.iter().filter(|other| galaxy != *other) {
                let (rr, cc) = other;
                let first = galaxy.min(other);
                let second = galaxy.max(other);
                if explored.contains(&(first, second)) {
                    continue;
                }
                len += graph.dijkstra(r * width + c, rr * width + cc).unwrap();
                explored.insert((first, second));
            }
        }
        len
    }
}

pub fn solve(input: &str) -> (usize, usize) {
    let image = Image::new(input);
    (image.paths(2), image.paths(1_000_000))
}

common::test!(day11, (374, 82000210), (9591768, 746962097860));
