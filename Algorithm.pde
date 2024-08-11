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
final byte zero = 0;

ArrayList<MinesweeperSolver> tasks = new ArrayList<MinesweeperSolver>();

void setupMinesweeper() {

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

  startTimer();
  try {
      exec.invokeAll(tasks);
      exec.shutdown();
  } catch (InterruptedException e) {
      e.printStackTrace();
  } finally {
    endTimer("ms to finish algorithm");
  }
}
