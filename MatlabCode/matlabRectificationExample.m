%matlab stereo calibration example

numImagePairs = 10;
imageFiles1 = cell(numImagePairs, 1);
imageFiles2 = cell(numImagePairs, 1);
imageDir = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', ...
    'calibration', 'stereoWebcams');
for i = 1:numImagePairs
    imageFiles1{i} = fullfile(imageDir, 'left',  sprintf('left%02d.png', i));
    imageFiles2{i} = fullfile(imageDir, 'right', sprintf('right%02d.png', i));
end

% Try to detect the checkerboard
im = imread(imageFiles1{1});
imagePoints = detectCheckerboardPoints(im);

% Display the image with the incorrectly detected checkerboard
figure;
imshow(im, 'InitialMagnification', 50);
hold on;
plot(imagePoints(:, 1), imagePoints(:, 2), '*-g');
title('Failed Checkerboard Detection');

images1 = cast([], 'uint8');
images2 = cast([], 'uint8');
for i = 1:numel(imageFiles1)
    im = imread(imageFiles1{i});
    im(3:700, 1247:end, :) = 0;
    images1(:, :, :, i) = im;

    im = imread(imageFiles2{i});
    im(1:700, 1198:end, :) = 0;
    images2(:, :, :, i) = im;
end

[imagePoints, boardSize] = detectCheckerboardPoints(images1, images2);

% Display one masked image with the correctly detected checkerboard
figure;
imshow(images1(:,:,:,1), 'InitialMagnification', 50);
hold on;
plot(imagePoints(:, 1, 1, 1), imagePoints(:, 2, 1, 1), '*-g');
title('Successful Checkerboard Detection');

% Generate world coordinates of the checkerboard points.
squareSize = 108; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Compute the stereo camera parameters.
stereoParams = estimateCameraParameters(imagePoints, worldPoints);

% Evaluate calibration accuracy.
figure;
showReprojectionErrors(stereoParams);

% Read in the stereo pair of images.
I1 = imread('sceneReconstructionLeft.jpg');
I2 = imread('sceneReconstructionRight.jpg');

% Rectify the images.
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

% Display the images before rectification.
figure;
imshow(stereoAnaglyph(I1, I2), 'InitialMagnification', 50);
title('Before Rectification');

% Display the images after rectification.
figure;
imshow(stereoAnaglyph(J1, J2), 'InitialMagnification', 50);
title('After Rectification');

disparityMap = disparity(rgb2gray(J1), rgb2gray(J2));
figure;
imshow(disparityMap, [0, 64], 'InitialMagnification', 50);
colormap('jet');
colorbar;
title('Disparity Map');

point3D = reconstructScene(disparityMap, stereoParams);

% Convert from millimeters to meters.
point3D = point3D / 1000;

% Plot points between 3 and 7 meters away from the camera.
z = point3D(:, :, 3);
maxZ = 7;
minZ = 3;
zdisp = z;
zdisp(z < minZ | z > maxZ) = NaN;
point3Ddisp = point3D;
point3Ddisp(:,:,3) = zdisp;
showPointCloud(point3Ddisp, J1, 'VerticalAxis', 'Y',...
    'VerticalAxisDir', 'Down' );
xlabel('X');
ylabel('Y');
zlabel('Z');