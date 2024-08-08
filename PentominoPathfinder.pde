import java.math.BigDecimal;
import java.text.DecimalFormat;

// Board size, edit these to change the board size, WARNING! non square boards have not been tested
int boardX = 8;
int boardY = 8;

// Enables the animation of the flood algorithm, used for debugging
boolean showAnim = false;

// Color correction, this multiplies the hue of the pentominos, only affects the visuals
int cc1 = 50;

// Color correction, this multiplies the color of the biggest flood, only affects the visuals
int cc2 = 5;

// Animation variables for debugging, very useful
ArrayList<Node> animation = new ArrayList<Node>();
int animIndex = 0;
long timerStart = 0;

void setup() {  
  size(1024, 1024);
  
  long start = System.nanoTime();
  int count = 1_000_000;
  
  for (int i = 0; i < count; i++) {
    Layout layout = new Layout(8, 8, 4);
    layout.start();
  }
  
  double t = NanoToMillis(System.nanoTime() - start);
  DecimalFormat df = new DecimalFormat("#");
  df.setMaximumFractionDigits(100);
  println(df.format(t / count) + " millis to generate puzzle");
  println(df.format(t) + " millis total to generate " + count + " puzzles");
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

void draw() {
  background(0);
  
  /*
  // Get draw parameters
  int size = board[0].length;
  int cellSize = height / size;
  
  pieceIndex = 3;
  
  
  if (frameCount % 100 == 0) {
    //allQbits[qBitIndex].use(false);
    //qBitIndex = (qBitIndex + 1) % allQbits.length;
    //allQbits[qBitIndex].use(true);
  }
  
  // Draw pieces
  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
      if (board[x][y] == 0) {
        continue;
      }
      
      colorMode(HSB, 255);
      fill(board[x][y] * cc1, 128, 128);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
   
  // Draw path
  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
      if (depth[x][y] == 0) {
        continue;
      }     
      
      colorMode(RGB, 255);
      fill(depth[x][y] * cc2, depth[x][y] * cc2, depth[x][y] * cc2);
      rect(x * cellSize, y * cellSize, cellSize, cellSize);
    }
  }
  
  if (showAnim) {
    if (frameCount % 15 == 0) {
      animIndex = (animIndex + 1) % animation.size();
    }
    
    Node node = animation.get(animIndex);
    colorMode(RGB, 255);
    fill(255);
    rect(node.x * cellSize + 5, node.y * cellSize + 5, cellSize - 10, cellSize - 10);
  }
  */
}
