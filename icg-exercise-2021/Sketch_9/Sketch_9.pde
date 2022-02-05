int iheight = 500;
float clow = 4;
float chigh = 14;

PImage input, output, depth, nmap, background;  

PImage selectChannel(PImage img, int no) {

  PImage res = createImage(img.width, img.height, RGB); 
  for (int y = 0; y < img.height; ++y) 
    for (int x = 0; x < img.width; ++x) {
        float r = red(img.pixels[x+y*img.width]);
        float g = green(img.pixels[x+y*img.width]);
        float b = blue(img.pixels[x+y*img.width]);
        switch (no) {
          case 0: res.pixels[x+y*img.width] = color(r);
                  break;
          case 1: res.pixels[x+y*img.width] = color(g);
                  break;
          case 2: res.pixels[x+y*img.width] = color(b);
                  break;
        }
  }  
  return res;
}

color quantizeColor(color c) {
  // TODO: Quantize the given color based on brightness. Use the alpha channel!
  // HINT: have four colors and map more colors to dark then bright.
  // HINT: Use most of your color space for black and grey, very little for white.
  return color(0,0,0,0);
}

PImage toonShade(PImage img, PImage depth, PImage nmap) {
  
  // TODO:
  // 1) Create a result image
  // 2) Quantize the input image to a temporary image
  // 3) Blend the temporary image onto the background using PImage.blend(...) with mode BLEND
  // 4) Generate an outline from the depth image and use PImage.filter(ERODE) to thicken it
  // 5) Determine the normal discontinuities as in the previous sketch and paint them onto the image.
  // 6) Paint the lines onto the blended image from step 3 by iterating over the image and checking
  //    for black pixels.

  PImage res = background.copy();
    
  return res; 
}

PImage createEdgesCanny(PImage img, float low, float high) {
  
  //create the detector CannyEdgeDetector 
  CannyEdgeDetector detector = new CannyEdgeDetector(); 

  //adjust its parameters as desired 
  detector.setLowThreshold(low); 
  detector.setHighThreshold(high); 

  //apply it to an image 
  detector.setSourceImage(img);
  detector.process(); 
  return detector.getEdgesImage();
}  

void setup() { 

  input = loadImage("dragon.png");
  depth = loadImage("dragon_depth.png");
  nmap = loadImage("dragon_normal.png");
  background = loadImage("background.png");
  
  input.resize(0,iheight);
  depth.resize(0,iheight);
  nmap.resize(0,iheight);

  size(500,500);
  surface.setResizable(true);
  surface.setSize(input.width, input.height);
  frameRate(3);

  output = toonShade(input,depth,nmap);  
}

void draw() {
  image(output, 0, 0); 
}

void keyPressed() {
  if (key=='1') output = input; // Debug, show input image
  if (key=='2') output = depth; // Debug, show depth
  if (key=='3') output = nmap;   // Debug, show normals 
  if (key=='4') output = createEdgesCanny(input,4,14); // Show edges of input image
  if (key=='5') output = createEdgesCanny(depth,4,14); // Show edges of depth image
  if (key=='6') output = toonShade(input,depth,nmap);  // Create the toon shaded output
  
  // Some keys to change the canny parameters
  if (key=='a') {
     chigh -= 0.2;
     output = toonShade(input,depth,nmap);
  }
  if (key=='s') {
     chigh += 0.2;
     output = toonShade(input,depth,nmap);
  }
  if (key=='q') {
     clow -= 0.1;
     output = toonShade(input,depth,nmap);
  }
  if (key=='w') {
     clow += 0.1;
     output = toonShade(input,depth,nmap);
  }
  if (key=='x') {
     save("toon.png");
  }
  println("Low: " + clow + " High: " + chigh); 
}
