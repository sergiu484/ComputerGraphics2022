  

float yPos = 50.0;
float xPos = 50.0;
float squareSize = 10;

float planetX = 100.0;
float planetY = 100.0;
float theta = 0.0;

float spiralX = 100;
float spiralY = 300;
float spiralRadius = 50;
float spiralA = 0.05;

color a, b, c, d;


void setup() {  // setup() runs once
  size(400, 400);
  frameRate(30);
}

void keyPressed() {
  if(key == '+') { squareSize += 10; }
  if(key == '-') { squareSize -= 10; }
}

void mousePressed() {
  xPos = mouseX;
  yPos = mouseY;
}
 
void draw() {  // draw() loops forever, until stopped
  background(200);
  fill(255);
  yPos += random(0,2) - 1;
  xPos += random(0,2) - 1;
  
  
  if (yPos < 0) {
    yPos = height;
  } else if(yPos > height) {
    yPos = 0;
  }
  if (xPos < 0) {
    xPos = width;
  } else if(xPos > width) {
    xPos = 0;
  }
  
  fill(color(255, 255, 255));
  rect(xPos - squareSize / 2.0, yPos - squareSize / 2.0, squareSize, squareSize);
  
  // orbit
  float orbitX = planetX + 70.0 * cos(theta);
  float orbitY = planetY + 10.0 * sin(theta);
  theta += 0.01;
  fill(color(255 * cos(theta), 0 , 0));
  ellipse(orbitX, orbitY, 5, 5);
  
  fill(color(#FFA500));
  ellipse(planetX, planetY, 10, 10);
  
  if (frameCount % 30 == 0) {
    a = color(random(0,255), random(0,255), random(0,255));
    b = color(random(0,255), random(0,255), random(0,255));
    c = color(random(0,255), random(0,255), random(0,255));
    d = color(random(0,255), random(0,255), random(0,255));
  }
  
  fill(a);
  rect(200, 200, squareSize, squareSize);
  fill(b);
  rect(200 + squareSize, 200, squareSize, squareSize);
  fill(c);
  rect(200, 200 + squareSize, squareSize, squareSize);
  fill(d);
  rect(200 + squareSize, 200 + squareSize, squareSize, squareSize);
  
  for (int i = 0; i < 1000; i++) {
    float t = radians(i);
    float x = spiralX + spiralA * t * spiralRadius * cos(t);
    float y = spiralY + spiralA * t * spiralRadius * sin(t);
    colorMode(HSB);
    fill(color((i + frameCount) % 255, 255, 255));
    noStroke();
    ellipse(x, y, 2, 2);
    colorMode(RGB);
    stroke(0);
  }
  
  textSize(30);
  fill(255);
  text("ICG", 300, 100);
  fill(125);
  text("ICG", 305, 105);
  fill(0);
  text("ICG", 310, 110);
}
