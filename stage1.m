
mainPaths = getfilepaths('data/');
for fileId = 1: length(mainPaths)
    tic
    frameVector = Vector('Frame');
    path = mainPaths(fileId)
   
    [time, model, isReported, reportedID, x, y, label, cap]...
        = textread(cell2mat(path), '%n%s%s%n%n%n%s%s','delimiter', ',');

    fileLineNum = length(time);
    TUFV = Vector('Frame');
    
    for i = 1: fileLineNum

        crtFrame = Frame...
            (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), label(i), cap(i), frameVector.size() + 1, path);
        if ~crtFrame.isValid
            continue;
        end
        % 根据实际情况决定是和frameVector的最后一个元素合并，还是作为新元素加入
        if frameVector.size() > 0 && frameVector.last().time == crtFrame.time
            frameVector.last().merge(crtFrame);
        elseif ~isempty(crtFrame.touchIDs) 
            frameVector.push_back(crtFrame);
            TUFV.clear();
        else % unreported
            if isempty(frameVector.last().touchIDs)
                frameVector.push_back(crtFrame);
            else
                if crtFrame.time - frameVector.last().time >= Consts.MAX_UNREPORTED_TIME
                    frameVector.merge(TUFV);
                    frameVector.push_back(crtFrame);
                    TUFV.clear();
                else
                    TUFV.push_back(crtFrame);
                end
            end
        end
    end

        
    savePath = sprintf('./frameVectors/frameVector%d.mat', fileId);
    save(savePath, 'frameVector');
    toc
end
    % 第一阶段处理结束，生成的是只有原始数据的帧的序列
    %**************************************************************************
    