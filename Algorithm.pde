import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;
import java.util.Random;

public class Layout implements Runnable {
  // Pentominos
  int[] usedPieces;
  int[] pieceSubIndex;
  byte sizeX;
  byte sizeY;
 
  // Pathfinding
  Node[][] nodes;
  Queue<Node> floodNodes = new LinkedList<Node>();
  
  byte[][] path;
  byte floodIndex = 0;
  byte pieceIndex = 0;
  int targetScore = 0;
  byte zero = 0;
  
  int pieceCount;
  Random random;
  
  // Layout
  public byte[][] board;
  public byte[][] depth;
  public int score = 0;
  
  public Layout(int x, int y, int pieces, int targetScore) {
    sizeX = (byte)x;
    sizeY = (byte)y;
    pieceCount = pieces;
    
    board = new byte[x][y];
    usedPieces = new int[pieces];
    pieceSubIndex = new int[pieces];
    depth = new byte[x][y];
    this.targetScore = targetScore;
    
    path = new byte[x][y];
    nodes = new Node[x][y];
    for (byte p_x = 0; p_x < x; p_x++) {
      for (byte p_y = 0; p_y < y; p_y++) {    
        nodes[p_x][p_y] = new Node(p_x, p_y);
      }   
    }
    
    random = new Random();
  }

  public void run() {
    clr();
    randomAlgorithm();
  }
  
  public void clr() {
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) { 
        path[x][y] = 0;
        depth[x][y] = 0;
        board[x][y] = 0;
      }   
    }
    
    for (int i = 0; i < usedPieces.length; i++) {
      usedPieces[i] = 0;
      pieceSubIndex[i] = 0;
    }
    
    pieceIndex = 0;
    floodIndex = 0;
  }
  
  /*
  public void draw() {
    int size = board[0].length;
    int cellSize = height / size;
    
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {
        if (board[x][y] == 0) {
          continue;
        }
        
        colorMode(HSB, 255);
        fill(board[x][y] * cc1, 128, 128);
        rect(x * cellSize, y * cellSize, cellSize, cellSize);
      }
    }
    
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {
        if (depth[x][y] == 0) {
          continue;
        }     
        
        colorMode(RGB, 255);
        fill(depth[x][y] * cc2, depth[x][y] * cc2, depth[x][y] * cc2);
        rect(x * cellSize, y * cellSize, cellSize, cellSize);
      }
    }
    
    if (showAnim) {
      if (frameCount % 10 == 0) {
        animIndex = (animIndex + 1) % animation.size();
      }
      
      Node node = animation.get(animIndex);
      colorMode(RGB, 255);
      fill(255);
      rect(node.x * cellSize + 5, node.y * cellSize + 5, cellSize - 10, cellSize - 10);
    }
  }
  */
  
  public void randomAlgorithm() {
    pieceIndex = 1;
    
    for (int i = 0; i < pieceCount; i++) {
      createPiece();  
    } 

    score = calculateShortestPath(); 
    
    if (score > bestScore) {     
      println("Best: " + score);
      LayoutData data = new LayoutData(board, depth, score);
      bestLayouts.add(data);
    }
  }
  
  public void createPiece() {
    int x = random.nextInt(sizeX);
    int y = random.nextInt(sizeY);
    int i = random.nextInt(12);
    int v = random.nextInt(8);
    
    tryPlace(x, y, i, v); 
  }
  
  /*
  public void handlePiece(int i, int v) {
    
    
    //byte[] piece = pieces[i][v];
  }  
  */
  
  // Tries to place any legal pentomino on 'p_x' 'p_y'
  void tryPlace(int p_x, int p_y, int p_i, int p_v) {
    
    // Loop through all the types
    for (byte l_i = 0; l_i < 12; l_i++) {
      byte i = byte((l_i + p_i) % 12);
      
      // If this type has been used, ignore
      if (hasBeenUsed(i)) {
        continue;
      }   
      
      // Loop through all the variants
      int variants = pieces[i].length;
      for (byte l_v = 0; l_v < variants; l_v++) {
        byte v = byte((l_v + p_v) % variants);
        
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
        usedPieces[pieceIndex - 1] = i + 1;
        pieceSubIndex[pieceIndex - 1] = v + 1;
        pieceIndex++;
        break;
      } 
    }
  }
  
  // Checks if the pentomino 'i' has been used
  boolean hasBeenUsed(int i) {
    // Check if the index is in the used list
    for (int p = 0; p < usedPieces.length; p++) {
      if ((usedPieces[p] - 1) == i) { 
        return true;
      }
    }
    
    return false;
  }
  
  // Checks if the 'i' 'v' pentomino can be placed in 'p_x' 'p_v'
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
  
  int calculateShortestPath() {
    // Keep track of the best depth
    int bestDepth = 0;
    floodIndex = 0;
    
    // Flood every blank cell that has not been flooded
    // This results in a list of floods that are separate from each other and their furthest point, that will be used as the starting point
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {      
        
        // If there is a piece or is already flooded, skip
        if (board[x][y] != 0 || path[x][y] != 0) {
          continue;
        }
        
        int dep = flood(x, y);
        
        if (bestDepth < dep) {
          bestDepth = dep;
          
          for (int i = 0; i < sizeX; i++) {
            for (int k = 0; k < sizeY; k++) {
              depth[i][k] = (byte)nodes[i][k].z;
            }
          }
          
        }
      }
    }
    
    return bestDepth;
  }
  
  int flood(int s_x, int s_y) {    
    
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {    
        nodes[x][y].empty();
      }   
    }
    
    floodIndex++;
    floodNodes.clear();
    
    // Create first node
    addNode(s_x, s_y, zero, 0);  
    Node deepestNode = null;
    
    // Modified dijkstra's algorithm
    while(floodNodes.size() > 0) {
      Node node = floodNodes.poll();
      
      int x = node.x;
      int y = node.y;
      byte z = node.z;
      
      //if (showAnim) animation.add(node);
      path[x][y] = floodIndex;
    
      // Flood neighbours
      if (node.from != 2) addNode(x + 1, y, z, 1);
      if (node.from != 1) addNode(x - 1, y, z, 2);
      if (node.from != 4) addNode(x, y + 1, z, 3);
      if (node.from != 3) addNode(x, y - 1, z, 4);
      
      // If this is the deepest node, store the position
      if (deepestNode == null || z > deepestNode.z) {
        deepestNode = node;
      }
    }
    
    // If the flood was too small, discard it
    if (deepestNode == null || deepestNode.z < 5) {
      return 0;
    } 
    
    // SECOND FLOOD
    
    // Clear arrays
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {    
        nodes[x][y].empty();    
      }   
    }
    
    floodNodes.clear();
    addNode(deepestNode.x, deepestNode.y, zero, 0);  
    deepestNode = floodNodes.peek();
     
    // Modified dijkstra's algorithm
    while(floodNodes.size() > 0) {
      Node node = floodNodes.poll();
      
      int x = node.x;
      int y = node.y;
      byte z = node.z;
      
      //if (showAnim) animation.add(node);
      
      // Flood neighbours
      if (node.from != 2) addNode(x + 1, y, z, 1);
      if (node.from != 1) addNode(x - 1, y, z, 2);
      if (node.from != 4) addNode(x, y + 1, z, 3);
      if (node.from != 3) addNode(x, y - 1, z, 4);
      
      // If this is the deepest node, store the position
      if (deepestNode == null || z > deepestNode.z) {
        deepestNode = node;
      }
    }
    
    // If the flood was too small, discard it
    if (deepestNode == null || deepestNode.z < 4) {
      return 0;
    } 
    
    return deepestNode.z;
  }

  // Adds a node and does some checks to test duplicates
  void addNode(int x, int y, byte z, int from) {
    if (x < sizeX && x > -1 && y < sizeY && y > -1 && board[x][y] == 0) {
      Node newNode = nodes[x][y];
      
      if (newNode.eval) {
        return;
      }
      
      newNode.eval = true;
      newNode.setValues(byte(z + 1), byte(from));
      floodNodes.add(newNode);
    }
   
    /* 
    Iterator<Node> it = floodNodes.iterator();
    while (it.hasNext()) {
      it.next().handle(newNode);
    }
    */
    // Add node if nothing happens
  
  }
}
