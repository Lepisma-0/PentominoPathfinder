import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;

public class Layout extends Thread {
  // Pentominos
  byte[] usedPieces;
  byte[] pieceSubIndex;
  byte[][] board;
  
  byte sizeX;
  byte sizeY;
 
  // Pathfinding
  Node[][] nodes;
  Queue<Node> floodNodes = new LinkedList<Node>();
  
  byte[][] path;
  byte floodIndex = 0;
  byte pieceIndex = 0;
  byte zero = 0;
  
  public Layout(int x, int y, int pieces) {
    board = new byte[x][y];
    usedPieces = new byte[pieces];
    pieceSubIndex = new byte[pieces];
    
    path = new byte[x][y];
    nodes = new Node[x][y];
    for (int p_x = 0; x < x; x++) {
      for (int p_y = 0; y < y; y++) {    
        nodes[p_x][p_y] = new Node(p_x, p_y);
      }   
    }
  }
  
  public void run() { 
    fast();
  }

  public void fast() {
    pieceIndex = 1;
  
    o: for (int x = 0; x < sizeX; x++) {
      for (int y = 0; y < sizeY; y++) {
        
        // Try place every single piece in this position, place the first one found
        tryPlace(x, y);
        
        if (pieceIndex > usedPieces.length) break o;
      }
    }
    
    calculateShortestPath();
  }
  
  // Tries to place any legal pentomino on 'p_x' 'p_y'
  void tryPlace(int p_x, int p_y) {
    
    // Loop through all the types
    for (byte i = 0; i < 12; i++) {
   
      // If this type has been used, ignore
      if (hasBeenUsed(i)) {
        continue;
      }   
      
      // Loop through all the variants
      int variants = pieces[i].length;
      for (byte v = 0; v < variants; v++) {
        
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
        usedPieces[pieceIndex - 1] = i;
        pieceSubIndex[pieceIndex - 1] = v;
        pieceIndex++;
        break;
      } 
    }
  }
  
  // Checks if the pentomino 'i' has been used
  boolean hasBeenUsed(int i) {
    // Check if the index is in the used list
    for (int p = 0; p < usedPieces.length; p++) {
      if (usedPieces[p] == i) { 
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
        
        // Run the flood alogrithm and store best depth
        bestDepth = max(bestDepth, flood(x, y));
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
      
      // Is in bounds
      if (x > -1 && y > -1 && x < sizeX && y < sizeY) {
        
        // If there is no piece, this hasn't been evaluated before, OR the depth is higher (means this is a shorter path)
        if (board[x][y] == 0 && (path[x][y] == 0 || nodes[x][y].z > z)) {
          if (showAnim) animation.add(node);
          
          // Set the depth and index of the flood
          path[x][y] = floodIndex;
          nodes[x][y].z = z;
          
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
      }
    }
    
    // If the flood was too small, discard it
    if (deepestNode == null || deepestNode.z < 5) {
      return 0;
    } 
    
    // SECOND FLOOD
    
    // Clear arrays  
    floodNodes.clear();
    addNode(deepestNode.x, deepestNode.y, 0, 0);  
    deepestNode = null;
    
    // Modified dijkstra's algorithm
    while(floodNodes.size() > 0) {
      Node node = floodNodes.poll();    
      int x = node.x;
      int y = node.y;
      int z = node.z;
      
      // Is in bounds
      if (x > -1 && y > -1 && x < sizeX && y < sizeY) {
        
        // If the path is from this flood, and the depth is zero (untouched) or higher (shorter path)
        if (path[x][y] == floodIndex && (nodes[x][y].z == 0 || nodes[x][y].z > z)) {
          if (showAnim) animation.add(node);
          
          nodes[x][y].z = z;
          
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
      }
    }
    
    // If the flood was too small, discard it
    if (deepestNode == null || deepestNode.z < 5) {
      return 0;
    } 
    
    return deepestNode.z;
  }
  
  // Adds a node and does some checks to test duplicates
  void addNode(int x, int y, int z, int from) {
    x = max(min(x, boardX - 1), 0);
    y = max(min(y, boardY - 1), 0);
    
    Node newNode = nodes[x][y];
    newNode.setValues(z + 1, from);
    
    Iterator<Node> it = floodNodes.iterator();
    while (it.hasNext()) {
      it.next().handle(newNode);
    }
    
    // Add node if nothing happens
    floodNodes.add(newNode);
  }
}
