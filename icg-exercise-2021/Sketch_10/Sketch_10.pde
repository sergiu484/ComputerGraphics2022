int iheight = 500;

boolean variableOutput = true;

PImage inp, outp, depth, nmap, contourImg; 

void setup() { 
  
  inp = loadImage(sketchPath("data/dragon.png"));
  depth = loadImage(sketchPath("data/dragon_depth.png"));
  nmap = loadImage(sketchPath("data/dragon_normals.png"));

  inp.resize(0, iheight); // proportional scale to height=500
  depth.resize(0, iheight); // proportional scale to height=500
  nmap.resize(0, iheight); // proportional scale to height=500

  size(10,10);
  surface.setResizable(true);
  surface.setSize(inp.width, inp.height);
  frameRate(3);
}

void draw() {
  contourImg = computeContourLines(nmap);
  image(contourImg, 0, 0);
}

void mouseMoved(){
  draw();
}
 //<>//

PVector rgbToNormal(color c) {
  // TODO: Extract the normal vector from the given color by mapping
  // RGB to XYZ components of the vector. Since the normal can point
  // into a negative direction but color components are only in 
  // [0; 255], you should subtract from 127.
  // Normalize the vector too.
  //return new PVector((127 - red(c)) / 255, (127 - green(c)) / 255, (127 - blue(c)) / 255).normalize();
  return new PVector(170 - red(c), 170 - green(c), 170 - blue(c)).normalize();
}


PImage computeContourLines(PImage img) {
  // TODO: Create a new image, and set up a view vecor (0, 0, 1). compute epison from the 
  // mouse position in the window, using mouseX and width. Remember that these are 
  // integers and division should yield a float! Then iterate the entire image and extract
  // the normal in each pixel. Compute the dot product with the view vector and compare
  // it to epsilon. Set the output color to white or black, depending on the result.   
  PImage res = createImage(img.width, img.height, RGB);
  
  PVector viewVector = new PVector(0, 0, 1);
  float epsilon = (float) mouseX / img.width;
  
  for (int y = 0; y < img.height; ++y) 
    for (int x = 0; x < img.width; ++x) {
      PVector pointNormal = rgbToNormal(img.pixels[x + y * img.width]);
      if (viewVector.dot(pointNormal) >= epsilon)
        res.pixels[x + y * res.width] = color(0, 0, 0);
      else
        res.pixels[x + y * res.width] = color(255, 255, 255);
    }
 
  return res;
}
