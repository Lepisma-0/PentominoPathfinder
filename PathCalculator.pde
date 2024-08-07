// This represents the end of the path, the value will remain even after the calculations are done
Node deepestNode = null;

// Path and depth
byte[][] path = new byte[8][8];
int[][] depth = new int[8][8];

// The starting position of every flood pass
ArrayList<PVector> floods = new ArrayList<PVector>();

// The list of nodes on a flood
ArrayList<Node> floodNodes = new ArrayList<Node>();

// Flood index
byte floodIndex = 0;

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
