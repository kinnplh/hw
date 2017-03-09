   
mainPaths = getfilepaths('data/');
% for fileId = 1: length(mainPaths)
for fileId = 1: 1
    tic
    path = mainPaths(fileId)
    savePath = sprintf('./frameVectors/frameVector%d.mat', fileId);   % might be quite slow in fact
    load(savePath);
    lastAreaIds = [];
    areaVector = Vector('Area');
    touchEventVector = Vector('TouchEvent');
    for i = 1: frameVector.size()
        newAreaIds = frameVector.at(i).flooding(areaVector, frameVector);
        % 根据lastAreaIds（上一帧上所有的Area编号）和 newAreaIds 确认连接关系
        lastAreaIds = Area.connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector);
    end
    
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    save(savePath, 'frameVector');% 现在的frameVector已经包含了足够的信息，可以逐帧输出进行测试
    savePath = sprintf('./areas/areaVector%d.mat', fileId);
    save(savePath, 'areaVector');
    savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    save(savePath, 'touchEventVector');

    toc
end