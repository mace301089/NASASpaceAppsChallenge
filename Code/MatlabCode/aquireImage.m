function [Img, exposureTimes, images ] = aquireImage(vid, varargin)
%%AQUIREHDR aquires multiple frames with different exposure times and
% calculates an hdr image.
%
% @Param:
%   vid:                Handle to the camera video object
%                       (returned by videoinput(...)).
%
% Optional Parameter (as ParameterName-ParameterValue pairs):
%   'Frames2Mean'       Integer > 0, specifies how many frames are taken
%                       per exposure time.
%
%   'Callback'          Function handle to a callback routine that gets one
%                       value x, with 0<=x<=1, that shows the progress and
%                       returns true if aquireHDR is allowed to continue
%                       aquisition of the exposure series. If optional
%                       parameter are required use a cell array with first
%                       element being the function handle and other
%                       elements being additional parameters.
%
%   'ExposureTimeList'  Array with a list of exposure values for explicitly
%                       defining the values (no automation).
%
%   'ExposureStartValue'
%                       Scalar value defining the start exposure value
%                       (smallest value) for the exposure series.
%                       Ignored if 'ExposureTimeList' is used. Values are
%                       clipped to the valid range.
%
%   'ExposureEndValue'  Scalar value defining the end exposure value
%                       (largest value) for the exposure series.
%                       Ignored if 'ExposureTimeList' is used. Values are
%                       clipped to the valid range.
%
%   'NumberOfFrames'    Scalar integer value defining the maximum number of
%                       frames to be taken for the exposure series. The
%                       exposure value starts with 'ExposureStartValue' or
%                       the maximum exposure value until the specified 
%                       number of frames is reached. Minimum is 4!
%                       Ignored if 'ExposureTimeList' is used.
%
%   'CameraProperties'  [m by 2] cell array with m camera properties
%                       (set(getselectedvideosource(vid), ParamName, ParamValue))
%                       to be set before the exposure series is aquired.
%                       Camera properties are given as ParameterName-
%                       ParameterValue pair. Camera parameters are returned
%                       to previous state after the aquisition.
%
% @Return:
%   Img:             Calculated hdr image.
%
%   exposureTimes:      1*k vector of the exposure times (same order as the
%                       images).
%
%   images:             n*m*k OR n*m*b*k array of images where n and m are
%                       the image dimensions, b is the number of bands
%                       (i.e. 3 => color images) and k is the number of
%                       images taken.
%
% examples for calling aquireHDR:
%   hdrImage = aquireHDR(vid);
%
%   hdrImage = aquireHDR(vid, 'Frames2Mean', 10);
%   10 frames per exposure time are averaged.
%
%   hdrImage = aquireHDR(vid, 'CameraProperties', {'Gain', 10});
%   Adjusting camera gain for the exposure series.
%
%   [hdrImage, images, expTimes] = aquireHDR(vid, ...);
%
%
% Author:
%   Stephan Seidel
%   script to function: Tim Elberfeld
%   modifications and speed up: Andrej Wentnagel
%
% History
%   02.05.2014 -    Script
%   09.05.2014 -    Made script into function, minor tweaks
%   18.05.2014 -    Change the exposure time array to 2^expTime, because of
%                   images2hdr()
%   23.05.2014 -    Added -1 as speacial case for nofFrames for taking as 
%                   many images as the range of exposure times allows.
%              -    Also added clipping for nOfFrames (if nOfFrames is >
%                   than the range of exposure times, the value is
%                   truncated)
%   15.06.2014 -    Modified preallocation of images variable for dynamic
%                   adjusting to the video source size and number of bands.
%              -    Added check to set only available source parameters
%                   (compatability with different cameras / camera
%                   adaptors). 
%              -    Added input parameter check.
%              -    Changed to run without getsnapshot(vid) and averaging
%                   over 10 frames for one exposure value (same speed as
%                   with getsnapshot without averaging). AW
%   20.06.2014 -    Bugfixes with integertype.
%   03.07.2014 -    frames2mean included. AW
%   14.08.2014 -    Rewritten. AW
%   15.08.2014 -    Inline hadr stitching -> reduced ram footprint when
%                   output parameter images is unused. AW
%   03.09.2014 -    Added optional parameter support for Callback. AW
%	07.12.2014 - 	Fixed proper clean up of camera parameters after
%					abortion. AW
%


%%
%function code

    % ----  default parameter values  ----
    frames2mean = 4;
    Callback = @(x) true;
    expTimeListMode = 'auto';
    expTimeList = [];
    expStartValMode = 'auto';
    expStartVal = 0;
    expEndValMode = 'auto';
    expEndVal = 0;
    nOfFrames = 100;
    prop2change = {                                             % default list of parameters and
        'ExposureMode', 'manual';                               %   values to be set to aquire hdr
        'BrightnessMode', 'manual';                             %   image series
        'ContrastMode', 'manual';
        'GainMode', 'manual';
        'BacklightCompensation', 'off';
        'Gain', 1;
        'Contrast', 0;
        'Brightness', 0};
    
    
    % ----  init  ----
    readInput()
    camSwitchMode = 'set';
    old_trigMode = get(vid, 'TriggerType');
    old_framPerTrig = vid.FramesPerTrigger;
    
    src = getselectedsource(vid);
    srcProp = propinfo(src);
    
    expValType = srcProp.Exposure.Type;
    if( strcmp(expValType,'integer') )
        expValType = 'int32';                                   % for supported data type conversion
    end                                                         %   ('integer' does not exist)
    
    mm = srcProp.Exposure.ConstraintValue;                      % border of possible exposure values
    expMin = mm(1);
    expMax = mm(2);
    
    auto_startVal = strcmp(expStartValMode, 'auto');
    auto_endVal = strcmp(expEndValMode, 'auto');
    auto_timeList = strcmp(expTimeListMode, 'auto');
    
    % ----  parameter check  ----
    if auto_timeList
        if auto_startVal
            expStartVal = expMin;
        else
            expStartVal = min(max(expStartVal, expMin), expMax);% enforce boundries
            expStartVal = cast(expStartVal, expValType);        % enforce type
        end
        if auto_endVal
            expEndVal = expMax;
        else
            expEndVal = min(max(expEndVal, expMin), expMax);
            expEndVal = cast(expEndVal, expValType);
        end
        if ~auto_startVal && ~auto_endVal
            t = max(expStartVal, expEndVal);                    % enforce expStartVal < expEndVal
            expStartVal = min(expStartVal, expEndVal);
            expEndVal = t;
        end
    else
        if all(expTimeList > expMax | expTimeList < expMin)
            error(['aquireHDR: no exposure times are in valid range [' ...
                num2str(expMin, '%3d') ',' num2str(expMax, '%3d') ']'])
        else
            expTimeList = cast(expTimeList, expValType);        % enforce type
            expTimeList = min(max(expTimeList, expMin), expMax);% enforce boundries
            expTimeList = unique(expTimeList);
        end
    end
    
    
   
    
    
    % ----  set camera parameters (to manual for full control)  ----
    switchCameraParameter()
    
    
    % ----  alloc the array for images  ----
    vidRes = get(vid, 'VideoResolution');
    noB = get(vid, 'NumberOfBands');
    Img = zeros([vidRes(2), vidRes(1), noB]);
    pixWeight = zeros(size(Img));
    if nargout > 2
        images = squeeze(zeros([vidRes(2), vidRes(1), noB, nOfFrames]));
        if noB > 1, setImg = @insert4d;
        else setImg = @insert3d; end
    else
        setImg = @(i,x) i;
    end
  
    
  
    % ----  reset camera parameter  ----
    switchCameraParameter()
    
    
 
%% 
    function readInput()
        k = 1;
        while k < numel(varargin)
            switch 1
            case strcmp(varargin{k}, 'Frames2Mean') && ...
                    isa(varargin{k+1}, 'numeric')
                frames2mean = max(varargin{k+1}, 1);
            case strcmp(varargin{k}, 'Callback')
                if isa(varargin{k+1}, 'function_handle')
                    Callback = @(x) clean_return(varargin{k+1}, x);
                elseif isa(varargin{k+1}, 'cell') && ...
                        isa(varargin{k+1}{1}, 'function_handle')
                    Callback = @(x) clean_return(varargin{k+1}{1}, x, ...
                        varargin{k+1}{2:end});
                end
            case strcmp(varargin{k}, 'ExposureTimeList') && ...
                    isa(varargin{k+1}, 'numeric')
                expTimeListMode = 'manual';
                expTimeList = varargin{k+1};
            case strcmp(varargin{k}, 'ExposureStartValue') && ...
                    isa(varargin{k+1}, 'numeric') && isscalar(varargin{k+1})
                expStartValMode = 'manual';
                expStartVal = varargin{k+1};
            case strcmp(varargin{k}, 'ExposureEndValue') && ...
                    isa(varargin{k+1}, 'numeric') && isscalar(varargin{k+1})
                expEndValMode = 'manual';
                expEndVal = varargin{k+1};
            case strcmp(varargin{k}, 'NumberOfFrames') && ...
                    isa(varargin{k+1}, 'numeric') && varargin{k+1} > 0
                nOfFrames = varargin{k+1};
            case strcmp(varargin{k}, 'CameraProperties') && ...
                    isa(varargin{k+1}, 'cell') && numel(varargin{k+1}) > 0
                tmp = varargin{k+1};
                include = true([size(tmp, 1), 1]);
                m = 1;
                while m <= size(tmp, 1)
                    for n = 1:size(prop2change, 1)
                        if strcmp(prop2change{n,1}, tmp{m,1})
                            prop2change{n,2} = tmp{m,2};
                            include(m) = false;
                        end
                    end
                    m = m+1;
                end
                prop2change = [prop2change; tmp(include,:)];
            end
            k = k+2;
        end
    end

    function switchCameraParameter()
        if strcmp(camSwitchMode, 'set')
            vid.FramesPerTrigger = frames2mean;
            triggerconfig(vid, 'immediate');
            camSwitchMode = 'reset';
        else
            vid.FramesPerTrigger = old_framPerTrig;
            triggerconfig(vid, old_trigMode);
            camSwitchMode = 'set';
        end
        for k = 1:size(prop2change, 1)
            if isfield(srcProp, prop2change{k,1})                   
                tmp = get(src, prop2change{k,1});
                set(src, prop2change{k,1}, prop2change{k,2})
                prop2change{k,2} = tmp;
            end
        end
    end
    
    function cont = clean_return(fcn, val, opt)
        if nargin < 3
            cont = fcn(val);
        else
            cont = fcn(val, opt);
        end
        if ~cont
            Img = -1;
            images = -1;
            exposureTimes = -1;
        end
    end

    function out = getFrame(expVal)
        src.Exposure = expVal;                                      % update exposure time
        flushdata(vid)                                              % remove old data
        start(vid)                                                  % start aquisition
        wait(vid)                                                   % wait to finish aquisition
        stop(vid)                                                   % stop aquisition
        out = getdata(vid, frames2mean, 'double');                  % get frame
        out = sum(out, 4)/frames2mean;                              % mean of frames
    end

    function insert4d(i, x)
        images(:,:,:,i) = x;
    end

    function insert3d(i, x)
        images(:,:,i) = x;
    end 
end




