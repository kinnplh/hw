    
mainPaths = getfilepaths('edge/');
load('./ClassifierPara/max_X.mat');
load('./ClassifierPara/max_Y.mat');
load('./ClassifierPara/Poss_SMOOTH.mat');
load('./ClassifierPara/step.mat');
 for fileId = 1: length(mainPaths)
% for fileId = 1: 1
    tic
    path = mainPaths(fileId)
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d_temedge.mat', fileId);
    load(savePath);
    savePath = sprintf('./areas/areaVector%d_temedge.mat', fileId);
    load(savePath);
    savePath = sprintf('./touchEvents/touchEventVector%d_temedge.mat', fileId);
    load(savePath);    
    
    totalFrameSize = frameVector.size();
    
    gd = GD(frameVector, touchEventVector, areaVector);
    
    clsf = Classifier(Poss_SMOOTH, step, max_X, max_Y);
    for i = 1: totalFrameSize
        crtFrame = frameVector.at(i);
        OnFrameReceived(crtFrame, gd, clsf);
    end
    
    testResultVector = clsf.testResultVector;
    savePath = sprintf('./testResultsOnlyDown/testResultVector%dedge.mat', fileId);
    save(savePath, 'testResultVector');
    toc
end