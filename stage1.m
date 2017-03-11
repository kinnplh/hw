
mainPaths = getfilepaths('tem/');
 for fileId = 1: length(mainPaths)
% for fileId = 1: 5
    tic
    
    
    frameVector = Vector('Frame');
    path = mainPaths(fileId)
   
    [time, model, isReported, reportedID, x, y, ~,label ,cap]...
        = textread(cell2mat(path), '%n%s%s%n%n%n%s%s%s','delimiter', ',');
    
    firstReport = find(x > 0);
    firstReport = firstReport(1);
    l = cell2mat(label(firstReport));
    if strcmp(l, 'MOVEBIG') || strcmp(l, 'SWIPEMID') || strcmp(l, 'SWIPEEDGE')
        MAX_MOVE_BTW_FRAME = 50;
    else
        MAX_MOVE_BTW_FRAME = 10;
    end
    
    
    
    
    fileLineNum = length(time);
    TUFV = Vector('Frame');
    
    for i = 1: fileLineNum     
        crtFrame = Frame...
            (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), label(i), cap(i), frameVector.size() + 1, path);
        if ~crtFrame.isValid
            continue;
        end
        if frameVector.size() == 0
            frameVector.push_back(crtFrame);
            continue;
        end
        
        % ����ʵ����������Ǻ�frameVector�����һ��Ԫ�غϲ���������Ϊ��Ԫ�ؼ���
        if frameVector.size() > 0 && frameVector.last().time == crtFrame.time
            frameVector.last().merge(crtFrame);
        elseif ~isempty(crtFrame.touchIDs)
            if TUFV.size() == 0
                frameVector.push_back(crtFrame);
            else % �ж�������TUFV�е�֡�Ƿ���Ҫ������
                %�ж���֮֡���������
                %ʵ�������ж�ǰһ֡����һ֡��ͬ��touchId֮��Ĺ�ϵ
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
                        frameVector.push_back(crtFrame);
                        TUFV.clear();
                    end
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

    
    for index = 1: frameVector.size() % ��֤ID����ȷ��
        frameVector.at(index).ID = index;
    end
        
    savePath = sprintf('./frameVectors/frameVector%d_tem.mat', fileId);
    save(savePath, 'frameVector');
    toc
end
    % ��һ�׶δ������������ɵ���ֻ��ԭʼ���ݵ�֡������
    %**************************************************************************
    