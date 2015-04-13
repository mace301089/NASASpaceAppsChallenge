Welcome,  
we are  
[ ![Junk Busters Logo](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Logo/JunkBusters-Logo%20small.jpg) ](https://2015.spaceappschallenge.org/project/junk-busters/)

#Space Junk
The increasing amount of space junk is a human made problem. We came up with the idea to use the [NASA SPHERES](http://www.nasa.gov/spheres/satellites.html) platform for developing autonomous satellites with stereo vision cameras to actively remove space junk. Our vision consists of two or more paired spheres: An observatory unit and one ore more operational units. 

[ ![SPHERES with VERTIGO extension for stereo vision](http://ssl.mit.edu/spheres/images/vertigo/vertigo-only-lores.jpg) ](http://ssl.mit.edu/spheres/projects/vertigo.html)  
SPHERES with VERTIGO extension for stereo vision

#Utilizing Stereo Vision
Having our idea in mind we used a real stereo camera setup ([IDS uEye](https://de.ids-imaging.com/store/ui-3220cp.html)), our laptop webcams and virtual demos to develop our implementation.

![Live Demo Setup](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/Live%20Demo%20Setup.jpg)

#Our solution
The original plan was to code a proof of concept in MATLAB by using different toolboxes. But then reality kicked in and we experienced minor issues. So we had a NOGO decision for MATLAB and switched to coding in C++ using OpenCV.

##OpenCV Image Processing and 3D reconstruction
We used the [OpenCV](http://opencv.org/) framework to solve the following task of processing stereo vision images in real time:

* Stereo Image Acquisition
* Camera Calibration using a checkerboard calibration target
* Color Segmentation and Binarization
* Object Tracking: Colored balls and taught patterns

![Camera Calibration](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/OpenCV%20camera%20calibration.png)
Stereo Camera Calibration

![Object Tracking](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Video%20Processing/OpenCV%20object%20detection.png)
Live Object Tracking

##Dashboard UI: Processing Data and Demonstration
In order to demonstrate our vision of the *Junk Buster* SpaceBots we created an interactive live demo with exemplary space trajectories. 
Features:

* 3D Data Processing: Numeric calculation of distance, speed and acceleration
* Alarm features: Collision alarm between all objects
* Impact prediction: Time to impact with alarm levels
* Interactivity: The operational Junk Buster follows the mouse. Scrolling edits the depth value set.
* Exemplary Space Trajectories: Generating sample data to animate the demo

![Dashboard Live Demo](https://raw.githubusercontent.com/mace301089/NASASpaceAppsChallenge/master/Demo/Dashboard%20UI/JunkBusterDemo%20Overview.png)
Dashboard with Annotations

##MatLab Trials
Our initial goal was to solve the project using MatLab. Since we ran into trouble we soon started to change the setup. We started using the [Computer Vision System Toolbox](http://de.mathworks.com/products/computer-vision/) and worked on an initial user interface. All the space trajectory processing was developed in MatLab and afterwards ported to C and Java (Processing).

#Presentation Material

[ Here you can see our slides:  
 ![Junk Busters Slides](http://0701.static.prezi.com/preview/hr4w4evjveobqvcuy6qbrnvvpaadw6rhlm5vs2oll757hbaoaxlq_0_0.png)  
](http://prezi.com/fyv5emc8qm2u/)

#Acknowledgements
Thanks to the members of staff at [Lab75](https://lab75.jp/), our host at Space Apps Challenge 2015 at Frankfurt. We also thank [Prof. Dr. Stephan Neser](http://www.fbmn.h-da.de/~neser/) for supporting us with the stereo camera equipment and MatLab advice.
