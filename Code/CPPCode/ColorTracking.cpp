#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "opencv/cv.h"
#include "opencv/cxmisc.h"
#include "opencv/highgui.h"
#include "opencv/cvaux.h"

#include <iostream>
#include <stdio.h>

using namespace std;
using namespace cv;

//Source
//http://opencv-srf.blogspot.de/2010/09/object-detection-using-color-seperation.html

int main_Tracking(int argc, const char** argv) {

	Scalar PinkLow;
	PinkLow[0] = 130;
	PinkLow[1]=  0;
	PinkLow[2] = 120;
	Scalar PinkHigh;
	PinkHigh[0] = 179;
	PinkHigh[1] = 255;
	PinkHigh[2]=  255;

	Scalar GreenLow;
	GreenLow[0] = 42;
	GreenLow[1]=  94;
	GreenLow[2] = 75;
	Scalar GreenHigh;
	GreenHigh[0] = 81;
	GreenHigh[1] = 255;
	GreenHigh[2]=  255;

	IplImage* img = cvCreateImage(cvSize(1000,1000),8,1);
	VideoCapture captureRight = 0;
	VideoCapture captureLeft = 0;
	Mat frame, frameCopy, image;

	
	


	captureRight.open(2);
	captureLeft.open(1);
	if( !captureRight.isOpened() || !captureLeft.isOpened() )
	{
		cout << "No cameras detected" << endl;
		return -1;
	}
	/*namedWindow( "CONTROL", CV_WINDOW_AUTOSIZE );
	
	int LowH = 0;
	int LowS = 0;
	int LowV  =0; 
	int HighH = 0;
	int HighS  =0;
	int HighV  =0;
	cvCreateTrackbar("LowH","CONTROL", &LowH,179);
	cvCreateTrackbar("HighH","CONTROL", &HighH,179);
	cvCreateTrackbar("LowS","CONTROL", &LowS,255);
	cvCreateTrackbar("HighS","CONTROL", &HighS,255);
	cvCreateTrackbar("LowV","CONTROL", &LowV,255);
	cvCreateTrackbar("HighV","CONTROL", &HighV,255);
	*/
	
	

	cout << "In capture ..." << endl;
	for(;;)
	{
		/*
	PinkLow[0]  =LowH; 
	PinkLow[1]=	LowS ;
	PinkLow[2]=	LowV ;
	PinkHigh[0]=HighH;
	PinkHigh[1]=HighS;
	PinkHigh[2]=HighV;
	*/
		Mat matRight;
		captureRight >> matRight;

		Mat matLeft;
		captureLeft >> matLeft;
		flip(matRight, matRight, 0);

		if( matRight.empty() || matLeft.empty() )
		{	
			break;
		}

		Mat rightHsv;
		Mat leftHsv;
		cvtColor(matRight,rightHsv, COLOR_BGR2HSV);
		cvtColor(matLeft,leftHsv, COLOR_BGR2HSV);

		inRange(rightHsv,PinkLow,PinkHigh, rightHsv);
		inRange(leftHsv,GreenLow,GreenHigh, leftHsv);

		
		 //morphological opening (removes small objects from the foreground)
        erode(rightHsv, rightHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
        dilate( rightHsv, rightHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );

        
        //morphological closing (removes small holes from the foreground)
        dilate( rightHsv, rightHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
        erode(rightHsv, rightHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );

		 //morphological opening (removes small objects from the foreground)
        erode(leftHsv, leftHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
        dilate( leftHsv, leftHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );

                //morphological closing (removes small holes from the foreground)
        dilate( leftHsv, leftHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
        erode(leftHsv, leftHsv, getStructuringElement(MORPH_ELLIPSE, Size(5, 5)) );
		GaussianBlur(rightHsv,rightHsv,Size(9,9),1.5);
		GaussianBlur(leftHsv,leftHsv,Size(9,9),1.5);
		
		
		vector<Vec3f> circlesRight;
		vector<Vec3f> circlesLeft;
		Mat gray;
		
		HoughCircles(rightHsv, circlesRight, CV_HOUGH_GRADIENT,2, rightHsv.rows/4,100,50,rightHsv.rows/10,rightHsv.rows/4);
		HoughCircles(leftHsv, circlesLeft, CV_HOUGH_GRADIENT,2, leftHsv.rows/4,100,50,leftHsv.rows/10,leftHsv.rows/4);
	
	for( size_t i = 0; i < circlesRight.size(); i++ )
    {
         Point center(cvRound(circlesRight[i][0]), cvRound(circlesRight[i][1]));
         int radius = cvRound(circlesRight[i][2]);
         // draw the circle center
         circle( matRight, center, 3, Scalar(255,255,255), -1, 8, 0 );
         // draw the circle outline
         circle( matRight, center, radius, Scalar(0,0,255), 3, 8, 0 );
    }
	for( size_t i = 0; i < circlesLeft.size(); i++ )
    {
         Point center(cvRound(circlesLeft[i][0])-75, cvRound(circlesLeft[i][1])-25);
         int radius = cvRound(circlesLeft[i][2]);
         // draw the circle center
         circle( matRight, center, 3, Scalar(255,255,255), -1, 8, 0 );
         // draw the circle outline
         circle( matRight, center, radius, Scalar(0,255,0), 3, 8, 0 );
    }
		imshow("RightCamera",rightHsv);
		imshow("Result",matRight);
		//imshow("Left",matLeft);
		imshow("LeftCamera",leftHsv);
		
		int key = waitKey( 10 ); 
		if(  key >= 0 )
		{
			return 0;
		}
		// waitKey(0);
	}
	return 0;
}