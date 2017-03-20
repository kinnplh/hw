    
mainPaths = getfilepaths('data/');
for fileId = 1: length(mainPaths)
% for fileId = 1: 5
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
    
    
    for i = 1: totalFrameSize
        crtFrame = frameVector.at(i);
        for j = 1: length(crtFrame.areaIDs)
            res = [res; Classifier.areaReceivedForStat(areaVector.at(crtFrame.areaIDs(j)), gd)];
        end
    end
    
    
    toc
end
save('res.mat', 'res') 