// This script is for testing bruteforce tactics
// Right now, it contains a system that for simplicity, the idea is """similar""" to qbits and quantum stuff
//
//

QbitCell[][] cells;


void calculateQuantumData() {
  cells = new QbitCell[boardX][boardY];
  b_QbitCell[][] b_cells = new b_QbitCell[boardX][boardY];
  
  // Create cells
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {    
      cells[x][y] = new QbitCell();
      b_cells[x][y] = new b_QbitCell();
    }   
  }
  
  // Create qbits
  // Loop through board
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {
      // The arrays with all this piece's qbits
      ArrayList<b_Qbit> b_qBitList = new ArrayList<b_Qbit>();
      ArrayList<Qbit> qBitList = new ArrayList<Qbit>();     
      
      // Loop through all pieces
      for (int i = 0; i < 12; i++) {  
        for (int v = 0; v < pieces[i].length; v++) { 
         
          // Loop through all the piece's positions
          byte[] piece = pieces[i][v];
          for (int c = 0; c < piece.length; c += 2) {
            int p_x = piece[c] + x;
            int p_y = piece[c + 1] + y;     
            
            // Create a qbit for this piece and position
            if (p_x < boardX && p_y < boardY) {          
              b_Qbit b_qBit = new b_Qbit();
              Qbit qBit = new Qbit();
              qBitList.add(qBit);
              
              b_qBit.piece = i;
              b_qBit.variation = v;         
              b_qBitList.add(b_qBit);
              b_qBit.cellsPresent.add(cells[p_x][p_y]);         
              
              b_cells[p_x][p_y].qBits.add(qBit);
            }
          }
          
          
        }     
      } 
      
      Qbit[] qBitArr = new Qbit[b_qBitList.size()];

      // Link all the qBits together
      for (int i = 0; i < b_qBitList.size(); i++) {
        b_Qbit qBit = b_qBitList.get(i);
        for (int j = 0; j < b_qBitList.size(); j++) {
          b_Qbit other = b_qBitList.get(j);
          
          if (other != qBit) {
            qBit.linkedQbits.add(qBitList.get(i));
          }
        }
        
        qBitArr[i] = qBitList.get(i);
        qBit.build(qBitArr[i]);
      }
    }
  }
  
  // Build all the cells
  for (int x = 0; x < boardX; x++) {
    for (int y = 0; y < boardY; y++) {    
      b_cells[x][y].build(cells[x][y]);
    }   
  }
}

class QbitCell {
  public Qbit[] qBits;
  
  // Disables all the active cells
  public void use(boolean state) {
    for (int i = 0; i < qBits.length; i++) {
      qBits[i].blockedCells += state ? 1 : -1;
    }
  }
  
  public void load(Qbit[] qBits) {
    this.qBits = qBits;
  }
}

class Qbit {
  public int piece;
  public int variation;
  
  public byte blockedCells;
  public byte blockedQbits;
  
  public QbitCell[] cellsPresent;
  public Qbit[] linkedQbits;
  
  public void load(QbitCell[] cellsPresent, Qbit[] linkedQbits, int piece, int variation) {
    blockedCells = 0;
    blockedQbits = 0;
    
    this.piece = piece;
    this.variation = variation;
    this.cellsPresent = cellsPresent;
    this.linkedQbits = linkedQbits;
  }
  
  public void use(boolean state) {
    for (int i = 0; i < cellsPresent.length; i++) {
      cellsPresent[i].use(state);
    }
    
    for (int i = 0; i < linkedQbits.length; i++) {
      linkedQbits[i].blockedQbits += state ? 1 : -1;
    }
  }
  
  public boolean canBeUsed() {
    return (blockedCells + blockedQbits) == 0;
  }
}

// Classes for building (b_) the arrays on the final more optimized classes
class b_QbitCell {
  public ArrayList<Qbit> qBits = new ArrayList<Qbit>();
  
  public void build(QbitCell qBitCell) {
    Qbit[] qBitsArr = new Qbit[qBits.size()];
    qBitCell.load(qBits.toArray(qBitsArr));
  }
}

class b_Qbit {
  public int piece;
  public int variation;
  
  public ArrayList<Qbit> linkedQbits = new ArrayList<Qbit>();
  public ArrayList<QbitCell> cellsPresent = new ArrayList<QbitCell>();
  
  public void build(Qbit qBit) {
    Qbit[] linkedQbitArr = new Qbit[linkedQbits.size()];
    QbitCell[] cellsPresentArr = new QbitCell[cellsPresent.size()];
    
    qBit.load(cellsPresent.toArray(cellsPresentArr), linkedQbits.toArray(linkedQbitArr), piece, variation);
  }
}
