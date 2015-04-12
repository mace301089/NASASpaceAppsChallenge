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
import java.util.Arrays;

float[] derivate(float[] currentPosition, float[] lastPosition) {
  float[] output = new float[3];
  for(int i = 0; i < 3; i++)
    output[i] = (currentPosition[i] - lastPosition[i]) * frameRate;
  return output;
}

/**
 * Changes to the C version: impact to the x-center
 */
float[] calculateImpact(float[] pos,
  float impactDistance, float impactVelocity,
  float previousImpactDistance, float previousImpactVelocity) {
            
  float[] output = new float[3];
  //0 impactDistance, 1 impactVelocity, 2 impactTime

  output[0] = sqrt(pow(OFFSCREEN_WIDTH/2-pos[0],2) + pos[1]*pos[1] + pos[2]*pos[2]);
  output[1] = (previousImpactDistance - output[0]) * frameRate;
  //float accel = (previousImpactVelocity - impactVelocity) * frameRate;
  //old: output[2] = sqrt( 2.0 * (impactDistance - impactVelocity)/accelaration );
  //improved: output[2] = 1/2*accel*( -1*output[0]+sqrt( pow(output[0],2)-4*output[0]*output[1] ) );
  // simplified: x = (dx/dt)*t -> t = x/(dx/dt)
  output[2] = output[0] / output[1];
  if(output[2]<0) // won't collide
    output[2] = Float.POSITIVE_INFINITY;

  /* Output historic values: remember to store the output after calling the function! */
  //*previousImpactDistance = *impactDistance;
  //*previousImpactVelocity = *impactVelocity;
  return output;
}


void performAdditionalSpaceCalculations() {
  /* calculate junk buster velocity */
  junkBusterVelo = derivate(junkBuster, junkBuster_1);
  //junkBuster_1 = junkBuster;
  System.arraycopy( junkBuster, 0, junkBuster_1, 0, junkBuster_1.length );

    /* calculate junk buster acceleration */
  junkBusterAccel = derivate(junkBusterVelo, junkBusterVelo_1);
  //junkBusterVelo_1 = junkBusterVelo;
  System.arraycopy( junkBusterVelo, 0, junkBusterVelo_1, 0, junkBusterVelo_1.length );

    /* calculate junk velocity */
  junkVelo = derivate(junk, junk_1);
  //junk_1 = junk;
  //System.arraycopy( src, 0, dest, 0, src.length );
  System.arraycopy( junk, 0, junk_1, 0, junk_1.length );

    /* calculate junk acceleration */
  junkAccel = derivate(junkVelo, junkVelo_1);
  //junkVelo_1 = junkVelo;
  System.arraycopy(junkVelo, 0, junkVelo_1, 0, junkVelo_1.length );

    /* Calculate Time To Impact for Junk */
  float[] answer1 = calculateImpact( junkBuster,
    junkBusterImpactDistance, junkBusterImpactVelocity,
    junkBusterImpactDistance_1, junkBusterImpactVelocity_1 );
  junkBusterImpactDistance = answer1[0];
  junkBusterImpactVelocity = answer1[1];
  junkBusterImpactTime = answer1[2];
  junkBusterImpactDistance_1 = junkBusterImpactDistance;
  junkBusterImpactVelocity_1 = junkBusterImpactVelocity;

  float[] answer2 = calculateImpact( junk,
    junkImpactDistance, junkImpactVelocity,
    junkImpactDistance_1, junkImpactVelocity_1 );
  junkImpactDistance = answer2[0];
  junkImpactVelocity = answer2[1];
  junkImpactTime = answer2[2];
  junkImpactDistance_1 = junkImpactDistance;
  junkImpactVelocity_1 = junkImpactVelocity;
}

float calcDistance(float[] a, float[] b) {
  return sqrt(pow(a[0]-b[0],2) + pow(a[1]-b[1],2) + pow(a[2]-b[2],2));
}
