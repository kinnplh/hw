   
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
        % ����lastAreaIds����һ֡�����е�Area��ţ��� newAreaIds ȷ�����ӹ�ϵ
        lastAreaIds = Area.connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector);
    end
    
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    save(savePath, 'frameVector');% ���ڵ�frameVector�Ѿ��������㹻����Ϣ��������֡������в���
    savePath = sprintf('./areas/areaVector%d.mat', fileId);
    save(savePath, 'areaVector');
    savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    save(savePath, 'touchEventVector');

    toc
end