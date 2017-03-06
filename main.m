% ���������г������ļ��Ĵ�������
%tic
% frameVector = Vector('Frame');
% 
% %path = '/Volumes/Hello/��Ϊ/data/cyz/parse/output4.txt';
%  path = 'output2.txt';
%  fileId = 1;% �ļ��ı��
% fid = fopen(path);
% 
% 
% [time, model, isReported, reportedID, x, y, isPositive,label, cap]...
%     = textread(path, '%n%s%s%n%n%n%s%s%s','delimiter', ',');
% 
% fileLineNum = length(time);
% 
% for i = 1: fileLineNum
%     
%     crtFrame = Frame...
%         (time(i), model(i), isReported(i), reportedID(i), x(i), y(i), isPositive(i),label(i), cap(i), frameVector.size() + 1);
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
% mkdir('./frameVectors');
% mkdir('./frameVectorsFlooded');
% mkdir('./areas');
% mkdir('./touchEvents');
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

%�����׶�ά��globalData���������ݰ�֡ι��OnFrameReceived�����ж�
%modified by Violynne

%tic
globalData = GD(frameVector, touchEventVector, areaVector);

global truelist;
global falselist;

truelist = Vector('TouchEvent');
falselist = Vector('TouchEvent');
%��һ�����������down֡���Ǹ�event�����һ֡���������down֡�ж�������Uncertain��evt�ͻᱣ�����״̬
%����������������Ӧ�ý�֮ͳһ��ΪFalse

while globalData.hasNextFrame()
    crtFrame = globalData.getNextFrame();
    OnFrameReceived(globalData,crtFrame);
end


%�����׶δ���������õ�truelist��falselist
%**************************************************************************

%���Ľ׶ζԵõ��ķ��������в���
%modified by Violynne

truerecord = [];
trueoutput = [];
falserecord = [];
falseoutput = [];
TP = 0;
FP = 0;
TN = 0;
FN = 0;


for i=1:truelist.size()
    evt = truelist.at(i);
    
    %�б����event�����label�ǣ�
    checkarea = globalData.areas.at(evt.firstReportedAreaID);
    checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
    checkindex = find(checkframe.touchIDs==checkarea.reportID);
    checklabel = checkframe.labels.at(checkindex);
   
    %checklabel�Ǿŷ��� ��Ҫת��Ϊ������
    if(isequal(checklabel{1},TOUCHEDGE)||isequal(checklabel{1},TOUCHNEAR)||isequal(checklabel{1},TOUCHMID)||isequal(checklabel{1},SWIPEMID)||isequal(checklabel{1},SWIPEEDGE))
        TP = TP + 1;
    else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
        FP = FP + 1;
    end
    
    %ͬʱ��¼�������ϵͳdown����ʱ��:
    timedelay = crtFrame.time - checkframe.time;
    
    %�洢ÿ��event������Ϣ�Ա�֮�����
    truerecord = [evt.ID,evt.state,checklabel,timedelay];
    trueoutput = [trueoutput;truerecord];
end

for i=1:falselist.size()
    evt = falselist.at(i);
    evt.state = TouchEvent.False;
    
    %�б����event�����label�ǣ�
    checkarea = globalData.areas.at(evt.firstReportedAreaID);
    checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
    checkindex = find(checkframe.touchIDs==checkarea.reportID);
    checklabel = checkframe.labels.at(checkindex);
    
    %checklabel�Ǿŷ��� ��Ҫת��Ϊ������
    if(isequal(checklabel{1},TOUCHEDGE)||isequal(checklabel{1},TOUCHNEAR)||isequal(checklabel{1},TOUCHMID)||isequal(checklabel{1},SWIPEMID)||isequal(checklabel{1},SWIPEEDGE))
        TN = TN + 1;
    else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
        FN = FN + 1;
    end
   
    %ͬʱ��¼�������ϵͳdown����ʱ��:
    timedelay = crtFrame.time - checkframe.time;
    
    %�洢ÿ��event������Ϣ�Ա�֮�����
    falserecord = [evt.ID,evt.state,checklabel,timedelay];
    falseoutput = [falseoutput;falserecord];
end

%trueoutput
%falseoutput

[TP,FP,TN,FN]
eventsum = TP+FP+TN+FN
accuracy = TP/(TP+TN)
callback = FN/(FN+FP)
F1score = 2 / (1 / accuracy + 1 / callback)
%toc

%���Ľ׶δ���������õ�����ֵ��trueoutput falseoutput�����ں��ڷ���