import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maze/helper.dart';
import '../Cell.dart';

GlobalKey<_MazeState> globalKey = GlobalKey();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int type = 0;

  reset() {
    setState(() {
      type = 0;
    });
    globalKey.currentState.reset();
  }

  solve(int x) {
    setState(() {
      type = x;
    });
    globalKey.currentState.solve(x);
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: black,
      body: Container(
        margin: EdgeInsets.all(15.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        solve(1);
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            'DFS',
                            style: TextStyle(
                              color: (this.type == 1 ? gray : lightGray),
                              fontSize: data.size.height * 0.08,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(),
                  ],
                ),
              ),
              Container(
                child: Center(
                  child: Maze(
                    height: min(data.size.height, data.size.width),
                    width: max(data.size.height, data.size.width),
                    key: globalKey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        solve(2);
                      },
                      child: Container(
                        child: Center(
                          child: Text(
                            'BFS',
                            style: TextStyle(
                              color: (this.type == 2 ? gray : lightGray),
                              fontSize: data.size.height * 0.08,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: reset,
                      child: Image(
                        image: AssetImage(
                          'assets/reset.png',
                        ),
                        height: data.size.height * 0.1,
                        width: data.size.height * 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Maze extends StatefulWidget {
  final double height, width;
  final Key key;

  Maze({
    this.height,
    this.width,
    this.key,
  });

  @override
  _MazeState createState() => _MazeState();
}

class _MazeState extends State<Maze> {
  final int cellSize = 30;
  int n, m;
  List<List<Cell>> maze;
  List<List<bool>> was;

  @override
  void initState() {
    super.initState();
    n = widget.height * 0.85 ~/ cellSize;
    m = widget.width * 0.75 ~/ cellSize;
    maze = List();
    was = List();
    for (int i = 0; i < n + 2; i++) {
      was.add(List.generate(m + 2, (j) {
        return false;
      }));
    }
    for (int i = 0; i < n + 2; i++) {
      maze.add(List.generate(m + 2, (j) {
        return Cell(block, blockColor);
      }));
    }
    while (!isSolvable()) {
      mazeBuilder();
    }
  }

  mazeBuilder() {
    clearWas();
    setState(() {
      for (int i = 1; i < n + 1; i++) {
        for (int j = 1; j < m + 1; j++) {
          int rand = Random().nextInt(2);
          maze[i][j] =
              (rand == 1 ? Cell(block, blockColor) : Cell(space, spaceColor));
        }
      }
      maze[1][1] = maze[n][m] = Cell(begin, startColor);
    });
  }

  bool isSolvable() {
    if (maze.length == 0) return false;
    checker(1, 1);
    return was[n][m];
  }

  checker(int x, int y) {
    setState(() {
      was[x][y] = true;
    });
    for (int i = 0; i < 4; i++) {
      if (!was[x + dx[i]][y + dy[i]] &&
          maze[x + dx[i]][y + dy[i]].type != block) {
        checker(x + dx[i], y + dy[i]);
      }
    }
  }

  clearWas() {
    setState(() {
      for (int i = 1; i < n + 1; i++) {
        for (int j = 1; j < m + 1; j++) {
          if (was[i][j]) {
            setState(() {
              was[i][j] = false;
              maze[i][j] = Cell(space, spaceColor);
            });
          }
        }
      }
      maze[1][1] = maze[n][m] = Cell(begin, startColor);
    });
  }

  solve(int x) {
    clearWas();
    if (x == 0) {
      return;
    } else if (x == 1) {
      dfs(1, 1);
    } else {
      bfs(1, 1);
    }
  }

  dfs(int x, int y) {
    setState(() {
      was[x][y] = true;
      if (!was[n][m] && (x != 1 || y != 1)) {
        maze[x][y] = Cell(path, pathColor);
      }
    });
    for (int i = 0; i < 4; i++) {
      if (!was[x + dx[i]][y + dy[i]] &&
          maze[x + dx[i]][y + dy[i]].type != block) {
        dfs(x + dx[i], y + dy[i]);
      }
    }
    setState(() {
      if (!was[n][m]) {
        maze[x][y] = Cell(space, spaceColor);
      }
    });
  }

  bfs(int x, int y) async {
    Queue<Pair> q = Queue();
    q.add(Pair(x, y));
    setState(() {
      was[x][y] = true;
    });
    while (q.isNotEmpty) {
      int x = q.first.x;
      int y = q.first.y;
      setState(() {
        if (!was[n][m] && (x != 1 || y != 1)) {
          maze[x][y] = Cell(path, pathColor);
        }
      });
      q.removeFirst();
      for (int i = 0; i < 4; i++) {
        if (!was[x + dx[i]][y + dy[i]] &&
            maze[x + dx[i]][y + dy[i]].type != block) {
          q.add(Pair(x + dx[i], y + dy[i]));
          setState(() {
            was[x + dx[i]][y + dy[i]] = true;
          });
        }
      }
    }
  }

  reset() {
    mazeBuilder();
    while (!isSolvable()) {
      mazeBuilder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(n, (i) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(m, (j) {
                return CellBuilder(
                  size: (cellSize - 5).toDouble(),
                  color: maze[i + 1][j + 1].color,
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}

class CellBuilder extends StatelessWidget {
  final double size;
  final color;
  CellBuilder({
    this.size,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(2.5),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class Pair {
  int x, y;
  Pair(this.x, this.y);
}
