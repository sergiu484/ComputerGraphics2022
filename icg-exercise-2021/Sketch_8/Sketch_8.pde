float [][] sourceArray, outputArray;
int inputHeight = 500; // What we rescale loaded images to
float clow = 2; // parameters for CannyEdge detection
float chigh = 6;
float sigma = 15;

PImage inputImage, outputImage, depthImage, normalMapImage;
boolean colorMapping = true;

float[][] differenceImage;

/*
* Extract the selected color channel (1 = red, 2 = green, 3 = blue) from the given image.
*/
PImage selectChannel(PImage img, int channelNumber) {

  PImage res = createImage(img.width, img.height, RGB);
  img.loadPixels();

  for (int y = 0; y < img.height; ++y){ 
    for (int x = 0; x < img.width; ++x) {
      float r = red(img.pixels[x+y*img.width]);
      float g = green(img.pixels[x+y*img.width]);
      float b = blue(img.pixels[x+y*img.width]);
      switch (channelNumber) {
      case 0: 
        res.pixels[x+y*img.width] = color(r, r, r);
        break;
      case 1: 
        res.pixels[x+y*img.width] = color(g, g, g);
        break;
      case 2: 
        res.pixels[x+y*img.width] = color(b, b, b);
        break;
      }
    }
  }
  res.updatePixels();

  return res;
}

/*
* Given a depth image, return a new image with all spots where the depth value is equal
* to the target depth. The depth value in the depth image is coded as the pixel brightness.
* Found locations are marked in red.
*/
PImage markDepth(PImage depth, int targetDepth) {

  // TODO: Create a new image with the same size as depth. Then iterate depth and check the
  // brightness. If it matches the targetDepth, mark it red, otherwise put a black pixel.
  // HINT: remember PImage.loadPixels() and PImage.updatePixels().
  
  PImage computedImage = new PImage();
  computedImage.height = depth.height;
  computedImage.width = depth.width;
  
  depth.loadPixels();
  computedImage.loadPixels();
  
  for (int y = 0;y < depth.height; ++y) {
    for (int x = 0; x < depth.width; ++x) { 
      if (targetDepth == (int) brightness(depth.pixels[x+y*depth.width])){
        computedImage.pixels[x + y * depth.width] = color(255, 0, 0);
      }
      else{
        computedImage.pixels[x + y * depth.width] = 1;
      }
    }
  }
   computedImage.updatePixels();
  
  return computedImage;
}

/*
* Maps the given original color to an orange/blue hue. 
*/
color colorMap(color originalColor, float thresholdBrightness)
{
  // TODO: Coompare the brightness of the original color to the given threshold brightness.
  // If it's smaller, return an orange-ish hue by adding the threshold to the red and green channel.
  // Otherwise, subtract from the green and blue channel.
  if (brightness(originalColor) < thresholdBrightness)
     //return color(red(originalColor) + thresholdBrightness, green(originalColor) + thresholdBrightness, blue(originalColor));
    return color(red(originalColor), green(originalColor) - thresholdBrightness, blue(originalColor) - thresholdBrightness);
  else return color(red(originalColor) + thresholdBrightness, green(originalColor) + thresholdBrightness, blue(originalColor));
}

/*
* Returns the difference of an image with its blurred version
*/
float[][] createBlurDiff(PImage depthImage)
{
  // TODO: Copy the depth image, and filter it using the BLUR filter with sigma as a parameter.
  // Then compute the difference between the depth image and the blurred depth image in each pixel.
  // Do not do a channel-wise difference bust subtract brightnesses. Write the result to a new
  // float[][] array of appropriate size and return it.
  float[][] resultDifference = new float[depthImage.width][depthImage.height];
  PImage copyImage = depthImage.copy();
  
  depthImage.loadPixels();
  
  copyImage.filter(BLUR, sigma);
  copyImage.loadPixels();
  
  for (int y = 0;y < depthImage.height; ++y) {
    for (int x = 0; x < depthImage.width; ++x) {
      resultDifference[x][y] = brightness(copyImage.pixels[x + y * depthImage.width]) - brightness(depthImage.pixels[x + y * depthImage.width]);
    }
  }
  
  return resultDifference;
}

/*
* Expects a difference image out of createBlurDiff and the original image
*/
PImage unsharpMask(float[][] blurredDiff, PImage originalImage, PImage depthImage) {
  // TODO: Create an empty resultImage with the same size as the depthImage.
  // Iterate the original image and modulate the color from the original image using colorMap()
  // if the flag colorMapping is true. Otherwise, subtract the difference from each channel and
  // write the result back to the image for a grey shadow effect.
  PImage resultImage = createImage(depthImage.width, depthImage.height, RGB);
  
  float threshold = 10;

  for (int y = 0;y < originalImage.height; ++y) {
    for (int x = 0; x < originalImage.width; ++x) {
     if(colorMapping){
       resultImage.pixels[x + y * resultImage.width] = colorMap(originalImage.pixels[x + y * originalImage.width], threshold);
     }
     else{
       resultImage.pixels[x + y * resultImage.width] = depthImage.pixels[x + y * depthImage.width] - (int) blurredDiff[x][y];
       resultImage.pixels[x + y * resultImage.width] = originalImage.pixels[x + y * originalImage.width] - (int) blurredDiff[x][y];
     }
    }
  }
  resultImage.updatePixels();

  return resultImage;
}

/*
*
*/
PImage markDiscontinuities(PImage img, PImage depth, PImage nmap) {
  
  // TODO: In this function you shall determine discontinuities in the normal and
  // depth images. 
  // 1) Use canny edge detection on the depth image with the parameters clow and chigh
  // 2) Use selectChannel on the normal map to extract the red, green and blue channel separately.
  // 3) Detect edges in the individual channel images of the previous step to find discontinuities
  // 4) Create an empty result image with the same size as the input and iterate it:
  //    * find the minimum value from the three edge detected images
  //    * Get the brightness of the depth image at the location
  //    * Mark the depth discontinuties in red and the normal discontinuities in blue.

  PImage res = createImage(img.width, img.height, RGB);

  depth = createEdgesCanny(depth, clow, chigh);
  
  PImage nmapRed = createEdgesCanny(selectChannel(nmap, 1), clow, chigh);
  PImage nmapGreen = createEdgesCanny(selectChannel(nmap, 2), clow, chigh);
  PImage nmapBlue = createEdgesCanny(selectChannel(nmap, 3), clow, chigh);
  nmapRed.loadPixels();
  nmapGreen.loadPixels();
  nmapBlue.loadPixels();

  for (int y = 0;y < img.height; ++y) {
    for (int x = 0; x < img.width; ++x) {
      int[] values = new int[3];
      values[0] = nmapRed.pixels[x + y * nmapRed.width];
      values[1] = nmapGreen.pixels[x + y * nmapGreen.width];
      values[2] = nmapBlue.pixels[x + y * nmapBlue.width];
      float minimumVal = min(values);

      if (minimumVal != -1.0)
          res.pixels[x + y * res.width] = color(0, 0, 255);
      else
         res.pixels[x + y * res.width] = color(255, 255, 255);
      
     float depthBrightness = brightness(depth.pixels[x + y * depth.width]);
     if (depthBrightness == 0)
       res.pixels[x + y * res.width] = color(255, 0, 0);
     
    }
  }
  
  res.updatePixels();

  return res;
}

/////////////////////////////////////////////////////////////////////////////

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
  inputImage = loadImage("data/venus.png");
  inputImage.resize(0, inputHeight); // proportional scale to height

  size(500,500);
  surface.setResizable(true);
  surface.setSize(inputImage.width, inputImage.height); 
  frameRate(3);
  
  depthImage = loadImage("data/venus_depth.png");
  depthImage.resize(0, inputHeight); 

  normalMapImage = loadImage("data/venus_normal.png");
  normalMapImage.resize(0, inputHeight); 


  differenceImage = createBlurDiff(depthImage);

  outputImage = inputImage;
}


void draw() {
  image(outputImage, 0, 0);
}

void keyPressed() {
  // Keys 1-5 just show the data we are working on. Keys 6 and 7 call functions which you should implement
  // a, s, q, w change canny edge detection parameters.
  // + and - change the blurring sigma
  // m toggles color mapping 
  // x saves the image
  if (key=='1') {
    outputImage = inputImage;
  }
  if (key=='2') {
    outputImage = depthImage;
  }
  if (key=='3') {
    outputImage = normalMapImage;
  }

  if (key=='4') { 
    outputImage = createEdgesCanny(inputImage, clow, chigh);
  }

  if (key=='5') { 
    outputImage = createEdgesCanny(depthImage, clow, chigh);
  }

  if (key=='6') {
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }

  if (key=='7') {

    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
  }

  if (key=='a') {
    chigh -= 0.2;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='s') {
    chigh += 0.2;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='q') {
    clow -= 0.1;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='w') {
    clow += 0.1;
    outputImage = markDiscontinuities(inputImage, depthImage, normalMapImage);
  }
  if (key=='+') {

    sigma += 1; 
    differenceImage = createBlurDiff(depthImage);
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
    println("Blur sigma: " + sigma);
  }
  if (key=='-') {

    sigma -= 1; 
    differenceImage = createBlurDiff(depthImage);
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
    println("Blur sigma: " + sigma);
  }
   if (key=='m') {

    colorMapping = !colorMapping;   
    outputImage = unsharpMask(differenceImage, inputImage, depthImage);
   
  }
  if (key == 'x') {
    save("result.png");
  }
  println("Low: " + clow + " High: " + chigh);
}
