import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;
import java.util.Random;

public class Layout implements Runnable {
  // Pentominos
  Piece[] usedPieces;
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
  
  // Algorithm
  int wiggleAdded = 0;
  boolean hasInitialized = false;
  
  class Piece {
    public byte x;
    public byte y;
    public byte i;
    public byte v;
    public byte c;
    
    public Piece(byte x, byte y, byte i, byte v, byte c) {
      this.x = x;
      this.y = y;
      this.i = i;
      this.v = v;
      this.c = c;
    }
    
    public boolean canBePlaced(int o_x, int o_y) {
      // Get the positions for each cell of the piece
      byte[] piece = pieces[i][v];
            
      // Return true only if all the positions of the array are empty
      for (byte c = 0; c < piece.length; c += 2) {
        int p_x = piece[c] + x + o_x;
        int p_y = piece[c + 1] + y + o_y;
        
        if (!(p_x > -1 && p_y > -1 && p_x < sizeX && p_y < sizeY && board[p_x][p_y] == 0)) {
          return false;
        }
      }
      
      return true;
    }
    
    public void place() {
      // Get the positions for each cell of the piece
      byte[] piece = pieces[i][v];
            
      // Return true only if all the positions of the array are empty
      for (byte p = 0; p < piece.length; p += 2) {
        int p_x = piece[p] + x;
        int p_y = piece[p + 1] + y;
        if (p_x < sizeX && p_y < sizeY) board[p_x][p_y] = c;
      } 
    }
    
    public void take() {
      // Get the positions for each cell of the piece
      byte[] piece = pieces[i][v];
            
      // Return true only if all the positions of the array are empty
      for (byte p = 0; p < piece.length; p += 2) {
        int p_x = piece[p] + x;
        int p_y = piece[p + 1] + y;
        if (p_x < sizeX && p_y < sizeY) board[p_x][p_y] = 0;
      } 
    }
    
    public boolean wiggle() {
      for (int i = 0; i < wiggleOffsets.length; i += 2) {
        int o_x = wiggleOffsets[i];
        int o_y = wiggleOffsets[i + 1];
        
        if (canBePlaced(o_x, o_y)) {
          x += o_x;
          y += o_y;
          return true;
        }
      }
      
      return false;
    }
    
    public boolean wiggleStep(int index) {
      index /= 2;
      int o_x = wiggleOffsets[index];
      int o_y = wiggleOffsets[index + 1];
      
      if (canBePlaced(o_x, o_y)) {
        take();       
        
        x += o_x;
        y += o_y;
        
        place();
        return true;
      }
      
      return false;
    }
    
    public boolean wiggleBackStep(int index) {
      index /= 2;
      int o_x = wiggleOffsets[index];
      int o_y = wiggleOffsets[index + 1];
      
      if (canBePlaced(o_x, o_y)) {
        take();       
        
        x -= o_x;
        y -= o_y;
        
        place();
        return true;
      }
      
      return false;
    }
  }  
    
  public Layout(int x, int y, int pieces, int targetScore) {
    sizeX = (byte)x;
    sizeY = (byte)y;
    pieceCount = pieces;
    
    usedPieces = new Piece[pieces];
    board = new byte[x][y];
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
    randomAlgorithm();
    
    for (int i = 0; i < 10; i++) {
      addWiggle();
    }
    
    
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
      usedPieces[i] = null;
    }
    
    pieceIndex = 1;
    floodIndex = 0;
  }
  
  // Find a good base, and wiggle the pieces around
  public void addWiggle() {
    int lastScore = score;
    
    wigglePieces(wiggleOffsets.length);
    wiggleAdded++;
    
    if (lastScore < score) {
      wiggleAdded = 0;
    }
    
    if (score >= bestScore) {     
      println("Best: " + score);
      LayoutData data = new LayoutData(board, depth, score);
      bestLayouts.add(data);
    }    
  }
  
  // Pure randomness, records: 7x7: 29, 8x8: 36, 14x14: 60
  public void randomAlgorithm() {
    clr();
    
    for (int i = 0; i < pieceCount; i++) {
      createRandomPiece();  
    } 

    score = calculateShortestPath(); 
    
    if (score > bestScore) {     
      println("Best: " + score);
      LayoutData data = new LayoutData(board, depth, score);
      bestLayouts.add(data);
    }
  }
  
  public void wigglePieces(int iterations) {
    byte[][] save = new byte[sizeX][sizeY];
    
    for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {    
        save[x][y] = board[x][y];
      }   
    }
    
    for (int i = 0; i < iterations; i++) {
      for (int p = 0; p < usedPieces.length; p++) {
        Piece piece = usedPieces[p];
        
        if (piece == null) {
          continue;
        }
        
        piece.wiggleStep(i);
        
        int newScore = calculateShortestPath();
        
        if (newScore > score) {
          return;
        }
        
        piece.wiggleBackStep(i);
      }
    }
  }
  
  public Piece createRandomPiece() {
    int x = random.nextInt(sizeX);
    int y = random.nextInt(sizeY);
    int i = random.nextInt(12);
    int v = random.nextInt(8);
    
    return forcePlace(x, y, i, v); 
  }
  
  Piece forcePlace(int p_x, int p_y, int p_i, int p_v) {
    Piece piece = tryPlace(p_x, p_y, p_i, p_v);
    

    if (piece.wiggle()) {
      piece.place();
      return piece;
    }
    
    return null;
  }
  
  // Tries to place any legal pentomino on 'p_x' 'p_y'
  Piece tryPlace(int p_x, int p_y, int p_i, int p_v) {
    
    // Loop through all the types
    for (byte l_i = 0; l_i < 12; l_i++) {
      byte i = byte((l_i + p_i) % 12);
      
      // If this type has been used, ignore
      if (hasBeenUsed(i)) {
        continue;
      }   
      
      byte v = byte(p_v % pieces[i].length);
      
      Piece piece = new Piece(byte(p_x), byte(p_y), i, v, pieceIndex);
      
      usedPieces[pieceIndex - 1] = piece;
      pieceIndex++;
  
      return piece;
    }
    
    return null;
  }
  
  // Checks if the pentomino 'i' has been used
  boolean hasBeenUsed(int i) {
    // Check if the index is in the used list
    for (int p = 0; p < usedPieces.length; p++) {
      if (usedPieces[p] != null && usedPieces[p].i == i) { 
        return true;
      }
    }
    
    return false;
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
    addNode(s_x, s_y, 0, 0);  
    Node deepestNode = null;
    
    // Modified dijkstra's algorithm
    while(floodNodes.size() > 0) {
      Node node = floodNodes.poll();
      
      int x = node.x;
      int y = node.y;
      int z = node.z;
      
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
    addNode(deepestNode.x, deepestNode.y, 0, 0);  
    deepestNode = floodNodes.peek();
     
    // Modified dijkstra's algorithm
    while(floodNodes.size() > 0) {
      Node node = floodNodes.poll();
      
      int x = node.x;
      int y = node.y;
      int z = node.z;
      
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
  void addNode(int x, int y, int z, int from) {
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
