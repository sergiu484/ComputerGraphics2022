class Stroke {
  ArrayList<PVector> strokePoints;
  float strokeWidth;
  color strokeColor;
  PImage texi,_texi;
  PVector start;

  Stroke(PVector pp, float pw, color pc, PImage ptexi) {
    strokeColor = pc;
    strokeWidth = pw;
    texi = ptexi;
    start = pp;
    iniTexture();
    strokePoints = new ArrayList<PVector>();
  }

  void addPoint(PVector pp) {
    strokePoints.add(pp);
  }

  void addPoint(float px, float py) {
    strokePoints.add(new PVector(px, py));
  }

  void setRadius(float pr) {
    strokeWidth = pr;
  }
  
  void setColor(color pcol) {
    strokeColor = pcol;
  }
  
  ArrayList<PVector> getPoints() {
    return strokePoints;
  }

  void draw() {

    if (strokePoints.size()<2) return;
    
    float len = getStrokeLength();
    float l=0,x=0,y=0;

    beginShape(QUAD_STRIP);
     texture(_texi); 
     normal(0,0,1); // only for lights
     for (int i = 0; i < strokePoints.size() - 1; ++i) {
       // TODO: Compute the vertices of the quad strip as shown in the lecture. 
       // keep track of the lenght of the stroke drawn so far to map the proper 
       // texture coordinates.  Use the function vertex(x, y, u, v) to create a
       // vertex for the current quad strip. The order in which you create
       // vertices is critical! If you get bowties instead of squares the order
       // is probably wrong.
       stroke(1);
       vertex(strokePoints.get(i).x, strokePoints.get(i).y-strokeWidth/2, _texi.width, 0);
       vertex(strokePoints.get(i+1).x, strokePoints.get(i+1).y-strokeWidth/2, _texi.width, _texi.height);
       vertex(strokePoints.get(i).x, strokePoints.get(i).y+strokeWidth/2, 0, 0);
       vertex(strokePoints.get(i+1).x, strokePoints.get(i+1).y+strokeWidth/2, 0, _texi.height);
       
     }
    endShape();
  }
  

  float getStrokeLength() {
    float len = 0;
    for (int i = 1;i<strokePoints.size(); i++) {
       PVector p  = strokePoints.get(i);
       PVector pp = strokePoints.get(i-1);
       len += sqrt(sq(pp.x-p.x)+sq(pp.y-p.y));
    }
    return len;
  }
  
  int getSize() {
    return strokePoints.size();
  }
  

  PVector getOffsetNormal(ArrayList<PVector> pointList, int index) {
    
    // TODO: For the point in plist at position index, compute the
    // offset normal as discussed in the lecture. Handle the following cases:
    // 1) Index is out of bounds
    // 2) First or last point in the point list
    // 3) Indicated point has neighbors
    
    return new PVector();
  }
    
 
  
  void iniTexture() {
    
    if (texi == null) {
        texi = createImage(10, 10, RGB);
        for (int i=0;i<texi.width*texi.height;i++) 
            texi.pixels[i]=color(0, 0, 0, 255);
    }
    
    // _texi has the color of the stroke color c
    // and brightness values (inverse) are mapped to alpha
    
    float cred = red(strokeColor);
    float cgreen = green(strokeColor);
    float cblue = blue(strokeColor);
    
    _texi = createImage(texi.width,texi.height,ARGB);
    for (int i=0;i<texi.width*texi.height;i++) {
      float a = 255-brightness(texi.pixels[i]); 
      _texi.pixels[i]=color(cred,cgreen,cblue,a);
    }
  }
  
 
  public String toString() {
      String s = "Line [";
        for (int i = 1;i<strokePoints.size(); i++) 
           s += strokePoints.get(i).toString();
      s += "] ";
      return s;
  }
  
  
  void movePerpendicuarToGradient(int steps, PImage inp) {
    strokePoints.add(start);
    PVector current = start;
    color col = inp.get(round(current.x), round(current.y));
     
    
    for (int i = 0; i < steps; ++i) {
      PVector next = tracePosition(inp, current);
      
      if(next.x == 0.0 && next.y == 0.0) {
        // nowhere to go? Go to a random place!
        next.x = current.x + random(strokeWidth / 2);
        next.y = current.y + random(strokeWidth / 2);
      }
   
   
      color actC = inp.get(round(next.x), round(next.y));
      
      // if color changes too much along the stroke
      if (sqrt(sq(red(col)-red(actC)) + sq(green(col)-green(actC)) + sq(blue(col)-blue(actC))) > 50) {
         break;
      }
      
      
      // TODO: 
      // a ----- b 
      //         /
      //        /
      //       c
      //
      // Calculate angle between the vectors b -> a and b -> (using a -> b would result in a blunt angle!)
      // a - b <- > c - b
      //
      // look at the previous, current and next point. If the angle is smaller than 45 degrees, then abort the stroke.
       //<>//
   
      current = next;
      strokePoints.add(next);
    }
  }
  

  PVector tracePosition(PImage inp, PVector pos) {
    int actX = round(pos.x);
    int actY = round(pos.y);
    int w = inp.width;
    
    actX = constrain(actX,1,inp.width-2);
    actY = constrain(actY,1,inp.height-2);
    
    // Gradient 
    float gx =   (brightness(inp.pixels[actX+1 + (actY-1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX+1 + (actY  )*w]) - brightness(inp.pixels[actX-1 + (actY  )*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY+1)*w]));

    float gy =   (brightness(inp.pixels[actX-1 + (actY+1)*w]) - brightness(inp.pixels[actX-1 + (actY-1)*w])) + 
               2*(brightness(inp.pixels[actX   + (actY+1)*w]) - brightness(inp.pixels[actX   + (actY-1)*w])) +
                 (brightness(inp.pixels[actX+1 + (actY+1)*w]) - brightness(inp.pixels[actX+1 + (actY-1)*w]));
                 
    // Normalize 
    float len = sqrt(sq(gx) + sq(gy));    
    if (len == 0) {
      return new PVector(0,0);
    }
    
    gx /= len;
    gy /= len;

   // find new postion
    float stepSize = strokeWidth / 2;
    float dx = -gy*stepSize;
    float dy =  gx*stepSize;
    return new PVector(actX+dx ,actY+dy);
 }
}
