% ͳ�Ƶ���¼����ж���ȷ��
mainPaths = getfilepaths('edge/');
totalSlideNum = 0;
delaySlideNum = 0; % �ͱ���λ�����   �����˱���λ�Ƶĵ�
aheadSlideNum = 0;
diffTime = [];
for fileId = 1: length(mainPaths)
   mainPaths(fileId)
   savePath = sprintf('./testResults/testResultVector%d_edge.mat', fileId); 
   load(savePath); % get testResultVector
   savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d_edge.mat', fileId);
   load(savePath); % get frameVector
   savePath = sprintf('./areas/areaVector%d_edge.mat', fileId);
   load(savePath); % get areaVector
   savePath = sprintf('./touchEvents/touchEventVector%d_edge.mat', fileId);
   load(savePath); % get touchEventVector
   
   resultSize = testResultVector.size();
   
   isSLIDE = false;
   
   for i = 1: resultSize % ��Ӧ�ڸ��ļ��е�ÿ���¼�
       crtRes = testResultVector.at(i);
       crtEvent = touchEventVector.at(crtRes.touchEventID);
       assert(i == crtRes.touchEventID);
       assert(crtRes.actualReportPos.size() == length(crtEvent.areaIDs));
       if crtEvent.firstReportedAreaID == -1
           continue; % not reported
       end
       
       % �жϸ��¼��ǲ���һ������¼�
       % �������  ˵�������ļ������ǵ���¼� break
       reportArea = areaVector.at(crtEvent.firstReportedAreaID);
       reportID = reportArea.reportID;
       reportFrame = frameVector.at(reportArea.frameID);
       reportIndex = find(reportFrame.touchIDs == reportID);
       if ~isSLIDE
           l = cell2mat(reportFrame.labels.at(reportIndex));
           if strcmp(l, 'SLIDE') || strcmp(l, 'DRAG')
               isSLIDE = true;
           else
               break;
           end
       end
       
       
       % ��Ҫ�ж϶��ڻ�����˵��û�и���
       % Ҳ����˵  ���ڵ�ʵ���жϷ���  ���ݼ��ٶ�Ԥ�� ��ǰ�ܹ���λ�� + 2 * ��ǰ֡��ǰһ֮֡���λ�� - ǰһ֡��ǰ��֮֡���λ��
       % ͳ�����ֱ��������и�����������ȥ�жϻ���ʱ���ӳ�
       reportPos = reportFrame.touchPosPixel.at(reportIndex);
       totalSlideNum = totalSlideNum + 1;
       startIndex = find(crtEvent.areaIDs == crtEvent.firstReportedAreaID);
       if crtEvent.lastReportedAreaID == -1
           endIndex = length(crtEvent.areaIDs);
       else
           endIndex = find(crtEvent.areaIDs == crtEvent.lastReportedAreaID);
       end
       
       totalMoveSys = 0;
       crtLastMove = 0;
       lastToBeforeMove = 0;
       sysAreaID = -1;
       for j = startIndex: endIndex
           totalMoveSys = reportPos.disTo(areaVector.at(crtEvent.areaIDs(j)).reportPos);
           if j - 1 >= startIndex
               lastToBeforeMove = crtLastMove;
               crtLastMove = areaVector.at(crtEvent.areaIDs(j)).reportPos.disTo(...
                   areaVector.at(crtEvent.areaIDs(j - 1)).reportPos);
           end
           if (totalMoveSys + 2 * crtLastMove - lastToBeforeMove) >= 24
               sysAreaID = crtEvent.areaIDs(j);
               break;
           end
       end
       
       
       totalMoveReport = 0;
       crtLastMove = 0;
       lastToBeforeMove = 0;
       reportAreaID = -1;
       for j = startIndex: endIndex
           totalMoveReport = reportPos.disTo(crtRes.actualReportPos.at(j));
           if j - 1 >= startIndex
               lastToBeforeMove = crtLastMove;
               crtLastMove = crtRes.actualReportPos.at(j).disTo(...
                   crtRes.actualReportPos.at(j - 1));
           end
           if (totalMoveReport + 2 * crtLastMove - lastToBeforeMove) >= 24
               reportAreaID = crtRes.areaIDs(j);
               break;
           end
       end
       if sysAreaID == -1 || reportAreaID == -1
           crtEvent
           continue;
       end
       
       if sysAreaID < reportAreaID
           delaySlideNum = delaySlideNum + 1;
           diffTime = [diffTime, frameVector.at(areaVector.at(sysAreaID).frameID).time - ...
               frameVector.at(areaVector.at(reportAreaID).frameID).time];
       elseif sysAreaID > reportAreaID
           aheadSlideNum = aheadSlideNum + 1;
           diffTime = [diffTime, frameVector.at(areaVector.at(sysAreaID).frameID).time - ...
               frameVector.at(areaVector.at(reportAreaID).frameID).time];
       end
       
       
   end
    
end
aheadSlideNum
delaySlideNum
totalSlideNum
% ͳ��ʹ��4������ֵ   ����们�������� �Լ��ܵĵ������
% ******************************************************************************




