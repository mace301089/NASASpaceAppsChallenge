function [stereoCameraParams] = automaticCalibration(videoIn)
%%
%AUTOMATICCALIBRATION aquires images from the camera to calibrate with and
%	without laser line in the image. Save the calibration data in a folder.
%
% @Param:
%   videoIn:        Video object for the camera to be used.
%   (optional)      Unused if LoadLast ~= 0.
%                   If unused, empty or -1 a video input object is created
%                   (videoinput('winvideo', 3)).
%
%   DEBUG:          Flag to indicate debug mode. When DEBUG is true, the
%   (optional)      calibration will be visualized. (i.e. plotting the
%                   laser plane in 3d and showing the detected line points
%                   for each image).
%
% @Return:
%   cameraParams:   The parameters of the camera that were calculated
%                   during the calibration process.
%
%
% History
% 	13.06.2014  Created the file
% 	20.06.2014  Finished the file and the automatic image
%               saving/aquisition process#
%   27.06.2014  Integrated the laser plane calibration.
%               DEBUG mode integrated.
%               Added saving of laser images as 'laserImg.mat' in the
%               calibration folder.
%   09.07.2014  Description and Parameter overview updated. Minor tweaks.
%   02.09.2014  Added advanced visualization for debug.
%   10.04.2015  Modified the file to be just automatic camera calibration
%               without laser plane calibration.
%


%%

% ----  default parameters  ----
cameraIndexR = 3; 
cameraIndexL = 2; % default camera index
RootFolder = 'calibrationFiles';    % default folder to save all the files in
nImages = 20;                       % maximum number of images to be aquired

% ----  input parameter check  ----
if (nargin < 1 || isempty(videoIn) || videoIn == -1)
    vidRight = videoinput('winvideo', cameraIndexR);
    vidLeft = videoinput('winvideo', cameraIndexL);
end


% ----  initialization  ----
srcRight = getselectedsource(vidRight);
srcLeft = getselectedsource(vidLeft);
expTime  = -4;
% gui elements
hFig = [];
hBtnCalc = [];
hBtnImg = [];

% folders
curTime = fix(clock);
calibrationFolder =  [RootFolder '/' ...
    num2str(curTime(1)) '-' ...
    num2str(curTime(2), '%02d') '-' ...
    num2str(curTime(3), '%02d') '_' ...
    num2str(curTime(4), '%02d') '-' ...
    num2str(curTime(5), '%02d')];
subFolder = [calibrationFolder '/images'];

% images and image properties
vidResRight = get(vidRight, 'VideoResolution');
vidResLeft = get(vidLeft, 'VideoResolution');
nBandsRight = get(vidRight, 'NumberOfBands');
nBandsLeft = get(vidLeft, 'NumberOfBands');
imgCheckerboardsRight = zeros(vidResRight(2), vidResRight(1), 1, nImages);
imgCheckerboardsLeft = zeros(vidResLeft(2), vidResLeft(1), 1, nImages);% array holding the checkerboard images for camera calibration
curImageCount = 1;                                          % start index for the image aquisition

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
writerObj = VideoWriter('peaks.avi');
open(writerObj);
Z = peaks; surf(Z); 
axis tight
set(gca,'nextplot','replacechildren');
set(gcf,'Renderer','zbuffer');
for k = 1:20 
   surf(sin(2*pi*k/20)*Z,Z)
   frame = getframe;
   writeVideo(writerObj,frame);
end

close(writerObj);
mkdir(subFolder);       % create folders and
saveImagesToFile()      % save images

calibrateCamera()
saveToFile()
plotData()



%% helping functions
    function loadImagesFromFolder(folder)
        if folder(end) == '/'
            folder = folder(1:end-1);
        end
        
        if isempty(folder)
            % find most up to date folder
            dirs = dir(RootFolder);
            dirs = dirs(3:numel(dirs));
            validStr = '';
            validDate = 0;
            val = regexp({dirs.name}, '\d{4}-\d{2}-\d{2}_\d{2}-\d{2}');
            for i = 1:numel(val)
                if ~isempty(val{i}) && val{i} == 1 && validDate < dirs(i).datenum
                    validStr = dirs(i).name;
                    validDate = dirs(i).datenum;
                end
            end
            if validDate > 0
                folder = validStr;
            end
        end
        
        if isdir(folder)
            try
                i = 0;
                tmpRight = load([folder '/calibImg_Right_01.tif']);
                tmpLeft = load([folder '/calibImg_Left_01.tif']);
                i = 1;
                sRight = [size(tmpRight) 1];
                sLeft = [size(tmpLeft) 1];
                sRight(1,4) = nImages;
                sLeft(1,4) = nImages;
                imgCheckerboardsRight = zeros(sRight);
                imgCheckerboardsLeft = zeros(sLeft);
                for i = 2:nImages
                    imgCheckerboardsRight(:,:,:,i) = load([folder 'calibImg_Right'...
                        num2str(i, '%02d') '.tif']);
                    imgCheckerboardsLeft(:,:,:,i) = load([folder 'calibImg_Left'...
                        num2str(i, '%02d') '.tif']);
                end
            catch
                imgCheckerboardsRight = imgCheckerboardsRight(:,:,:,1:i);
                imgCheckerboardsLeft = imgCheckerboardsLeft(:,:,:,1:i);
            end
        else
            error(['automaticCalibration: specified folder does not exist: ' folder])
        end
    end



    function saveImagesToFile()
        % save checkerboard images
        imgCheckerboardsRight = cast(imgCheckerboardsRight,'uint8');
        imgCheckerboardsLeft = cast(imgCheckerboardsLeft,'uint8');
        for i = 1:nImages
            imgFileNameRight = [subFolder '/calibImg_Right_' num2str(i, '%02d') '.tif'];
            imgFileNameLeft = [subFolder '/calibImg_Left_' num2str(i, '%02d') '.tif'];
            imwrite(imgCheckerboardsRight(:,:,i), imgFileNameRight);
            imwrite(imgCheckerboardsLeft(:,:,i), imgFileNameLeft);
        end
               
    end



    function saveToFile()
               
        % save camera parameters
        save([calibrationFolder '/stereoCameraParams.mat'], 'stereoCameraParams')
        save([RootFolder '/stereoCameraParams.mat'], 'stereoCameraParams')
        
    end

    function calibrateCamera()
        % detect checkerboards in images
        [imagePoints, boardSize, pairsUsed] = detectCheckerboardPoints(imgCheckerboardsRight,imgCheckerboardsLeft);
       
        
        % remove unused images
        imgCheckerboardsRight = imgCheckerboardsRight(:,:,:,pairsUsed);
        imgCheckerboardsLeft = imgCheckerboardsLeft(:,:,:,pairsUsed);
       
        nImages = sum(pairsUsed);
       
        
        % world points of the checkerboard pattern
        squareSize = 31; % in units of 'mm'
        worldPoints = generateCheckerboardPoints(boardSize, squareSize);
        
        
        % calibrate the camera                          
        stereoCameraParams = estimateCameraParameters(imagePoints,worldPoints);%, ...
          %  'EstimateSkew', true, 'EstimateTangentialDistortion', true, ...
           % 'NumRadialDistortionCoefficients', 3, 'WorldUnits', 'mm');
        
        
       
    end

   

%% GUI
    function gui_getFrames()
        hFig = figure('Name', 'Preview Window - Position the object!');
        hBtnCalc = uicontrol('String', 'calculate',...                      % add a close button to the figure
            'Position', [0 0 120 20], 'Callback', @startCalc);
        hBtnImg = uicontrol('String', 'getImage',...                        % button to aquire new image
            'Position', [130 0 120 20], 'Callback', @getImage);
        uicontrol('String', 'abort', 'Position', [260 0 120 20],...         % button to abort the function
            'Callback', @abortClick);
        % first image
       
        subplot(121);
        hImageRight = image(zeros(vidResRight(2), vidResRight(1), nBandsRight));
        set(gca, 'Visible', 'off');
        
        axis equal;
        srcRight.VerticalFlip = 'on';
        preview( vidRight,hImageRight);
        % second image
        subplot(122);
        hImageLeft = image(zeros(vidResLeft(2), vidResLeft(1), nBandsLeft));
        set(gca,'Visible','off');
        
        axis equal;
        srcLeft.VerticalFlip = 'on';
        preview(vidLeft, hImageLeft);
                 
        
       
        
        uiwait(hFig);
        if abort
            stereoCameraParams = -1;
          
            return
        end
    end



%% GUI-Callbacks
% function to aquire the images
    function getImage(~,~)
        set([hBtnCalc hBtnImg], 'Enable', 'off');
        show_message(['---- Image ' num2str(curImageCount) ' of ' ...
            num2str(nImages) ' (max) ----']);
        show_message('image aquisition without laser started');
        imagesRefRight = getFrame(srcRight,vidRight,expTime);%aquireImage(vid, 'Callback', @(~) ~abort);
        imagesRefLeft = getFrame(srcLeft,vidLeft,expTime);
        if abort
            show_message('function aborted')
            return
        end
        if nBandsRight > 1
            imagesRefRight = rgb2gray(imagesRefRight);%squeeze(mean(imagesRef, 3));            % reduce to gray color if true color image
        end   
        if nBandsLeft > 1
            imagesRefLeft = rgb2gray(imagesRefLeft);
        end
       
        
        imgCheckerboardsRight(:,:,1,curImageCount) = imagesRefRight;
        imgCheckerboardsLeft(:,:,1,curImageCount) = imagesRefLeft;
        
        
        if (curImageCount == nImages)
            close(hFig);
            return;
        end
        
        set([hBtnCalc hBtnImg], 'Enable', 'on')
        curImageCount = curImageCount + 1;
    end

% aborting operation
    function abortClick(~,~)
        abort = true;
        close(hFig)
    end

% stop image aquisition and start calculation
    function startCalc(~,~)
        close(hFig)
        nImages = curImageCount-1;
        imgCheckerboardsRight = imgCheckerboardsRight(:,:,:,1:nImages);
        imgCheckerboardsLeft = imgCheckerboardsLeft(:,:,:,1:nImages);
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

    

 function plotData()
        % view reprojection errors
        figure
        showReprojectionErrors(stereoCameraParams, 'BarGraph');
        
        % visualize pattern locations including laser plane
        figure
        showExtrinsics(stereoCameraParams);%, 'PatternCentric');
        
    end
end






