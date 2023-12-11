use common::graph::{constants, Graph};

pub fn input() -> &'static str {
    include_str!("../../input/day12.txt")
}

pub fn test_input() -> &'static str {
    include_str!("../../input/tests/day12.txt")
}

pub fn solve(input: &str) -> (usize, usize) {
    let (starts, end) = endpoints(input);
    let g = Graph::new(&heights(input), |cur, _, next| {
        if next as isize - cur as isize > 1 {
            constants::SKIP // we never want to follow this path
        } else {
            1
        }
    });
    (
        g.dijkstra(0, end).unwrap(),
        starts
            .iter()
            .map(|&start| g.dijkstra(start, end).unwrap_or(usize::MAX))
            .min()
            .unwrap(),
    )
}

fn endpoints(input: &str) -> (Vec<usize>, usize) {
    let mut starts = vec![];
    let mut end = 0;
    let width = input.lines().next().unwrap().len();
    for (r, row) in input.lines().enumerate() {
        for (c, ch) in row.chars().enumerate() {
            if ch == 'a' || ch == 'S' {
                starts.push(width * r + c);
            } else if ch == 'E' {
                end = width * r + c;
            }
        }
    }
    (starts, end)
}

fn heights(input: &str) -> Vec<Vec<usize>> {
    let mut heights: Vec<Vec<usize>> = vec![];
    for (r, row) in input.lines().enumerate() {
        heights.push(vec![]);
        for c in row.chars() {
            if c == 'E' {
                heights[r].push(('z' as u8 - 97) as usize);
            } else if c == 'S' {
                heights[r].push(0);
            } else {
                heights[r].push((c as u8 - 97) as usize);
            }
        }
    }
    heights
}

common::test!(day12, (31, 29), (423, 416));
