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
        % ����ʵ����������Ǻ�frameVector�����һ��Ԫ�غϲ���������Ϊ��Ԫ�ؼ���
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

% ��һ�׶δ�����������ɵ���ֻ��ԭʼ���ݵ�֡������
%**************************************************************************

    lastAreaIds = [];
    areaVector = Vector('Area');
    touchEventVector = Vector('TouchEvent');
    
    for i = 1: frameVector.size()
        newAreaIds = frameVector.at(i).flooding(areaVector, frameVector);
        % ����lastAreaIds����һ֡�����е�Area��ţ��� newAreaIds ȷ�����ӹ�ϵ
        lastAreaIds = Area.connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector);
    end
    
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    save(savePath, 'frameVector');% ���ڵ�frameVector�Ѿ��������㹻����Ϣ��������֡������в���
    savePath = sprintf('./areas/areaVector%d.mat', fileId);
    save(savePath, 'areaVector');
    savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    save(savePath, 'touchEventVector');
    
end