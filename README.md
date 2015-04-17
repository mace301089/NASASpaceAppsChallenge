Welcome,  
we are  
![Junk Busters Logo](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Logo/JunkBusters-Logo%20small.jpg)

#Abstract
***
Space junk has become a major threat for future space exploration. Predictions indicate that we actively have to remove space junk to not to litter the earths orbit completely. In order to reduce the amount of junk in space we are using 3D stereo data to locate, track and navigate space debris which is then actively removed. We use a hardware stereo sensor consisting of two industrial cameras in order to gather 3D depth data. In addition we visualize the relative movement of objects in space. 

#The Problem: Space Junk
***
The increasing amount of space junk [1] is a human made problem. We came up with the idea to use the [NASA SPHERES](http://www.nasa.gov/spheres/satellites.html) platform [2] for developing autonomous satellites with stereo vision cameras to actively remove space junk.

![Illustration of Space Junk](https://upload.wikimedia.org/wikipedia/commons/d/d2/Space_Junk.jpg)  
**Figure 1** *Illustration of Space Junk by [David Shikomba](http://commons.wikimedia.org/wiki/File:Space_Junk.jpg)*

#Our Solution: Paired SPHERES
***

Our vision consists of two or more paired SPHERES: An observatory unit and one or more operational units. They can detect small particles and remove them in a safely manner, for example using a ion source.

[ ![SPHERES with VERTIGO extension for stereo vision](http://ssl.mit.edu/spheres/images/vertigo/vertigo-only-lores.jpg) ](http://ssl.mit.edu/spheres/projects/vertigo.html)  
**Figure 2** *SPHERES with VERTIGO extension for stereo vision [3]*

##Utilizing Stereo Vision
***
Having our idea in mind we used a real stereo camera setup ([IDS uEye](https://de.ids-imaging.com/store/ui-3220cp.html), see Figure 1), our laptop web-cams and virtual demos to develop our implementation.

![Front view of our stereo sensor](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/stereoSensorInside.jpg)
**Figure 4** *Front view of our stereo sensor*

Figure 5 shows our live demo setup with some calibration targets. The magenta ball simulates some piece of space junk and the green ball is an approaching junk buster unit. The whole scene is seen by our stereo sensor which is used to reconstruct the 3D scene. 

![Live Demo Setup](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/Live%20Demo%20Setup.jpg)  
**Figure 5** *Demo Setup of our Camera Environment*

##Technical Implementation
***
We created a set of software to demonstrate our vision and concept. There are two main parts: Image processing / 3D reconstruction and the data interpretation plus visualization.

###OpenCV Image Processing and 3D reconstruction
***
We used the [OpenCV](http://opencv.org/) framework to solve the following task of processing stereo vision images [4] in real time:

* o Stereo Image Acquisition
* o Camera Calibration using a checkerboard calibration target
* o Color Segmentation and Binarization
* o Object Tracking: Colored balls and taught patterns

![Camera Calibration](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/OpenCV%20camera%20calibration.png)  
**Figure 6** *Stereo Camera Calibration*

![Object Tracking](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/OpenCV%20Object%20Detection%20Demo.jpg)  
**Figure 7** *Live Object Tracking*

###CONCEPT DEMO: Data Processing Data and Visualization
***
In order to demonstrate our vision of the *Junk Buster* SpaceBots we created an interactive live demo with exemplary space trajectories. 
Features:

* o Data Processing: Numeric calculation of distance, speed and acceleration
* o Visualization: Movements of the objects in 3D
* o Alarm features: Collision alarm between all objects
* o Impact prediction: Time to impact with alarm levels
* o Interactivity: The operational Junk Buster follows the mouse. Scrolling edits the depth value set.
* o Exemplary Space Trajectories: Generating data to animate the demo

![Dashboard Live Demo](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Dashboard%20UI/JunkBusterDemo%20Overview.png)
**Figure 8** *Dashboard User Interface with Annotations*

###MATLAB Trials
***
The original plan was to code a proof of concept in MATLAB by using different toolboxes. But then reality kicked in and we experienced minor issues. So we had a NOGO decision for MATLAB and switched to coding in C++ using OpenCV. All the initial space trajectory processing was developed in MATLAB and afterwards ported to C and Java (Processing).

![MATLAB Stereo Camera Calibration](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/camera%20extrinsics.png)  
**Figure 9** *Results of Stereo Camera Calibration with MATLAB*

#Conclusion: Saving the Future of Space Exploration
***

By having optical particle detection on board of the SpaceBots, they can detect and remove objects that are invisible to the existing tracking systems. In our mind the technologies exist to reduce the harm of space junk today. With the existing NASA SPHERE program there is an existing platform that could be used for our purpose.

We think it's time for starting to save the future of space exploration!

#Acknowledgments
***
Thanks to the members of staff at [Lab75](https://lab75.jp/), our host at Space Apps Challenge 2015 at Frankfurt. We also thank [Prof. Dr. Stephan Neser](http://www.fbmn.h-da.de/~neser/) for supporting us with the stereo camera equipment and MATLAB advice.

#References
***
^1 ["Orbital Debris FAQ: How many orbital debris are currently in Earth orbit?"](http://orbitaldebris.jsc.nasa.gov/faqs.html#3), NASA, March 2012.  
^2 [SPHERES Satellites](http://www.nasa.gov/spheres/satellites.html), NASA, August 2013.  
^3 [The Visual Estimation for Relative Tracking and Inspection of Generic Objects (VERTIGO) program](http://ssl.mit.edu/spheres/projects/vertigo.html), MIT Space Systems Laboratory.  
^4 [Camera Calibration and 3D Reconstruction](http://docs.opencv.org/modules/calib3d/doc/calib3d.html), OpenCV, February 2015.


#Project Data
***
* o [Source Code Repository](https://github.com/mace301089/NASASpaceAppsChallenge.git)
* o [Introduction Video](https://vimeo.com/125179293)
* o [ Presentation Slides](http://prezi.com/fyv5emc8qm2u/)

#About the Authors
***
**[Eduardo Cruz](http://www.eduardo-cruz.com/)**  
*Software Engineer*

**Tim Elberfeld**  
*Student of Photonics and Computer Vision*

**[Marcel Kaufmann](http://www.marcelkaufmann.de/)**  
*Student of Photonics and Computer Vision*

**[Sebastian Schleemilch](http://www.it-schleemilch.de/)**  
*Student of Electronic and Medical Engineering*

**Philipp Schneider**  
*Student of Photonics and Computer Vision*

This project was worked on during the NASA Space Apps Challenge 2015 (11.-12.04.2015).  
Last updated: 17.04.2015.

***
