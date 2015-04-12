/**
 * This demo is part of the Junk Busters project. We try to solve the
 * "SpaceBot Stero Vision" challenge of the  NASA Space Apps Challenge 2015.
 *
 * Url: https://2015.spaceappschallenge.org/project/junk-busters/
 *
 * Author:  Sebastian Schleemilch
 * Co-Authors:  All members of the project. See our website.
 * Date:    2015-04-12
 */
PGraphics offscreen;
PImage bgImg;
PImage innosat, cubesat;
PImage starfield;
PImage infobox;

float scaleValue = 1;

final int OFFSCREEN_WIDTH = 947;
final int OFFSCREEN_HEIGHT = 489;

float infoboxOpacity = 1.0f;

void setup() {
  offscreen = createGraphics(OFFSCREEN_WIDTH, OFFSCREEN_HEIGHT);
  
  bgImg = loadImage("JBDemoBackground.png");
  size(bgImg.width, bgImg.height);
  
  innosat = loadImage("innosat.png");
  cubesat = loadImage("cubesat.png");
  starfield = loadImage("starfield.png");
  
  infobox = loadImage("JunkBusterInfoBox.png");
}

void draw() {
  image(bgImg, 0, 0);
  fill(255);
  text("CONTROLLING SPACE BUSTER VIEW", 38, 633);
  
  /* Draw offscreen */
  offscreen.beginDraw();
  offscreen.imageMode(CORNER);
  offscreen.image(starfield, 0, 0);  
  offscreen.textSize(12);
  offscreen.imageMode(CENTER);
  offscreen.ellipseMode(CENTER);
  
  if(junkImpactDistance>=junkBusterImpactDistance) {
    drawElement("OPERATING JUNK BUSTER", innosat, junkBuster, junkBusterScreen, junkBusterVelo, 
      junkBusterImpactDistance, junkBusterImpactVelocity, junkBusterImpactTime);
    drawElement("JUNK", cubesat, junk, junkScreen, junkVelo,
      junkImpactDistance, junkImpactVelocity, junkImpactTime );
  }
  else {
    drawElement("JUNK", cubesat, junk, junkScreen, junkVelo,
      junkImpactDistance, junkImpactVelocity, junkImpactTime );
    drawElement("OPERATING JUNK BUSTER", innosat, junkBuster, junkBusterScreen, junkBusterVelo, 
      junkBusterImpactDistance, junkBusterImpactVelocity, junkBusterImpactTime);
  }
  
  float elementsDistance = calcDistance(junk, junkBuster);
  if(elementsDistance<400) {
    offscreen.noFill();
    offscreen.stroke(255, 0, 0);
    offscreen.strokeWeight(10);
    offscreen.ellipseMode(CENTER);
    float scaleValue = 1-0.5*(junk[2]+junkBuster[2])/2/Z_MAX;
    float alarmX = (junkScreen[0]+junkBusterScreen[0])/2*scaleValue;
    float alarmY = (junkScreen[1]+junkBusterScreen[1])/2*scaleValue;
    offscreen.ellipse(alarmX, alarmY, 400, 400);
    offscreen.textSize(30);
    offscreen.noStroke();
    offscreen.fill(0);
    offscreen.rect(alarmX-32, alarmY-32, 105, 35);
    offscreen.fill(255, 0, 0);
    offscreen.text(String.format("%.0f m", elementsDistance), alarmX-30, alarmY);
    offscreen.strokeWeight(0);
  }
  
  offscreen.endDraw();
  image(offscreen, 40, 130);  
  if(infoboxOpacity>0) {
    tint(255, 255*infoboxOpacity*infoboxOpacity);  // Display at half opacity
    image(infobox, 180, 200);
    tint(255, 255);
  }
  infoboxOpacity -= 0.002;
  performAdditionalSpaceCalculations();
  generateSpaceData();
}

void mouseMoved() {
  /* Update operational Space Buster Target Set */
  targetJunk[0] = mouseX-40;
  targetJunk[1] = OFFSCREEN_HEIGHT-mouseY+130;
}
void mouseWheel(MouseEvent event) {
  /* Update operational Space Buster Target Set */
  float e = event.getCount();
  targetJunk[2] -= e*1000;
  targetJunk[2] = constrain(targetJunk[2], 0, Z_MAX);
}

void drawElement(String label, PImage objImg, float[] pos, float[] screenPos, 
  float[] velo, float impactDist, float impactVelo, float impactTime) {
  float scaleValue = 1-0.5*pos[2]/Z_MAX;
  offscreen.scale(scaleValue);
  offscreen.image(objImg, screenPos[0], screenPos[1]);  
  
  offscreen.noFill(); offscreen.stroke(255);
  offscreen.ellipse(screenPos[0], screenPos[1], 10, 10);
  
  offscreen.resetMatrix();
  offscreen.translate(screenPos[0]*scaleValue, screenPos[1]*scaleValue);
  screenPos = new float[] {0,0}; // see translation before
  
  offscreen.stroke(255);
  final float dNConversion = 2;
  float dX = velo[0] / dNConversion;
  float dY = -1*velo[1] / dNConversion;
  float dZ = -1*velo[2] / dNConversion;
  offscreen.line(screenPos[0], screenPos[1], screenPos[0]+dX, screenPos[1]);
  offscreen.line(screenPos[0], screenPos[1], screenPos[0], screenPos[1]+dY);
  offscreen.line(screenPos[0], screenPos[1], screenPos[0]+dZ, screenPos[1]+dZ);
  
  offscreen.fill(255);
  offscreen.text(label, screenPos[0]+20, screenPos[1]+20);
  offscreen.text(String.format("Rel Dist: %.2f m", impactDist),
    screenPos[0]+20, screenPos[1]+40+15*0);
  offscreen.text(String.format("Rel Speed: %.2f m/s", impactVelo),
    screenPos[0]+20, screenPos[1]+40+15*1);
  if(impactTime<30) {
    if(impactTime<10)
      offscreen.fill(255, 0, 0);
    else
      offscreen.fill(255, 255, 0);
    offscreen.noStroke();
    offscreen.rect(screenPos[0]+19, screenPos[1]+30+15*2, 90, 15);
    offscreen.fill(0);
  }
  offscreen.text(String.format("Impact: %.1f s", impactTime),
    screenPos[0]+20, screenPos[1]+40+15*2);
  offscreen.resetMatrix();
}

PImage convertToCyan(PImage img) {
  for(int i = 0; i < img.pixels.length; i++) {
    int red = img.pixels[i]>>16 & 0xFF;
    int green = img.pixels[i]>>8 & 0xFF;
    int blue = img.pixels[i] & 0xFF;
    int grey = (red+green+blue)/3;
    img.pixels[i] = grey<<8 | grey;
  }
  img.updatePixels();
  return img;
}
PImage convertToRed(PImage img) {
  for(int i = 0; i < img.pixels.length; i++) {
    int red = img.pixels[i]>>16 & 0xFF;
    int green = img.pixels[i]>>8 & 0xFF;
    int blue = img.pixels[i] & 0xFF;
    int grey = (red+green+blue)/3;
    img.pixels[i] = grey<<16;
  }
  img.updatePixels();
  return img;
}
