import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;

// Board size, edit these to change the board size, WARNING! non square boards have not been tested
static int boardX = 8;
static int boardY = 8;
static int maxPieceCount = 4;
static int threadCount = Runtime.getRuntime().availableProcessors(); // Remove this and set to '1' to disable multithreading

// Color correction, this multiplies the hue of the pentominos, only affects the visuals
int cc1 = 50;

// Color correction, this multiplies the color of the biggest flood, only affects the visuals
int cc2 = 5;

long timerStart = 0;
Queue<LayoutData> topLayouts = new LinkedList<LayoutData>();

public static Queue<LayoutData> bestLayouts = new LinkedList<LayoutData>();
public static byte[][] bestBoard;
public static byte[][] bestDepth;
public static int bestScore;
public static int bestScoreThreads;

void setup() {  
  size(1024, 1024); 
  
  bestBoard = new byte[boardX][boardY];
  bestDepth = new byte[boardX][boardY];
  
  setupMinesweeper();
  runMinesweeper();
  
  /*
  for (int i = 0; i < 32; i++) {
    int usedPieces = 0;
    int newUsedPieces = usedPieces | (0x01 << i);
    boolean isUsed = (newUsedPieces >> i & 0x01) == 1;
    println(isUsed);
  }
  */
}

void startTimer() {
  timerStart = System.nanoTime();
}

void endTimer(String message) {
  double t = NanoToMillis(System.nanoTime() - timerStart);
  DecimalFormat df = new DecimalFormat("#");
  df.setMaximumFractionDigits(100);
  println(df.format(t) + message);
}

double NanoToMillis(long nano) {
  return ((double)nano) / 1000000;
}

int skips = 0;

void draw() { 
  if (skips == 0) {
    skips = 1;
    println("Donkey");
  }
  
  background(0);
  
  int size = bestBoard[0].length;
  int cellSize = height / size;
  
  while (bestLayouts.size() > 0) {
    LayoutData data = bestLayouts.poll();
    
    if (data != null && data.score > bestScore) {
      bestBoard = data.board;
      bestDepth = data.depth;
      bestScore = data.score;
      
      topLayouts.add(data);
      
      if (topLayouts.size() > 10) {
        topLayouts.remove();
      }
    }
  }
    
  if (bestBoard == null) {
    return;
  }
  
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {
      if (bestBoard[x][y] < 1) {
        continue;
      }
      
      colorMode(HSB, pieceCount());
      fill(bestBoard[x][y] - 1, pieceCount() / 2, pieceCount() / 2);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
  
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {
      if (bestDepth[x][y] == 0) {
        continue;
      }     
      
      colorMode(RGB, 255);
      fill(bestDepth[x][y] * cc2, bestDepth[x][y] * cc2, bestDepth[x][y] * cc2);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
}
