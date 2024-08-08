
void solve() {
  // Clear all the arrays
  pieceIndex = 1;
  board = new byte[boardX][boardY];
  path = new byte[boardX][boardY];
  used = new ArrayList<Byte>();
  
  // The max amount of pentominos, the lower, the faster it goes but more things it misses
  int hardPieceLimit = 4;
     
  /*
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {
      Qbit qBit = cells[x][y].getActiveQbit(0);
      
      if (qBit != null) {
        qBit.use(true);
        pieceIndex++;
      }
      
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
  */
  /*
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
  */
  
  calculateShortestPath();
}
