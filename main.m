% ���������г������ļ��Ĵ�������
%tic
%frameVector = Vector('Frame');
% 
% %path = '/Volumes/Hello/��Ϊ/data/cyz/parse/output4.txt';
 path = 'output4.txt';
 fileId = 1;% �ļ��ı��
% fid = fopen(path);
% 
% 
% [time, model, isReported, reportedID, x, y, label, cap]...
%     = textread(path, '%n%s%s%n%n%n%s%s','delimiter', ',');
% 
% fileLineNum = length(time);
% 
% for i = 1: fileLineNum
%     
%     crtFrame = Frame...
%         (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), label(i), cap(i), frameVector.size() + 1);
%     if ~crtFrame.isValid
%         continue;
%     end
%     % ����ʵ����������Ǻ�frameVector�����һ��Ԫ�غϲ���������Ϊ��Ԫ�ؼ���
%     if frameVector.size() > 0 && frameVector.last().time == crtFrame.time
%         frameVector.last().merge(crtFrame);
%     else
%         frameVector.push_back(crtFrame);
%     end
% end
% 
% savePath = sprintf('./frameVectors/frameVector%d.mat', fileId);
% save(savePath, 'frameVector');

% ��һ�׶δ�����������ɵ���ֻ��ԭʼ���ݵ�֡������
%**************************************************************************

% lastAreaIds = [];
% areaVector = Vector('Area');
% touchEventVector = Vector('TouchEvent');
% for i = 1: frameVector.size()
%     newAreaIds = frameVector.at(i).flooding(areaVector, frameVector);
%     % ����lastAreaIds����һ֡�����е�Area��ţ��� newAreaIds ȷ�����ӹ�ϵ
%     lastAreaIds = Area.connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector);
% end
% savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
% save(savePath, 'frameVector');% ���ڵ�frameVector�Ѿ��������㹻����Ϣ��������֡������в���
% savePath = sprintf('./areas/areaVector%d.mat', fileId);
% save(savePath, 'areaVector');
% savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
% save(savePath, 'touchEventVector');
% 
% toc

% �ڶ��׶δ�����������ɵ��Ǿ����鷺��֡�����У����е�area�����е�touchEvent����ͨ����ָ�롱����ʽ����
%**************************************************************************

%�����׶ο��Խ��в��ԣ�Ҳ���Ը���TouchEvent���е���
tic
globalData = GD(frameVector, touchEventVector, areaVector);
while globalData.hasNextFrame()
    crtFrame = globalData.getNextFrame();
    % OnFrameReceived(crtFrame);
end
toc