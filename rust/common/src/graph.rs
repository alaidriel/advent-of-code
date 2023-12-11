use std::collections::BinaryHeap;

pub mod constants {
    pub const SKIP: usize = usize::MAX;
}

pub struct Graph {
    pub nodes: Vec<Vec<Edge>>,
}

#[derive(Copy, Clone, Eq, PartialEq)]
struct State {
    cost: usize,
    position: usize,
}

#[derive(Debug, Copy, Clone)]
pub struct Edge {
    node: usize,
    cost: usize,
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.position.cmp(&other.position))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl From<&Vec<Vec<usize>>> for Graph {
    /// Creates an adjacency list for a graph representation
    /// of a grid. For each node in the graph, the weight
    /// of the edge between it and a neighbor is defined by
    /// the value of the neighbor in the grid.
    fn from(grid: &Vec<Vec<usize>>) -> Self {
        Self::new(grid, |_, _, next| next)
    }
}

impl Graph {
    /// Creates an adjacency list for a graph representation
    /// of a grid, using the function f to calculate the weight
    /// of each edge.
    pub fn new<F>(grid: &[Vec<usize>], f: F) -> Self
    where
        F: Fn(usize, (usize, usize), usize) -> usize,
    {
        let width = grid.iter().next().unwrap().len();
        let height = grid.len();
        let mut nodes: Vec<Vec<Edge>> = vec![];
        for (row, values) in grid.iter().enumerate() {
            for (col, &value) in values.iter().enumerate() {
                let mut edges: Vec<Edge> = vec![];
                for edge in super::grid::neighbors((width, height), (row, col), false) {
                    edges.push(Edge {
                        node: width * edge.0 + edge.1,
                        cost: f(value, (row, col), grid[edge.0][edge.1]),
                    });
                }
                nodes.push(edges);
            }
        }
        Self { nodes }
    }

    pub fn dijkstra(&self, start: usize, goal: usize) -> Option<usize> {
        let mut dist: Vec<_> = (0..self.nodes.len()).map(|_| usize::MAX).collect();
        let mut heap = BinaryHeap::new();

        dist[start] = 0;
        heap.push(State {
            cost: 0,
            position: start,
        });

        while let Some(State { cost, position }) = heap.pop() {
            if position == goal {
                return Some(cost);
            }

            if cost > dist[position] {
                continue;
            }

            for edge in &self.nodes[position] {
                if edge.cost == constants::SKIP {
                    continue;
                }

                let next = State {
                    cost: cost + edge.cost,
                    position: edge.node,
                };

                if next.cost < dist[next.position] {
                    heap.push(next);
                    dist[next.position] = next.cost;
                }
            }
        }

        None
    }
}
