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
float[] junkBusterScreen = new float[] {0,0}; // XY, must be set by image processing
float[] junkScreen= new float[] {0,0}; // XY, must be set by image processing

float[] junkBuster= new float[] {20, 20, 0}; // XYZ, must be set by image processing
float[] junkBuster_1= new float[] {0,0,0};
float[] junkBusterVelo= new float[] {0,0,0};
float[] junkBusterVelo_1= new float[] {0,0,0};
float[] junkBusterAccel= new float[] {0,0,0};
float junkBusterImpactDistance=0;
float junkBusterImpactVelocity=0;
float junkBusterImpactDistance_1=0;
float junkBusterImpactVelocity_1=0;
float junkBusterImpactTime=0;

float[] junk= new float[] {300, 200, 200}; //XYZ, must be set by image processing
float[] junk_1= new float[] {0,0,0};
float[] junkVelo= new float[] {0,0,0};
float[] junkVelo_1= new float[] {0,0,0};
float[] junkAccel= new float[] {0,0,0};
float junkImpactDistance=0;
float junkImpactVelocity=0;
float junkImpactDistance_1=0;
float junkImpactVelocity_1=0;
float junkImpactTime=0;
