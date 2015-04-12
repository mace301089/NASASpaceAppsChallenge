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
float[] intAccelBuster = new float[3];
float[] intAccelJunk = new float[3];

float[] intVeloBuster = {0,0,0};
float[] intVeloJunk = {0,0,0};
final float Z_MAX = 200;

float[] targetJunk = {40, 200, 10};

void generateSpaceData() {
  intAccelBuster = guideBuster(intAccelBuster, junkBuster, targetJunk);
  //intAccelBuster = modifyArrayRandomly(intAccelBuster, 10);
  
  intAccelJunk = modifyArrayRandomly(intAccelJunk, 20 );
  float[] targetObservatory = {OFFSCREEN_WIDTH/2, OFFSCREEN_HEIGHT/2, 0};
  intAccelJunk = addCenterBouncing(intAccelJunk, junk, targetObservatory, 0.3);
  
  intVeloBuster = addIntegration(intVeloBuster, intAccelBuster);
  intVeloJunk = addIntegration(intVeloJunk, intAccelJunk);
  
  junkBuster = addIntegration(junkBuster, intVeloBuster);
  junk = addIntegration(junk, intVeloJunk);
  
  junkBuster = clipSpace(junkBuster);
  junk = clipSpace(junk);
  
  junkScreen = projectCoordinates(junk); 
  junkBusterScreen = projectCoordinates(junkBuster);
}

float[] modifyArrayRandomly(float[] in, float amout) {
  for(int i = 0; i < in.length; i++) {
    in[i] += random(-1*amout, amout)/10;
    in[i] = constrain(in[i], -1*amout, amout);
  }
  return in;  
}

float[] addIntegration(float[] dest, float[] div) {
  for(int i = 0; i < dest.length; i++)
    dest[i] += div[i]/frameRate;
  return dest;
}

float[] clipSpace(float[] in) {
  in[0] = constrain(in[0], 10, OFFSCREEN_WIDTH-10);
  in[1] = constrain(in[1], 10, OFFSCREEN_HEIGHT-10);
  in[2] = constrain(in[2], 20, Z_MAX);
  return in;
}

float[] projectCoordinates(float[] xyz) {
  float[] xy = {xyz[0], xyz[1]};
  float zAdd = xyz[2] * 0.5;
  xy[0] += zAdd;
  xy[1] += zAdd;
  xy[1] = OFFSCREEN_HEIGHT - xy[1];
  return xy;
}

float[] addCenterBouncing (float[] accel, float[] pos,
  float target[], float backwardAcceleration) {
  float[] vector = new float[3];
  for(int i = 0; i < 2; i++) {
    vector[i] = (target[i]-pos[i]);
    accel[i] += vector[i] * backwardAcceleration;
  }
  return accel;
}

float guideIntegrator[] = new float[] {0,0,0};
float guideDerivator[] = new float[] {0,0,0};
float[] guideBuster(float[] accel, float[] pos, float target[]) {
  float Kp = -2000, Ti = 0.2, Tv=2;
  float Tu = 0.877;// 1/frameRate; //Verzugszeit der Totzeit
  float Tg = 1.72-Tu; //2/frameRate;//2/frameRate; // Ausgleichszeit der Totzeit
  float Ks = 1;
  Tv = 0.5*Tu;
  Ti = 1.0*Tg;
  Kp = 0.6*Tg/Tu/Ks;
  
  
  float[] vector = new float[3];
  for(int i = 0; i < 3; i++) {
    vector[i] = (target[i]-pos[i]); // inversed, because set difference
    //PI: accel[i] = Kp * (vector[i] + guideIntegrator[i]/Ti);
    //PD: accel[i] = Kp * (vector[i] + Tv*(vector[i]-guideDerivator[i]/frameRate) );
    //P: accel[i] = Kp*vector[i];
    /*PID:*/
    accel[i] = Kp * (vector[i] + guideIntegrator[i]/Ti + 
      Tv*(vector[i]-guideDerivator[i]/frameRate));
    guideDerivator[i] = vector[i];
    guideIntegrator[i] += vector[i]/frameRate;
    guideIntegrator[i] = constrain(guideIntegrator[i], -2, 2);
  }
  return accel;
}
