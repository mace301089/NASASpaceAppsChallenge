function [] = Live_Anaglyph(videoIn)



%%
% ----  default parameters  ----
% cameraIndexR = 3; 
% cameraIndexL = 2; % default camera index
cameraIndexR = 1; 
cameraIndexL = 2;

% ----  input parameter check  ----
if (nargin < 1 || isempty(videoIn) || videoIn == -1)
    vidRight = videoinput('winvideo', cameraIndexR);
    vidLeft = videoinput('winvideo', cameraIndexL);
end


% ----  initialization  ----
srcRight = getselectedsource(vidRight);
srcLeft = getselectedsource(vidLeft);
% gui elements
hFig = [];

% anaglyoh recitfication settings
metricThreshold = 2000;     % the threshold value for the surf feature detection
nStrongest = 100;            % first n strongest SURF features for selection
    % matching
matchThreshold = 5;         % the matching threshold of the features
nTrialsFundMat = 10000;     % number of trials for the epipolar constraints
distThresh = 0.1;           % distance threshold for the epiolar constraints
confidenceLevel = 99.99;    % confidence level for the epipolar constraints

% images and image properties
vidResRight = get(vidRight, 'VideoResolution');
vidResLeft = get(vidLeft, 'VideoResolution');
nBandsRight = get(vidRight, 'NumberOfBands');
nBandsLeft = get(vidLeft, 'NumberOfBands');

% miscellaneous
abort = false;
ccPoints = [];
ccpI = [];
outlier  =[];

show_message = @(x) disp(x);


%% main
gui_getFrames()         % aquire images from camera
if abort
    disp('function aborted')
    return
end



%% helping functions
 

   

%% GUI
    function gui_getFrames()
        hFig = figure('Name', 'Preview Window - Position the object!');
        uicontrol('String', 'abort', 'Position', [260 0 120 20],...         % button to abort the function
            'Callback', @abortClick);
        % first image
       
        %subplot(121);
        hImageRight = image(zeros(vidResRight(2), vidResRight(1), nBandsRight));
        set(gca, 'Visible', 'off');
        
        axis equal;
        srcRight.VerticalFlip = 'off';
        
        imgLeft = rgb2gray(getFrame(srcLeft, vidLeft, -4));
        imgRight = rgb2gray(getFrame(srcRight, vidRight, -4));
        
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
        
        imshow(Irectified);
        uiwait(hFig);
        if abort
            return
        end
    end



%% GUI-Callbacks
% aborting operation
    function abortClick(~,~)
        abort = true;
        close(hFig)
    end

    function camName = getCamName(vid)
        vidName = get(vid, 'Name');
        splitted = regexp(vidName, '-', 'split');
        iinfo = imaqhwinfo(splitted{end-1}, str2double(splitted{end}));
        camName = iinfo.DeviceName;
    end
function out = getFrame(src,vid,expVal)
        src.Exposure = expVal;  % update exposure time
        flushdata(vid)
           % remove old data
        start(vid) 
        % start aquisition
        wait(vid) 
        % wait to finish aquisition
        stop(vid)  
        % stop aquisition
        out = getdata(vid,1); 
        % get frame
 end

end






