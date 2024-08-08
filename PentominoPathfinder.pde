
// Board size, edit these to change the board size, WARNING! non square boards have not been tested
int boardX = 8;
int boardY = 8;

// Enables the animation of the flood algorithm, used for debugging
boolean showAnim = false;

// Color correction, this multiplies the hue of the pentominos, only affects the visuals
int cc1 = 50;

// Color correction, this multiplies the color of the biggest flood, only affects the visuals
int cc2 = 5;

// The board with the pentominos
byte[][] board = new byte[8][8];

// A list to keep track the used pentominos
ArrayList<Byte> used = new ArrayList<Byte>();
byte pieceIndex = 0;

// Animation variables for debugging, very useful
ArrayList<Node> animation = new ArrayList<Node>();
int animIndex = 0;

int qBitIndex = 0;
Qbit lastQbit = null;

void setup() {  
  size(1024, 1024);
  
  long start = System.nanoTime(); 
  createNodes();
  calculateQuantumData();
  println(NanoToMillis(System.nanoTime() - start) + " millis to generate needed data");

  // Do some warmup
  for (int i = 0; i < 10; i++) {
    solve();
  }
  
  
  start = System.nanoTime();
  int count = 100000;
  for (int i = 0; i < count; i++) {
    solve();
  }
  double t = NanoToMillis(System.nanoTime() - start);
  println((t / count) + " millis to generate puzzle");
  println((t) + " millis total to generate " + count + " puzzles");
  
}

double NanoToMillis(long nano) {
  return ((double)nano) / 1000000;
}

void draw() {
  background(0);
  // Get draw parameters
  int size = board[0].length;
  int cellSize = height / size;
  
  pieceIndex = 3;
  
  
  if (frameCount % 100 == 0) {
    //allQbits[qBitIndex].use(false);
    //qBitIndex = (qBitIndex + 1) % allQbits.length;
    //allQbits[qBitIndex].use(true);
    solve();
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
  
}

void calculateShortestPath() {
  // Keep track of the best depth
  int bestDepth = 0;
  int[][] depthTemp = null;
  floodIndex = 0;
  
  // Flood every blank cell that has not been flooded
  // This results in a list of floods that are separate from each other and their furthest point, that will be used as the starting point
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {      
      
      // If there is a piece or is already flooded, skip
      if (board[x][y] != 0 || path[x][y] != 0) {
        continue;
      }
      
      // Flood this cell
      flood(x, y);
      
      // If this is the deepest flood, keep the depth map
      if (deepestNode.z > bestDepth) {
        bestDepth = deepestNode.z;
        depthTemp = depth.clone();
      }
    }
  }
  
  if (depthTemp != null) {
    depth = depthTemp.clone();
  }
}
