class Stroke {
  ArrayList<PVector> pointList;
  float strokeWidth;
  color strokeColor;
  final int colorMaxDiff = 50;

  // Strokes cannot be default constructed (no arguments): A position is always present!
  Stroke(PVector pp, float pwid, color pcol) {
    strokeColor = pcol; 
    strokeWidth = pwid;
    pointList = new ArrayList<PVector>();
    pointList.add(pp);
  }

  void addPoint(PVector pp) {
    pointList.add(pp);
  }

  void addPoint(float px, float py) {
    pointList.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }

  void setColor(color pcol) {
    strokeColor = pcol;
  }


  void draw() {
    stroke(strokeColor);
    strokeWeight(strokeWidth);
    // TODO; Draw all points in pointList using the line() function of processing.
    // You should connect adjacent points with a line so you get a pattern like this:
    // o---o---o---o- ... -o
    // where each "o" is a control point and --- the line between them.
    for (int i = 1; i < pointList.size(); i++){
      line(pointList.get(i).x, pointList.get(i).y, pointList.get(i-1).x, pointList.get(i-1).y);
    }
  }

  void movePerpendicuarToGradient(int steps, PImage inp) {
    // TODO: call growStroke exactly step times in order to enlarge the stroke.
    // If growStroke returns (-1, -1), i.e. it has found no gradient, abort the stroke.
    // Keep track of the color at the start of the stroke and if the error exceeds 
    // colorMaxDiff, also abort the stroke.
    while(steps > 0){
      PVector pv = growStroke(inp);
      if (pv.x < 0 || pv.y < 0 || pv.x > inp.width - 1 || pv.y > inp.height - 1) break;
      steps--;
      color col = inp.pixels[(int)pv.x + (int)pv.y * inp.width];
      if (getColorDifference(col, strokeColor) > colorMaxDiff) break;
    }
    
  }
  
  float getColorDifference(color c1, color c2){
    float red_c1 = c1 >> 16 & 0xFF;
    float red_c2 = c2 >> 16 & 0xFF;
    float green_c1 = c1 >> 8 & 0xFF;
    float green_c2 = c2 >> 8 & 0xFF;
    float blue_c1 = c1 & 0xFF;
    float blue_c2 = c2 & 0xFF;
    return sqrt((red_c1 - red_c2) * (red_c1 - red_c2) + (green_c1 - green_c2) * (green_c1 - green_c2) + (blue_c1 - blue_c2) * (blue_c1 - blue_c2));
  }


  PVector growStroke(PImage inp) {
    // TODO: Extend te stroke by figuring out where the next point shall be located
    // 1) get the last point of this stroke
    // 2) Compute the local gradient at the curent location. Implement a sobel operator for this. You can use 
    //    brightness(inp.pixels[x + y * w]) to get the brightness easily at a point x, y.
    // 3) Move orthogonally to the gradient and movy by stepSize to a new position. Add this to the point list.
    // 4) Return the location you find or (-1, -1) if you have gradient of magnitude 0. 
    
    PVector lp = this.pointList.get(this.pointList.size() - 1);
    
    if (lp.x < 1 || lp.y < 1 || lp.x > inp.width - 2 || lp.y > inp.height - 2) return new PVector(-1, -1);

    PVector g = computeGradientDirection((int)lp.x, (int)lp.y, inp);   
    
    float gradient = sqrt(g.x * g.x + g.y * g.y);
    
    if (gradient > 0){
      PVector np = new PVector(lp.x + g.x, lp.y + g.y);
      pointList.add(np);
      return np;
    }
    else{
      return new PVector(-1,-1);
    }
  }
  
  PVector computeGradientDirection(int x, int y, PImage inp){
    int comp_x =(int) (brightness(inp.pixels[x + 1 + y * inp.width]) * 2 + 
                  brightness(inp.pixels[x - 1 + y * inp.width]) * (-2) +
                  brightness(inp.pixels[x - 1 + (y + 1) * inp.width]) * (-1) +
                  brightness(inp.pixels[x - 1 + (y - 1) * inp.width]) * (-1) +
                  brightness(inp.pixels[x + 1 + (y + 1) * inp.width]) +
                  brightness(inp.pixels[x + 1 + (y - 1) * inp.width]));
                  
    int comp_y =(int) (brightness(inp.pixels[x + (y - 1) * inp.width]) * 2 + 
                  brightness(inp.pixels[x + (y + 1) * inp.width]) * (-2) +
                  brightness(inp.pixels[x - 1 + (y + 1) * inp.width]) +
                  brightness(inp.pixels[x - 1 + (y - 1) * inp.width]) * (-1) +
                  brightness(inp.pixels[x + 1 + (y + 1) * inp.width]) * (-1) +
                  brightness(inp.pixels[x + 1 + (y - 1) * inp.width]));
    return new PVector(comp_x, comp_y);
  }
}
