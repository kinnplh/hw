% 统计点击事件的判断正确率
mainPaths = getfilepaths('dataTouchAndHold/');
totalClickNumSimple = 0;
clickEventMovedSimple = 0; % 和报点位置相比   出现了报点位移的点
for fileId = 1: length(mainPaths)
   mainPaths(fileId)
   savePath = sprintf('./testResults/testResultVector%d_TouchAndHold.mat', fileId); 
   load(savePath); % get testResultVector
   savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d_TouchAndHold.mat', fileId);
   load(savePath); % get frameVector
   savePath = sprintf('./areas/areaVector%d_TouchAndHold.mat', fileId);
   load(savePath); % get areaVector
   savePath = sprintf('./touchEvents/touchEventVector%d_TouchAndHold.mat', fileId);
   load(savePath); % get touchEventVector
   
   resultSize = testResultVector.size();
   
   isClick = false;
   
   for i = 1: resultSize % 对应于该文件中的每个事件
       crtRes = testResultVector.at(i);
       crtEvent = touchEventVector.at(crtRes.touchEventID);
       assert(i == crtRes.touchEventID);
       assert(crtRes.actualReportPos.size() == length(crtEvent.areaIDs));
       if crtEvent.firstReportedAreaID == -1
           continue; % not reported
       end
       
       % 判断该事件是不是一个点击事件
       % 如果不是  说明整个文件都不是点击事件 break
       reportArea = areaVector.at(crtEvent.firstReportedAreaID);
       reportID = reportArea.reportID;
       reportFrame = frameVector.at(reportArea.frameID);
       reportIndex = find(reportFrame.touchIDs == reportID);
       if ~isClick
           l = cell2mat(reportFrame.labels.at(reportIndex));
           if strcmp(l, 'CLICK') || strcmp(l, 'FORCE_CLICK') || strcmp(l, 'TOUCH_HOLD')
               isClick = true;
           else
               break;
           end
       end
       
       
       reportPos = reportFrame.touchPosPixel.at(reportIndex);
       totalClickNumSimple = totalClickNumSimple + 1;
       
       startIndex = find(crtEvent.areaIDs == crtEvent.firstReportedAreaID);
       if crtEvent.lastReportedAreaID == -1
           endIndex = length(crtEvent.areaIDs);
       else
           endIndex = find(crtEvent.areaIDs == crtEvent.lastReportedAreaID);
       end
       
       for j = startIndex: endIndex
           crtArea = areaVector.at(crtEvent.areaIDs(j));
           crtFrame = frameVector.at(crtArea.frameID);
           assert(crtArea.reportID ~= -1)
           assert(~crtRes.actualReportPos.at(j).isEqual(Pos(-1, -1)));
           % should report point in this area
           % 我们要求对于一个点击事件而言，所有的报点  都应该和down那个时刻的报点一致
           if ~reportPos.isEqual(crtRes.actualReportPos.at(j))
               clickEventMovedSimple = clickEventMovedSimple + 1;
               break;
           end
       end
       
       
   end
    
end
% 统计使用4像素阈值   点击变滑动的数量 以及总的点击数量
% ******************************************************************************
totalClickNumSimple
clickEventMovedSimple



