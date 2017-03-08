    
mainPaths = getfilepaths('data/');
for fileId = 1: length(mainPaths)
    tic
    path = mainPaths(fileId)
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    load(savePath);
    savePath = sprintf('./areas/areaVector%d.mat', fileId);
    load(savePath);
    savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    load(savePath);    
    
    globalData = GD(frameVector, touchEventVector, areaVector);
    
    while globalData.hasNextFrame()
        crtFrame = globalData.getNextFrame();
        % OnFrameReceived(crtFrame);
    
    end
    toc
end