int iheight = 500;

boolean variableOutput = true;

PImage inp, outp, depth, nmap; 

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
  
  // TODO: Get the NV Image here, then the contour image. Blend the contour image onto
  // the input image and save it. We don't use the draw() function since the computation
  // of suggestive contours is quite slow. You can tune the parameters radius, D and S as 
  // you see fit. A good spot fo the dragon image is radius = 10, D = 0.5 and S = 0.12.
  
  PImage nvImg = computeNVImage(nmap);
  println("Got NV Image");
  PImage contourImage = computeSuggestiveContours(nvImg, 5, 0.5, 0.12);
  println("Got contour Image");
  image(contourImage, 0, 0);
  fill(#FF0000);
  stroke(#00FF00);
  rect(10, 10, 20, 20);
  nvImg.save("nv.png");
  contourImage.save("Contours.png");
  
  inp.blend(contourImage, 0, 0, contourImage.width, contourImage.height, 0, 0, inp.width, inp.height, BLEND);
  inp.save("result.png");
  
  exit();
}
 //<>//

PVector rgbToNormal(color c) {
  PVector v = new PVector(127f-red(c), 127f-green(c), blue(c)-127f);
  v.normalize();
  return v;
}


PImage computeNVImage(PImage img) {
  // TODO: Compute the NV Image like in the last sketch, but do not do any thresholding.
  // In each pixel compute n.dot(v) with n being the normal and v the view vector 
  // (0, 0, 1). Write the result as a greyscale value to an image and return it.
  
  PImage res = createImage(img.width, img.height, RGB);
  PVector viewVector = new PVector(0, 0, 1);
  
  for (int y = 0; y < img.height; ++y) 
    for (int x = 0; x < img.width; ++x) {
      PVector normal = rgbToNormal(img.pixels[x + y * img.width]);
      res.pixels[x + y * res.width] = color(normal.dot(viewVector));
    }
 
  return res;
}

PImage computeSuggestiveContours(PImage nvImage, int radius, float D, float S) {
  // TODO: Here, you need to create an image with suggestive contours which can then blend over
  // the input image. As we figures out the hard way last time, this image needs an alpha
  // channel, hence we create it as ARGB. Note however, that when you use color() to set
  // a pixel to a certain color, the channels are color(R, G, B, A) (because consistency)
  // or color(grey, alpha). 
  //
  // The goal is to scan the NV image with a circle to determine if a certain location is
  // a ridge in the NV field. We approximate this by checking the ratio of dark pixels to
  // the total amount of pixels in the circle. So
  // 
  // 1) Iterate the image, so you can access a position (x,y). Stay radius pixels away from
  //    the border of the image.
  // 2) Store the brightness of the current pixel at (x,y).
  // 3) Now look at a circle with the given radius around (x,y) by iterating over the pixels
  //    in a square around (x,y). Then you can use PVector.dist() to see which pixels to skip
  //    (when the pixel is in the square but more than radius away from (x,y).
  // 4) Count the amount of pixels in the circle as totalPixels and all black pixels as blackPixels.
  // 5) Count how many pixels in the circle are darker then (x,y) into darkerPixels.
  // 6) Keep track of the maximum intensity of all the pixels you see.
  // 7) Finally: If maxIntensity - (float) centerBrightness > D and 
  //    (darkerPixels / float(totalPixels)) < S, then set the result pixel to solid black,
  //    otherwise keep it transparent. However, if half of the pixels you saw were black, then 
  //    keep the result pixel transparent. This avoids filling in large flat areas.
  
  PImage res = createImage(nvImage.width, nvImage.height, ARGB);
  nvImage.loadPixels();
  
  for (int y = radius; y < nvImage.height - radius; ++y) 
    for (int x = radius; x < nvImage.width - radius; ++x) {
      float brightness = brightness(nvImage.pixels[x + y * nvImage.width]);
      int totalPixels = 0;
      int blackPixels = 0;
      int darkerPixels = 0;
      float maxIntensity = 0;
      for (int i = -radius; i < radius; i++)
        for (int j = -radius; j < radius; j++){ 
          //calculate distance
          float distance = new PVector(x, y).dist(new PVector(x + i, y + j));
          if (distance <= radius && i + j != 0){
            totalPixels++;
            if (nvImage.pixels[x + i + (y + j) * nvImage.width] == 0) blackPixels++;
            if (nvImage.pixels[x + y * nvImage.width] >= nvImage.pixels[x + i + (y + j) * nvImage.width]) darkerPixels++;
            if (maxIntensity < brightness(nvImage.pixels[x + i + (y + j) * nvImage.width])) maxIntensity = brightness(nvImage.pixels[x + i + (y + j) * nvImage.width]);
          }
      }
      if (maxIntensity - brightness > D && darkerPixels / totalPixels < S && blackPixels < totalPixels / 2){
        res.pixels[x + y * res.width] = color(0, 0, 0, 255);
      }
    }
  updatePixels();
  return res;
}
