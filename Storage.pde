// Random functions mostly used to generate data, i might have to use them later, but right now they here
// It gets boring writing these over and over

// Stores and prints all the cells on the outline of the pieces
void dataPrinter() {
  byte[][][][] boundsCompleteArray = new byte[newPieces.length][][][];
  String print = "= {\n";
  
  for (int a = 0; a < newPieces.length; a++) {
    
    print += "  {\n";
    
    int bl = newPieces[a].length;
    boundsCompleteArray[a] = new byte[bl][][];
    for (int b = 0; b < bl; b++) {
      
      print += "    {\n";
      
      int cl = newPieces[a][b].length;
      boundsCompleteArray[a][b] = new byte[cl][];
      for (int c = 0; c < cl; c++) {
        
        byte[] bounds = printerHandlePiece(a, b, c);
        boundsCompleteArray[a][b][c] = bounds;
        
        print += "      {";
        for (int d = 0; d < bounds.length; d++) {
          print += bounds[d];
          if ((d + 1) < bounds.length) print += ", ";
        }
        
        print += "},\n";
      }
      
      print += "    },\n";
    }
    
    print += "  },\n";
  }
  
  print += "};";
  saveStrings("da frick", new String[] {print});
  println(print);
}

byte[] printerHandlePiece(int o, int i, int v) {
  byte[] piece = newPieces[o][i][v];
  ArrayList<Byte> bounds = new ArrayList<Byte>();
  
  for (int j = 0; j < piece.length; j += 2) {
    int x = piece[j];
    int y = piece[j + 1];
         
    offset: for (int b = 0; b < boundOffset.length; b += 2) {
      int bx = x + boundOffset[b];
      int by = y + boundOffset[b + 1];
  
      for (int k = 0; k < piece.length; k += 2) {
        if (bx == piece[k] && by == piece[k + 1]) continue offset;
      }
      
      for (int k = 0; k < bounds.size(); k += 3) {
        if (bx == bounds.get(k) && by == bounds.get(k + 1)) {
          bounds.set(k + 2, byte(bounds.get(k + 2) | (0x01 << b)));
          continue offset;
        }
      }
      
      bounds.add(byte(bx));
      bounds.add(byte(by));
      bounds.add(byte(0x01 << b));
    }
  }

  byte[] result = new byte[bounds.size()];
  for(int t = 0; t < bounds.size(); t++) result[t] = bounds.get(t).byteValue();
  return result;
}

/*
void generateOthersA() {
  byte[][][][] generated = new byte[newPieces.length][][][];
  
  for (int a = 0; a < newPieces.length; a++) {
    
    int bl = newPieces[a].length;
    generated[a] = new byte[bl][][];
    for (int b = 0; b < bl; b++) {
       
      int cl = newPieces[a][b].length;
      generated[a][b] = new byte[cl][];
      for (int c = 0; c < cl; c++) {
        
        int dl = newPieces[a][b][c].length;
        generated[a][b][c] = new byte[dl];
        for (int d = 0; d < dl; d += 2) {
          int x = newPieces[a][b][c][d];
          int y = newPieces[a][b][c][d + 1];
          
          generated[a][b][c][d] = byte(x);
          generated[a][b][c][d + 1] = byte(-y);
        }       
      }
    }   
  }
  
  printMegaArray(generated, "top");
}

void generateOthersB() {
  byte[][][][] generated = new byte[newPieces.length][][][];
  
  for (int a = 0; a < newPieces.length; a++) {
    
    int bl = newPieces[a].length;
    generated[a] = new byte[bl][][];
    for (int b = 0; b < bl; b++) {
       
      int cl = newPieces[a][b].length;
      generated[a][b] = new byte[cl][];
      for (int c = 0; c < cl; c++) {
        
        int dl = newPieces[a][b][c].length;
        generated[a][b][c] = new byte[dl];
        for (int d = 0; d < dl; d += 2) {
          int x = newPieces[a][b][c][d];
          int y = newPieces[a][b][c][d + 1];
          
          generated[a][b][c][d] = byte(y);
          generated[a][b][c][d + 1] = byte(x);
        }       
      }
    }   
  }
  
  printMegaArray(generated, "right");
}
void generateOthersC() {
  byte[][][][] generated = new byte[newPieces.length][][][];
  
  for (int a = 0; a < newPieces.length; a++) {
    
    int bl = newPieces[a].length;
    generated[a] = new byte[bl][][];
    for (int b = 0; b < bl; b++) {
       
      int cl = newPieces[a][b].length;
      generated[a][b] = new byte[cl][];
      for (int c = 0; c < cl; c++) {
        
        int dl = newPieces[a][b][c].length;
        generated[a][b][c] = new byte[dl];
        for (int d = 0; d < dl; d += 2) {
          int x = newPieces[a][b][c][d];
          int y = newPieces[a][b][c][d + 1];
          
          generated[a][b][c][d] = byte(-y);
          generated[a][b][c][d + 1] = byte(x);
        }       
      }
    }   
  }
  
  printMegaArray(generated, "left");
}


void printMegaArray(byte[][][][] array, String saveName) {
  String print = "= {\n";
  
  for (int a = 0; a < array.length; a++) {
    
    print += "  {\n";
    
    int bl = array[a].length;
    for (int b = 0; b < bl; b++) {
      
      print += "    {\n";
      
      int cl = array[a][b].length;
      for (int c = 0; c < cl; c++) {
        
        print += "      {";
        
        int dl = array[a][b][c].length;
        for (int d = 0; d < dl; d++) {
          print += array[a][b][c][d];
          if ((d + 1) < dl) print += ", ";
        }
        
        print += "},\n";
      }
      
      print += "    },\n";
    }
    
    print += "  },\n";
  }
  
  print += "};";
  saveStrings(saveName, new String[] {print});
  println(print);
}

void keyPressed() {
  int size = bestBoard[0].length;
  int cellSize = height / size;
  
  int mx = floor(mouseX / cellSize);
  int my = floor(mouseY / cellSize);
  
  if (key == 'q') {
    // THIS IS SO FUCKING STUPID
    building.add((Byte)byte(mx - 4));
    building.add((Byte)byte(my - 4));
  }
  
  if (key == 'w') {
    byte[] result = new byte[building.size()];
    for(int t = 0; t < building.size(); t++) result[t] = building.get(t).byteValue();
    buildingPieceRotations.add(result);
    
    building.clear();
  }
  
  if (key == 'e') {
    byte[][] rots = new byte[buildingPieceRotations.size()][];
    for(int t = 0; t < buildingPieceRotations.size(); t++) rots[t] = buildingPieceRotations.get(t);
    allPiecesBuilding.add(rots);
    
    buildingPieceRotations.clear();
  }
  
  if (key == 'r') {
    cX = mx;
    cY = my;
    
    byte[][][] all = new byte[allPiecesBuilding.size()][][];
    for(int t = 0; t < allPiecesBuilding.size(); t++) all[t] = allPiecesBuilding.get(t);    
    allOrientationsBuilding.add(all);
    
    allPiecesBuilding.clear();
  }
  
  if (key == 't') {
    byte[][][][] all = new byte[allOrientationsBuilding.size()][][][];
    for(int t = 0; t < allOrientationsBuilding.size(); t++) all[t] = allOrientationsBuilding.get(t);    
    printMegaArray(all);
  }
}

void printMegaArray(byte[][][][] array) {
  String print = "= {\n";
  
  for (int a = 0; a < array.length; a++) {
    
    print += "  {\n";
    
    int bl = array[a].length;
    for (int b = 0; b < bl; b++) {
      
      print += "    {\n";
      
      int cl = array[a][b].length;
      for (int c = 0; c < cl; c++) {
        
        print += "      {";
        
        int dl = array[a][b][c].length;
        for (int d = 0; d < dl; d++) {
          print += array[a][b][c][d];
          if ((d + 1) < dl) print += ", ";
        }
        
        print += "},\n";
      }
      
      print += "    },\n";
    }
    
    print += "  },\n";
  }
  
  print += "};";
  println(print);
}

int cX;
int cY;
ArrayList<byte[][][]> allOrientationsBuilding = new ArrayList<byte[][][]>();
ArrayList<byte[][]> allPiecesBuilding = new ArrayList<byte[][]>();
ArrayList<byte[]> buildingPieceRotations = new ArrayList<byte[]>();
ArrayList<Byte> building = new ArrayList<Byte>();
*/
