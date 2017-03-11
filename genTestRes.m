% ͳ�Ƶ���¼����ж���ȷ��
mainPaths = getfilepaths('data/');
totalClickNum = 0;
clickEventMoved = 0; % �ͱ���λ�����   �����˱���λ�Ƶĵ�
for fileId = 1: length(mainPaths)
   mainPaths(fileId)
   savePath = sprintf('./testResultsSimple/testResultVector%d.mat', fileId); 
   load(savePath); % get testResultVector
   savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
   load(savePath); % get frameVector
   savePath = sprintf('./areas/areaVector%d.mat', fileId);
   load(savePath); % get areaVector
   savePath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
   load(savePath); % get touchEventVector
   
   resultSize = testResultVector.size();
   
   isClick = false;
   
   for i = 1: resultSize % ��Ӧ�ڸ��ļ��е�ÿ���¼�
       crtRes = testResultVector.at(i);
       crtEvent = touchEventVector.at(crtRes.touchEventID);
       assert(i == crtRes.touchEventID);
       if crtEvent.firstReportedAreaID == -1
           continue; % not reported
       end
       
       % �жϸ��¼��ǲ���һ������¼�
       % �������  ˵�������ļ������ǵ���¼� break
       reportArea = areaVector.at(crtEvent.firstReportedAreaID);
       reportID = reportArea.reportID;
       reportFrame = frameVector.at(reportArea.frameID);
       reportIndex = find(reportFrame.touchIDs == reportID);
       if ~isClick
           l = cell2mat(reportFrame.labels.at(reportIndex));
           if strcmp(l, 'CLICK') || strcmp(l, 'FORCE_CLICK')
               isClick = true;
           else
               break;
           end
       end
       
       
       reportPos = reportFrame.touchPosPixel.at(reportIndex);
       totalClickNum = totalClickNum + 1;
       
       startIndex = find(crtEvent.areaIDs == crtEvent.firstReportedAreaID);
       if crtEvent.lastReportedAreaID == -1
           endIndex = length(crtEvent.areaIDs);
       else
           endIndex = find(crtEvent.areaIDs == crtEvent.lastReportedAreaID);
       end
       
       for j = startIndex: endIndex
           crtArea = areaVector.at(crtEvent.areaIDs(j));
           crtFrame = frameVector.at(crtArea.frameID);
           
           % should report point in this area
           % ����Ҫ�����һ������¼����ԣ����еı���  ��Ӧ�ú�down�Ǹ�ʱ�̵ı���һ��
           if ~reportPos.isEqual(crtFrame.touchPosPixel.at(crtFrame.touchIDs == crtArea.reportID))
               
               clickEventMoved = clickEventMoved + 1;
               break;
           end
       end
       
       
   end
    
end
% ͳ��ʹ��4������ֵ   ����们�������� �Լ��ܵĵ������
% ******************************************************************************




