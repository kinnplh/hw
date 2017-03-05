% 这里大概罗列出单个文件的处理流程
%tic
% frameVector = Vector('Frame');
% 
% %path = '/Volumes/Hello/华为/data/cyz/parse/output4.txt';
%  path = 'output2.txt';
%  fileId = 1;% 文件的编号
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
%     % 根据实际情况决定是和frameVector的最后一个元素合并，还是作为新元素加入
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

% 第一阶段处理结束，生成的是只有原始数据的帧的序列
%**************************************************************************

% lastAreaIds = [];
% areaVector = Vector('Area');
% touchEventVector = Vector('TouchEvent');
% for i = 1: frameVector.size()
%     newAreaIds = frameVector.at(i).flooding(areaVector, frameVector);
%     % 根据lastAreaIds（上一帧上所有的Area编号）和 newAreaIds 确认连接关系
%     lastAreaIds = Area.connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector);
% end
% savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
% save(savePath, 'frameVector');% 现在的frameVector已经包含了足够的信息，可以逐帧输出进行测试
% savePath = sprintf('./areas/areaVector%d.mat', fileId);
% save(savePath, 'areaVector');
% savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
% save(savePath, 'touchEventVector');
% 
% toc

% 第二阶段处理结束，生成的是经过洪泛的帧的序列，所有的area和所有的touchEvent，并通过“指针”的形式相连
%**************************************************************************

%第三阶段可以进行测试，也可以根据TouchEvent进行调试
%tic
globalData = GD(frameVector, touchEventVector, areaVector);

truelist = Vector('TouchEvent');
falselist = Vector('TouchEvent');

while globalData.hasNextFrame()
    crtFrame = globalData.getNextFrame();
    OnFrameReceived(globalData,crtFrame);
end

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
    
    %有报点的event本身的label是：
    checkarea = evt.areas.at(firstReportedAreaID);
    checkframe = evt.frames.at(evt.areas.at(firstReportedAreaID).frameID);
    checkindex = find(touchIDs==checkarea.reportedID);
    checklabel = checkframe.labels.at(checkindex);
   
    %checklabel是九分类 需要转换为二分类
    if(checklabel == TOUCHEDGE || checklabel == TOUCHMID || checklabel == TOUCHNEAR || checklabel == SWIPEMID || checklabel == SWIPEEDGE)
        TP = TP + 1;
    else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
        FP = FP + 1;
    end
    
    %同时记录报点距离系统down的延时差:
    timedelay = crtFrame.time - checkframe.time;
    
    %存储每个event具体信息以便之后调试
    truerecord = [evt.ID,evt.state,checklabel,timedelay];
    trueoutput = [trueoutput;truerecord];
end

for i=1:falselist.size()
    evt = falselist.at(i);
    evt.state = TouchEvent.False;
    
    %有报点的event本身的label是：
    checkarea = evt.areas.at(firstReportedAreaID);
    checkframe = evt.frames.at(evt.areas.at(firstReportedAreaID).frameID);
    checkindex = find(touchIDs==checkarea.reportedID);
    checklabel = checkframe.labels.at(checkindex);
    
    %checklabel是九分类 需要转换为二分类
    if(checklabel == TOUCHEDGE || checklabel == TOUCHMID || checklabel == TOUCHNEAR || checklabel == SWIPEMID || checklabel == SWIPEEDGE)
        TN = TN + 1;
    else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
        FN = FN + 1;
    end
   
    %同时记录报点距离系统down的延时差:
    timedelay = crtFrame.time - checkframe.time;
    
    %存储每个event具体信息以便之后调试
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