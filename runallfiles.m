mainPaths = getfilepaths('data/');

for fileId = 1: length(mainPaths)
    frameVector = Vector('Frame');
    path = cell2mat(mainPaths(fileId))


    [time, model, isReported, reportedID, x, y, isPositive,label, cap]...
        = textread(path, '%n%s%s%n%n%n%s%s%s','delimiter', ',');

    fileLineNum = length(time);

    for i = 1: fileLineNum

        crtFrame = Frame...
            (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), isPositive(i),label(i), cap(i), frameVector.size() + 1);
        if ~crtFrame.isValid
            continue;
        end
        % 根据实际情况决定是和frameVector的最后一个元素合并，还是作为新元素加入
        if frameVector.size() > 0 && frameVector.last().time == crtFrame.time
            frameVector.last().merge(crtFrame);
        else
            frameVector.push_back(crtFrame);
        end
    end
    
    mkdir('./frameVectors');
    mkdir('./frameVectorsFlooded');
    mkdir('./areas');
    mkdir('./touchEvents');
    mkdir('./predictlists');
    mkdir('./predictrecords');

    savePath = sprintf('./frameVectors/frameVector%d.mat', fileId);
    save(savePath, 'frameVector');

% 第一阶段处理结束，生成的是只有原始数据的帧的序列
%**************************************************************************

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
    
end