% test 3d point cloud 
close all;
filenameLeft = 'Testbilder/Rechts.png';
filenameRight = 'Testbilder/Links.png';
imgLeft = rgb2gray(imread(filenameLeft));
imgRight = rgb2gray(imread(filenameRight));
load('stereoParams_TEST.mat');

[pointCloud, imgLeftRect, imgRightRect] = get3DPointCloud(imgLeft, imgRight, stereoParams);

figure;
imshow(stereoAnaglyph(imgLeftRect, imgRightRect));
%figure;
%imshow(stereoAnaglyph(imgLeft, imgRight));

% 
% Z = pointCloud(:, :, 3);
% figure;
% mask = repmat(Z > 3200 & Z < 3700, [1, 1, 1]);
% imgLeft(~mask) = 0;
% imshow(imgLeft);
% 
% maxZ = 2;
% minZ = 1;
% zdisp = Z;
% pointCloud = pointCloud/1000; % in meters
% zdisp(Z < minZ | Z > maxZ) = NaN;
% point3Ddisp = pointCloud;
% point3Ddisp(:,:,3) = zdisp;
% [imgHeight, imgWidth] = size(imgLeft);
% showPointCloud(point3Ddisp);
% xlabel('X');
% ylabel('Y');
% zlabel('Z');