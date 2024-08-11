import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;
import java.util.Random;
import java.util.concurrent.Callable;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class MinesweeperSolver implements Callable<Integer> { 
  byte[][] board;
  
  int usedPieces;
  int pieceCount;
 
  byte floodIndex = 0;
  byte pieceIndex = 0;
  int targetScore = 0;
  byte zero = 0;
  
  int startX;
  int startY;
  
  Node[][] nodes;
  Queue<Node> floodNodes = new LinkedList<Node>();
  
  byte[][] depth;
  byte[][] path;
  
  public MinesweeperSolver(int x, int y) {
    startX = x;
    startY = y;
    board = new byte[boardX][boardY];
    pieceCount = maxPieceCount;
    usedPieces = 0;
    
    for (int i = 0; i < boardX; i++) {
      board[i][0] = -1;
      board[i][boardY - 1] = -1;
    }
    
    for (int i = 1; i < boardY - 1; i++) {
      board[0][i] = -1;
      board[boardY - 1][i] = -1;
    }
    
    depth = new byte[boardX][boardY];

    path = new byte[boardX][boardY];
    nodes = new Node[boardX][boardY];
    for (byte p_x = 0; p_x < boardX; p_x++) {
      for (byte p_y = 0; p_y < boardY; p_y++) {
        nodes[p_x][p_y] = new Node(p_x, p_y);
      }
    }
  } 
  
  public Integer call() {
    for (int i = 0; i < pieceCount(); i++) {       
      for (int v = 0; v < pieceVariants(i); v++) {
        // Can be placed?  
        if (!canPlace(board, startX, startY, i, v)) continue;
        
        // Clone board
        byte[][] newBoard = new byte[boardX][boardY];
        for (int k = 0; k < board.length; k++) newBoard[k] = board[k].clone(); 
        
        // Place piece and evaluate new state
        place(newBoard, startX, startY, i, v);
        int newScore = evaluate(newBoard);
        int newUsedPieces = 0x01 << i;
        
        // If the score is lower, skip this, it's going to be bad
        if (newScore < 0) continue;       
        
        // Do recursion
        int bestBranchScore = recursiveMinesweeper(newBoard, newUsedPieces, newScore, 1);          
        if (bestBranchScore > score) score = bestBranchScore;
      }
    }
    
    return 0;
  }
    
  int recursiveMinesweeper(byte[][] board, int usedPieces, int score, int depth) { 
    if (depth >= pieceCount) {
      return score;
    }
    
    int bestLocalScore = score;
    
    for (int x = 0; x < boardX; x++) {
      for (int y = 0; y < boardY; y++) {     
        // If the coordinate is not placeable, skip
        if (board[x][y] != -1) continue;       
        
        for (int i = 0; i < pieceCount(); i++) {
          // If the piece has been used, skip
          if ((usedPieces >> i & 0x01) == 1) continue;
                    
          for (int v = 0; v < pieceVariants(i); v++) {
            // Can be placed?        
            if (!canPlace(board, x, y, i, v)) continue;
            
            // Clone board
            byte[][] newBoard = new byte[boardX][boardY];
            for (int k = 0; k < board.length; k++) newBoard[k] = board[k].clone();  
            
            // Place piece and evaluate new state
            place(newBoard, x, y, i, v);
            int newScore = evaluate(newBoard);
            int newUsedPieces = usedPieces | (0x01 << i);
            
            // If the score is lower, skip this, it's going to be bad
            if (newScore < score) continue;       
            
            // Do recursion
            int bestBranchScore = recursiveMinesweeper(newBoard, newUsedPieces, newScore, depth + 1);          
            if (bestBranchScore > bestLocalScore) bestLocalScore = bestBranchScore;
          }
        }
      }
    }
    
    return bestLocalScore;
  }
  
  // Checks if certain pentomino has been placed
  boolean hasBeenUsed(int i) {
    return (usedPieces >> i & 0x01) == 1;
  }    
  
  int evaluate(byte[][] other){
    board = other;
    int newScore = calculateShortestPath(); 
    
    Lock lock = new ReentrantLock();      
    lock.lock();
    
    try { 
      if (newScore > score) {     
        println("Best: " + score);
       
        LayoutData data = new LayoutData(board, depth, newScore);
        bestLayouts.add(data); 
        score = newScore;   
      }
    } finally { 
      lock.unlock(); 
    }    
  
    return score;
  }
  
  int calculateShortestPath() {
    // Keep track of the best depth
    int bestDepth = 0;
    floodIndex = 0;
    
    for (int x = 0; x < boardX; x++) {
      for (int y = 0; y < boardY; y++) { 
        path[x][y] = 0;
        depth[x][y] = 0;
      }   
    }
    
    // Flood every blank cell that has not been flooded
    // This results in a list of floods that are separate from each other and their furthest point, that will be used as the starting point
    for (int x = 0; x < boardX; x++) {
      for (int y = 0; y < boardY; y++) {      
        
        // If there is a piece or is already flooded, skip
        if (board[x][y] > 0 || path[x][y] != 0) {
          continue;
        }
        
        int dep = flood(x, y);
        
        if (bestDepth < dep) {
          bestDepth = dep;
          
          for (int i = 0; i < boardX; i++) {
            for (int k = 0; k < boardY; k++) {
              depth[i][k] = (byte)nodes[i][k].z;
            }
          }         
        }
      }
    }
    
    return bestDepth;
  }
  
  int flood(int s_x, int s_y) {    
    
    for (int x = 0; x < boardX; x++) {
      for (int y = 0; y < boardY; y++) {    
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
    for (int x = 0; x < boardX; x++) {
      for (int y = 0; y < boardY; y++) {    
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
    if (x < boardX && x > -1 && y < boardY && y > -1 && board[x][y] < 1) {
      Node newNode = nodes[x][y];
      
      if (newNode.eval) {
        return;
      }
      
      newNode.eval = true;
      newNode.setValues(byte(z + 1), byte(from));
      floodNodes.add(newNode);
    } 
  }  
}

static boolean canPlace(byte[][] board, int x, int y, int i, int v) {
    byte[] positions = getPiece(i, v);

    for (int p = 0; p < positions.length; p += 2) {
      int px = positions[p] + x;
      int py = positions[p + 1] + y;
      
      if (!(px > -1 && py > -1 && px < boardX && py < boardY && board[px][py] < 1)) return false;
    }
    
    return true;
  }
  
// Places a pentomino and it's bounds
static void place(byte[][] board, int x, int y, int i, int v) {
    byte[] positions = getPiece(i, v);
    
    board[x][y] = byte(i + 1);
    
    for (int p = 0; p < positions.length; p += 2) {
      int px = positions[p] + x;
      int py = positions[p + 1] + y;
      
      board[px][py] = byte(i + 1);
    }
    
    positions = getPieceBounds(i, v);
    
    for (int p = 0; p < positions.length; p += 2) {
      int px = positions[p] + x;
      int py = positions[p + 1] + y;
      
      if (px > -1 && py > -1 && px < boardX && py < boardY && board[px][py] == 0) {
        board[px][py] = -1;
      }
    }
  }
