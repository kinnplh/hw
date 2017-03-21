
mainPaths = getfilepaths('edge/');
 for fileId = 1: length(mainPaths)
% for fileId = 1: 5
    tic
    
    
    frameVector = Vector('Frame');
    path = mainPaths(fileId)
   
    [time, model, isReported, reportedID, x, y,label ,cap]...
        = textread(cell2mat(path), '%n%s%s%n%n%n%s%s','delimiter', ',');
    
    firstReport = find(x > 0);
    firstReport = firstReport(1);
    l = cell2mat(label(firstReport));
    if strcmp(l, 'SLIDE') || strcmp(l, 'DRAG')
        MAX_MOVE_BTW_FRAME = 50;
    else
        MAX_MOVE_BTW_FRAME = 10;
    end
    
    
    
    
    fileLineNum = length(time);
    TUFV = Vector('Frame');
    
    for i = 1: fileLineNum    
        if time(i) == 6475
            
            
        end
        crtFrame = Frame...
            (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), label(i), cap(i), frameVector.size() + 1, path);
        if ~crtFrame.isValid
            continue;
        end
        if frameVector.size() == 0
            frameVector.push_back(crtFrame);
            continue;
        end
        
        % 根据实际情况决定是和frameVector的最后一个元素合并，还是作为新元素加入
        if frameVector.size() > 0 && frameVector.last().time == crtFrame.time
            frameVector.last().merge(crtFrame);
        elseif ~isempty(crtFrame.touchIDs)
            if TUFV.size() == 0
                frameVector.push_back(crtFrame);
            else % 判断现在在TUFV中的帧是否需要被丢掉
                %判断两帧之间的连续性
                %实际上是判断前一帧和这一帧相同的touchId之间的关系
                index = find(frameVector.last().touchIDs == crtFrame.touchIDs);
                
                if isempty(index)
                    frameVector.merge(TUFV);
                    frameVector.push_back(crtFrame);
                    TUFV.clear();
                else
                    crtRep = crtFrame.touchPosPixel.first();
                    lastRep = frameVector.last().touchPosPixel.at(index);
                    if crtRep.disTo(lastRep) <= MAX_MOVE_BTW_FRAME
                        TUFV.clear();
                    else
                        frameVector.merge(TUFV);
                        TUFV.clear();
                    end
                    frameVector.push_back(crtFrame);
                end
            end
            
        else % unreported
            if isempty(frameVector.last().touchIDs)
                frameVector.push_back(crtFrame);
                assert(TUFV.size() == 0);
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

    
    for index = 1: frameVector.size() % 保证ID是正确的
        frameVector.at(index).ID = index;
    end
        
    savePath = sprintf('./frameVectors/frameVector%dedge.mat', fileId);
    save(savePath, 'frameVector');
    toc
end
    % 第一阶段处理结束，生成的是只有原始数据的帧的序列
    %**************************************************************************
    