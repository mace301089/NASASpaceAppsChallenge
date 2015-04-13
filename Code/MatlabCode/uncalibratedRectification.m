% input parameters
    %   images
filenameLeft = 'Testbilder/Links.png';      % filenameLeft = 'left.tif';
filenameRight = 'Testbilder/Rechts.png';    % filenameRight = 'right.tif';
    %   SURF
metricThreshold = 2000;     % the threshold value for the surf feature detection
nStrongest = 50;            % first n strongest SURF features for selection
    % matching
matchThreshold = 5;         % the matching threshold of the features
nTrialsFundMat = 10000;     % number of trials for the epipolar constraints
distThresh = 0.1;           % distance threshold for the epiolar constraints
confidenceLevel = 99.99;    % confidence level for the epipolar constraints

%load stereo images and convert to grayscale
imgLeft = rgb2gray(imread(filenameLeft));
imgRight = rgb2gray(imread(filenameRight));

imshowpair(imgLeft, imgRight, 'montage'); % show both of the images

% detect some SURF features
blobsLeft = detectSURFFeatures(imgLeft, 'MetricThreshold', metricThreshold);
blobsRight = detectSURFFeatures(imgRight, 'MetricThreshold', metricThreshold);

% visualize them
figure;
imshow(imgLeft);
hold on;
plot(selectStrongest(blobsLeft, nStrongest));
title('N strongest SURF features in left image');

figure;
imshow(imgRight);
hold on;
plot(selectStrongest(blobsRight, nStrongest));
title('N strongest SURF features in right image');

% extract the features
[featuresLeft, validBlobsLeft] = extractFeatures(imgLeft, blobsLeft);
[featuresRight, validBlobsRight] = extractFeatures(imgRight, blobsRight);

% then match them 
indexPairs = matchFeatures(featuresLeft, featuresRight, 'Metric', 'SAD', ...
  'MatchThreshold', matchThreshold);
matchedPointsLeft = validBlobsLeft(indexPairs(:,1),:);
matchedPointsRight = validBlobsRight(indexPairs(:,2),:);

% only leave points that match epiolar line constraints
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPointsLeft, matchedPointsRight, 'Method', 'RANSAC', ...
  'NumTrials', nTrialsFundMat, 'DistanceThreshold', distThresh, 'Confidence', confidenceLevel);

if status ~= 0 || isEpipoleInImage(fMatrix, size(imgLeft)) ...
  || isEpipoleInImage(fMatrix', size(imgRight))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPointsLeft = matchedPointsLeft(epipolarInliers, :);
inlierPointsRight = matchedPointsRight(epipolarInliers, :);

% display the matched points
figure;
showMatchedFeatures(imgLeft, imgRight, inlierPointsLeft, inlierPointsRight);
legend('Inlier points in Leftimg', 'Inlier points in Rightimg');

% uncalibrated rectification transform
[tLeft, tRight] = estimateUncalibratedRectification(fMatrix, ...
  inlierPointsLeft.Location, inlierPointsRight.Location, size(imgRight));
tformLeft = projective2d(tLeft);
tformRight = projective2d(tRight);

imgLeftRect = imwarp(imgLeft, tformLeft, 'OutputView', imref2d(size(imgLeft)));
imgRightRect = imwarp(imgRight, tformRight, 'OutputView', imref2d(size(imgRight)));

% transform the points to visualize them together with the rectified images
ptsLeftRect = transformPointsForward(tformLeft, inlierPointsLeft.Location);
ptsRightRect = transformPointsForward(tformRight, inlierPointsRight.Location);

% actual rectification
Irectified = cvexTransformImagePair(imgLeft, tformLeft, imgRight, tformRight);
Irectified = flipud(Irectified);
figure;
imshow(Irectified);