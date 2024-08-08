// Tries to place any legal pentomino on 'p_x' 'p_y'
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

// Checks if the pentomino 'i' has been used
boolean hasBeenUsed(int i) {
  // Check if the index is in the used list
  for (int p = 0; p < used.size(); p++) {
    if (used.get(p) == i) { 
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
  
// Pentomino coordinates by hans314
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
