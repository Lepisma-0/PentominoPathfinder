import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

int score = 0;

Node[][] nodes;
Queue<Node> floodNodes = new LinkedList<Node>();

byte[][] depth;
byte[][] path;
byte floodIndex = 0;
byte zero = 0;

ArrayList<MinesweeperSolver> tasks = new ArrayList<MinesweeperSolver>();

void setupMinesweeper() {
  depth = new byte[boardX][boardY];

  path = new byte[boardX][boardY];
  nodes = new Node[boardX][boardY];
  for (byte p_x = 0; p_x < boardX; p_x++) {
    for (byte p_y = 0; p_y < boardY; p_y++) {
      nodes[p_x][p_y] = new Node(p_x, p_y);
    }
  }

  // Allow for pieces to be placed on the borders of the board
  for (int i = 0; i < boardX; i++) {
    tasks.add(new MinesweeperSolver(i, 0));
    tasks.add(new MinesweeperSolver(i, boardY - 1));
  }

  for (int i = 1; i < boardY - 1; i++) {
    tasks.add(new MinesweeperSolver(0, i));
    tasks.add(new MinesweeperSolver(boardX - 1, i));
  }
}

void runMinesweeper() {
  ExecutorService exec = Executors.newFixedThreadPool(threadCount);

  try {
      List<Future<Integer>> results = exec.invokeAll(tasks);
      for (Future<Integer> result : results) System.out.println(result.get());    
  } catch (InterruptedException | java.util.concurrent.ExecutionException e) {
      e.printStackTrace();
  } finally {
      exec.shutdown();
  }
}

void statusMinesweeper() {
  for (int i = 0; i < tasks.size(); i++) {
  }
}
