#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <stdio.h>

using namespace std;
using namespace cv;


int main_getFrames( int argc, const char** argv )
{
	int frameCounter = 0;
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
	cvNamedWindow( "result", CV_WINDOW_AUTOSIZE );

	cout << "In capture ..." << endl;
		for(;;)
		{
			Mat matRight;
			captureRight >> matRight;

			Mat matLeft;
			captureLeft >> matLeft;
			flip(matLeft, matLeft, 0);
			
			if( matRight.empty() || matLeft.empty() )
				break;
			
			imshow("RightCamera",matRight);
			imshow("LeftCamera",matLeft);

			int key = waitKey( 10 ); 
			if(  key >= 0 )
			{
				if(key == 32)
				{
					stringstream leftFile;
					leftFile << "C:/Users/Philipp/Desktop/CalibFiles/Left" << frameCounter << ".png";
					stringstream rightFile;
					rightFile << "C:/Users/Philipp/Desktop/CalibFiles/Right" << frameCounter << ".png";
					
					imwrite(leftFile.str(), matLeft); 
					imwrite(rightFile.str(), matRight);
					frameCounter++;
				}
				else
				{
					break;
				}
			}
		}
		

	
	return 0;
}



