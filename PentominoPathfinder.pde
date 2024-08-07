class Node {
  public int x;
  public int y;
  public int z;
  public int from;
  public Node parent;
  
  public Node(int x, int y, int z, int from, Node parent) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.from = from;
    this.parent = parent;
  }
  
  public boolean handle(Node other) {
    if (x == other.x && y == other.y) {
      if (z > other.z) {
        z = other.z;
        depth[x][y] = z;
        parent = other.parent;
      }
      return true;
    }
    
    return false;
  }
}
// Board size, edit these to change the board size, WARNING! non square boards have not been tested
int boardX = 8;
int boardY = 8;

// Displays the shortest path in white to gray squares
boolean showPath = true;

// Enables the animation of the flood algorithm, used for debugging
boolean showAnim = false;

// Color correction, this multiplies the hue of the pentominos, only affects the visuals
int cc1 = 50;

// Color correction, this multiplies the color of the biggest flood, only affects the visuals
int cc2 = 5;

// This represents the end of the path, the value will remain even after the calculations are done
Node deepestNode = null;

// The board with the pentominos
byte[][] board = new byte[8][8];

// A list to keep track the used pentominos
ArrayList<Byte> used = new ArrayList<Byte>();

// Path and depth
byte[][] path = new byte[8][8];
int[][] depth = new int[8][8];

// The starting position of every flood pass
ArrayList<PVector> floods = new ArrayList<PVector>();

// The list of nodes on a flood
ArrayList<Node> floodNodes = new ArrayList<Node>();

// Internal indexes
byte pieceIndex = 0;
byte floodIndex = 0;

// Animation variables for debugging, very useful
ArrayList<Node> animation = new ArrayList<Node>();
int animIndex = 0;

void setup() {
  long start = System.nanoTime();
  size(1024, 1024);
  solve();
  println(NanoToMillis(System.nanoTime() - start) + " millis");
}

double NanoToMillis(long nano) {
  return ((double)nano) / 1000000;
}

void draw() {
  background(255);
  
  // Get draw parameters
  int size = board[0].length;
  int cellSize = height / size;
    
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

  
  if (showPath) {
    Node node = deepestNode.parent;
    
    while (node != null) {
      colorMode(RGB, 255);
      fill(255 - node.z * cc2);
      rect(node.x * cellSize + 5, node.y * cellSize + 5, cellSize - 10, cellSize - 10);
      node = node.parent;
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

void solve() {
  // Clear all the arrays
  pieceIndex = 1;
  board = new byte[boardX][boardY];
  path = new byte[boardX][boardY];
  used = new ArrayList<Byte>();
  
  // The max amount of pentominos, the lower, the faster it goes but more things it misses
  int hardPieceLimit = 4;
  
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {
      
      // Try place every single piece in this position, place the first one found
      tryPlace(x, y);
      
      // Stop if the piece limit was reached
      if (pieceIndex > hardPieceLimit) {
        break;
      }
    }
    
    // Stop if the piece limit was reached
    if (pieceIndex > hardPieceLimit) {
      break;
    }
  }
  
  // Keep track of the best depth
  int bestDepth = 0;
  int[][] depthTemp = null;
  
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

void flood(int x, int y) {  
  // Clear arrays
  floodNodes = new ArrayList<Node>();
  depth = new int[boardX][boardY];
  floodIndex++;
  
  // Create first node
  addNode(x, y, 0, null);  
  
  // Dijkstra's algorithm
  while(floodNodes.size() > 0) {
    Node node = floodNodes.get(0);
    floodNodes.remove(0);
       
    floodNode(node);
  }
  
  // If the flood was too small, discard it
  if (deepestNode.z < 5) {
    return;
  } 
  
  // SECOND FLOOD
  
  // Clear arrays
  floodNodes = new ArrayList<Node>();
  depth = new int[boardX][boardY];
  
  // Create first node
  addNode(deepestNode.x, deepestNode.y, 0, null);  
  
  // Dijkstra's algorithm
  while(floodNodes.size() > 0) {
    Node node = floodNodes.get(0);
    floodNodes.remove(0);
       
    reFloodNode(node);
  }
  
  // If the flood was too small, discard it
  if (deepestNode.z < 5) {
    return;
  } 
}

void floodNode(Node node) {
  int x = node.x;
  int y = node.y;
  int z = node.z;
  
  // Is in bounds
  if (x > -1 && y > -1 && x < boardX && y < boardY) {
    
    // If there is no piece, this hasn't been evaluated before, OR the depth is higher (means this is a shorter path)
    if (board[x][y] == 0 && (path[x][y] == 0 || depth[x][y] > z)) {
      if (showAnim) animation.add(node);
      
      // Set the depth and index of the flood
      path[x][y] = floodIndex;
      depth[x][y] = z;
      
      // Flood neighbours
      if (node.from != 2) addNode(x + 1, y, 1, node);
      if (node.from != 1) addNode(x - 1, y, 2, node);
      if (node.from != 4) addNode(x, y + 1, 3, node);
      if (node.from != 3) addNode(x, y - 1, 4, node);
      
      // If this is the deepest node, store the position
      if (deepestNode == null || z > deepestNode.z) {
        deepestNode = node;
      }
    }
  }
}

void reFloodNode(Node node) {
  int x = node.x;
  int y = node.y;
  int z = node.z;
  
  // Is in bounds
  if (x > -1 && y > -1 && x < boardX && y < boardY) {
    
    // If the path is from this flood, and the depth is zero (untouched) or higher (shorter path)
    if (path[x][y] == floodIndex && (depth[x][y] == 0 || depth[x][y] > z)) {
      if (showAnim) animation.add(node);
      
      // Set the depth and index of the flood
      path[x][y] = floodIndex;
      depth[x][y] = z;
      
      // Flood neighbours
      if (node.from != 2) addNode(x + 1, y, 1, node);
      if (node.from != 1) addNode(x - 1, y, 2, node);
      if (node.from != 4) addNode(x, y + 1, 3, node);
      if (node.from != 3) addNode(x, y - 1, 4, node);
      
      // If this is the deepest node, store the position
      if (deepestNode == null || z > deepestNode.z) {
        deepestNode = node;
      }
    }
  }
}

// Adds a node and does some checks to test duplicates
void addNode(int x, int y, int from, Node parent) {
  Node newNode = new Node(x, y, parent == null ? 0 : parent.z + 1, from, parent);
  
  // Checks if the node is duplicate, if it is, apply depth and parent corrections
  for (int i = 0; i < floodNodes.size(); i++) {
    if (floodNodes.get(i).handle(newNode)) {
      return;
    }
  }
  
  // Add node if nothing happens
  floodNodes.add(newNode);
}

// Tries to place any piece in the given position
void tryPlace(int p_x, int p_y) {
  
  // Loop through all the types
  for (int i = 0; i < 12; i++) {
 
    // If this type has been used, ignore
    if (hasBeenUsed(i)) {
      continue;
    }   
    
    // Loop through all the variants
    int variants = pieces[i].length;
    for (int v = 0; v < variants; v++) {
      
      // If it can't be placed, ignore
      if (!canPlace(i, v, p_x, p_y)) {
        continue;
      }   
      
      // Get the positions for the cells of the piece
      byte[] piece = pieces[i][v];
            
      // Place the cells and give them value for later visualization
      for (int c = 0; c < piece.length; c += 2) {
        int x = piece[c] + p_x;
        int y = piece[c + 1] + p_y;
        
        // Set the color
        board[x][y] = pieceIndex;
      }
      
      // Add piece to the used list
      used.add(byte(i));
      pieceIndex++;
      break;
    } 
  }
}

boolean hasBeenUsed(int i) {
  // Check if the index is in the used list
  for (int p = 0; p < used.size(); p++) {
    if (used.get(p) == i) { 
      return true;
    }
  }
  
  return false;
}

boolean canPlace(int i, int v, int p_x, int p_y) {
  // Get the positions for each cell of the piece
  byte[] piece = pieces[i][v];
        
  // Return true only if all the positions of the array are empty
  for (int c = 0; c < piece.length; c += 2) {
    int x = piece[c] + p_x;
    int y = piece[c + 1] + p_y;
    
    if (x >= boardX || y >= boardY || board[x][y] != 0) {
      return false;
    }
  }
  
  return true;
}
  
// Pentomino coordinates by SMISKI
byte[][][] pieces = {
    // N
    {
        {0, 0, 0, 1, 0, 2, 1, 2, 1, 3} ,
        {0, 1, 0, 2, 0, 3, 1, 0, 1, 1} ,
        {0, 1, 1, 1, 2, 0, 2, 1, 3, 0} ,
        {0, 0, 1, 0, 2, 0, 2, 1, 3, 1} ,
        {0, 0, 0, 1, 1, 1, 1, 2, 1, 3} ,
        {0, 2, 0, 3, 1, 0, 1, 1, 1, 2} ,
        {0, 1, 1, 0, 1, 1, 2, 0, 3, 0} ,
        {0, 0, 1, 0, 1, 1, 2, 1, 3, 1} ,
    },
    // F
    {
        {0, 1, 1, 0, 1, 1, 1, 2, 2, 2} ,
        {0, 1, 1, 0, 1, 1, 1, 2, 2, 0} ,
        {0, 1, 1, 1, 1, 2, 2, 0, 2, 1} ,
        {0, 1, 1, 0, 1, 1, 2, 1, 2, 2} ,
        {0, 0, 1, 0, 1, 1, 1, 2, 2, 1} ,
        {0, 2, 1, 0, 1, 1, 1, 2, 2, 1} ,
        {0, 1, 0, 2, 1, 0, 1, 1, 2, 1} ,
        {0, 0, 0, 1, 1, 1, 1, 2, 2, 1} ,
    },
    // P
    {
        {0, 0, 0, 1, 0, 2, 1, 1, 1, 2} ,
        {0, 0, 0, 1, 0, 2, 1, 0, 1, 1} ,
        {0, 1, 1, 0, 1, 1, 2, 0, 2, 1} ,
        {0, 0, 1, 0, 1, 1, 2, 0, 2, 1} ,
        {0, 0, 0, 1, 1, 0, 1, 1, 1, 2} ,
        {0, 1, 0, 2, 1, 0, 1, 1, 1, 2} ,
        {0, 0, 0, 1, 1, 0, 1, 1, 2, 0} ,
        {0, 0, 0, 1, 1, 0, 1, 1, 2, 1} ,
    },
    // Y
    {
        {0, 0, 0, 1, 0, 2, 0, 3, 1, 2} ,
        {0, 0, 0, 1, 0, 2, 0, 3, 1, 1} ,
        {0, 1, 1, 1, 2, 0, 2, 1, 3, 1} ,
        {0, 0, 1, 0, 2, 0, 2, 1, 3, 0} ,
        {0, 1, 1, 0, 1, 1, 1, 2, 1, 3} ,
        {0, 2, 1, 0, 1, 1, 1, 2, 1, 3} ,
        {0, 0, 1, 0, 1, 1, 2, 0, 3, 0} ,
        {0, 1, 1, 0, 1, 1, 2, 1, 3, 1} ,
    },
    // Z
    {
        {0, 0, 1, 0, 1, 1, 1, 2, 2, 2} ,
        {0, 2, 1, 0, 1, 1, 1, 2, 2, 0} ,
        {0, 1, 0, 2, 1, 1, 2, 0, 2, 1} ,
        {0, 0, 0, 1, 1, 1, 2, 1, 2, 2} ,
    },
    // V
    {
        {0, 0, 0, 1, 0, 2, 1, 2, 2, 2} ,
        {0, 0, 0, 1, 0, 2, 1, 0, 2, 0} ,
        {0, 2, 1, 2, 2, 0, 2, 1, 2, 2} ,
        {0, 0, 1, 0, 2, 0, 2, 1, 2, 2} ,
    },
    // U
    {
        {0, 0, 0, 1, 0, 2, 1, 0, 1, 2} ,
        {0, 0, 0, 1, 1, 1, 2, 0, 2, 1} ,
        {0, 0, 0, 1, 1, 0, 2, 0, 2, 1} ,
        {0, 0, 0, 2, 1, 0, 1, 1, 1, 2} ,
    },
    // T
    {
        {0, 2, 1, 0, 1, 1, 1, 2, 2, 2} ,
        {0, 0, 1, 0, 1, 1, 1, 2, 2, 0} ,
        {0, 1, 1, 1, 2, 0, 2, 1, 2, 2} ,
        {0, 0, 0, 1, 0, 2, 1, 1, 2, 1} ,
    },
    // L
    {
        {0, 0, 0, 1, 0, 2, 0, 3, 1, 3} ,
        {0, 0, 0, 1, 0, 2, 0, 3, 1, 0} ,
        {0, 1, 1, 1, 2, 1, 3, 0, 3, 1} ,
        {0, 0, 1, 0, 2, 0, 3, 0, 3, 1} ,
        {0, 0, 1, 0, 1, 1, 1, 2, 1, 3} ,
        {0, 3, 1, 0, 1, 1, 1, 2, 1, 3} ,
        {0, 0, 0, 1, 1, 0, 2, 0, 3, 0} ,
        {0, 0, 0, 1, 1, 1, 2, 1, 3, 1} ,
    },
    // X
    {
        {0, 1, 1, 0, 1, 1, 1, 2, 2, 1} ,
    },
    // I
    {
        {0, 0, 0, 1, 0, 2, 0, 3, 0, 4} ,
        {0, 0, 1, 0, 2, 0, 3, 0, 4, 0} ,
    },
    // W
    {
        {0, 2, 1, 1, 1, 2, 2, 0, 2, 1} ,
        {0, 0, 1, 0, 1, 1, 2, 1, 2, 2} ,
        {0, 1, 0, 2, 1, 0, 1, 1, 2, 0} ,
        {0, 0, 0, 1, 1, 1, 1, 2, 2, 2} ,
    },
};  
