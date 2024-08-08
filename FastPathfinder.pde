import java.util.Iterator; 
import java.util.LinkedList; 
import java.util.Queue;

// This represents the end of the path, the value will remain even after the calculations are done
Node deepestNode = null;

// Path and depth
Node[][] boardNodes = new Node[8][8];
byte[][] path = new byte[8][8];
int[][] depth = new int[8][8];

// The list of nodes on a flood
Queue<Node> floodNodes = new LinkedList<Node>();

// Flood index
byte floodIndex = 0;

class Node {
  public int x;
  public int y;
  public int z;
  public int from;
  
  public Node(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public void setValues(int z, int from) {
    this.z = z;
    this.from = from;
  }
  
  public boolean handle(Node other) {
    if (x == other.x && y == other.y) {
      if (z > other.z) {
        z = other.z;
        depth[x][y] = z;
      }
      return true;
    }
    
    return false;
  }
}

void createNodes() {
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {    
      boardNodes[x][y] = new Node(x, y);
    }   
  }
}

void flood(int x, int y) {  
  path = new byte[boardX][boardY];
  
  // Clear arrays
  floodNodes = new LinkedList<Node>();
  depth = new int[boardX][boardY];
  floodIndex++;
  
  // Create first node
  addNode(x, y, 0, 0);  
  
  // Dijkstra's algorithm
  while(floodNodes.size() > 0) {
    Node node = floodNodes.poll();
    floodNode(node);
  }
  
  // If the flood was too small, discard it
  if (deepestNode.z < 5) {
    return;
  } 
  
  // SECOND FLOOD
  
  // Clear arrays
  floodNodes = new LinkedList<Node>();
  depth = new int[boardX][boardY];
  
  // Create first node
  addNode(deepestNode.x, deepestNode.y, 0, 0);  
  
  // Dijkstra's algorithm
  while(floodNodes.size() > 0) {
    Node node = floodNodes.poll();    
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

// Adds a node and does some checks to test duplicates
void addNode(int x, int y, int z, int from) {
  x = max(min(x, boardX - 1), 0);
  y = max(min(y, boardY - 1), 0);
  
  Node newNode = boardNodes[x][y];
  newNode.setValues(z + 1, from);
  
  Iterator<Node> it = floodNodes.iterator();
  while (it.hasNext()) {
    it.next().handle(newNode);
  }
  
  // Add node if nothing happens
  floodNodes.add(newNode);
}
