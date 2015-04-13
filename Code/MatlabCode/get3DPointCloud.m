function [ pointCloud, imgLeftRect, imgRightRect ] = get3DPointCloud( imgLeft, imgRight, stereoParams)
    [imgLeftRect, imgRightRect] = rectifyStereoImages(imgLeft, imgRight, stereoParams,...
        'interp','cubic');
    disparityMap = disparity(imgLeftRect,imgRightRect,...
        'BlockSize', 5,'DisparityRange', [-2 14], 'Method','SemiGlobal');
    pointCloud = reconstructScene(disparityMap,stereoParams);
end

