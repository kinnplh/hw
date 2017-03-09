    
mainPaths = getfilepaths('data/');
% for fileId = 1: length(mainPaths)
for fileId = 1: 1
    tic
    path = mainPaths(fileId)
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    load(savePath);
    savePath = sprintf('./areas/areaVector%d.mat', fileId);
    load(savePath);
    savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    load(savePath);    
    
    totalFrameSize = frameVector.size();
    
    gd = GD(frameVector, touchEventVector, areaVector);
    
    clsf = Classifier();
    for i = 1: totalFrameSize
        crtFrame = frameVector.at(i);
        OnFrameReceived(crtFrame, gd, clsf);
    end
    
    testResultVector = clsf.testResultVector;
    savePath = sprintf('./testResultsSimple/testResultVector%d.mat', fileId);
    save(savePath, 'testResultVector');
    toc
end