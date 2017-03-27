classdef TouchEvent < handle
   properties
      areaIDs;% 是一个1维向量， 每个元素依次是构成该touchEvent的Area的序号
      firstReportedAreaID;
      lastReportedAreaID;
      reportID;
      ID;
      
      multipleFrameNum;
      WCMoveDistance;
      firstWCStable;
      downReportPos;
      
   end
   
   methods
       
       function obj = TouchEvent(id)
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
           obj.lastReportedAreaID = -1;
           obj.reportID = -1;
           obj.ID = id;
           obj.multipleFrameNum = 0;
           obj.WCMoveDistance = 0;
           obj.firstWCStable = Pos(-1, -1);
           obj.downReportPos = Pos(-1, -1);
       end
           
       function addAreaID(obj, newID, globalData)
           areaVector = globalData.areas;
           obj.areaIDs = [obj.areaIDs, newID];
           
           
           % 维护first reported ID
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID >= 0
               obj.firstReportedAreaID = newID;
               obj.reportID = areaVector.at(newID).reportID;
               obj.downReportPos = areaVector.at(newID).reportPos;
               return;
           end
           
           % 维护firstWCStable
           crtArea = areaVector.at(newID);
           if crtArea.reportID >= 0 && crtArea.previousID > 0 && (obj.firstWCStable.x == -1 || obj.firstWCStable.y == -1)
               lastArea = areaVector.at(crtArea.previousID);
               if lastArea.reportID >= 0 % 连续两帧均有报点  可以查看N1和N2的情况来确定是否已经稳定
                   [N1, N2] = Classifier.calFeatureN(lastArea, crtArea, globalData);
                   if N1 > 0 && N2 < 0
                       obj.firstWCStable = crtArea.weightedCenter;
                   end
               end
           end
           
           %计算相关的数值
           if obj.reportID > -1 &&  areaVector.at(newID).reportID > -1
               assert(obj.reportID == areaVector.at(newID).reportID);
               
               if obj.firstWCStable.x ~= -1 && obj.firstWCStable.y ~= -1
                   crtArea = areaVector.at(newID);
                   lastArea = areaVector.at(crtArea.previousID);
                   obj.WCMoveDistance = obj.WCMoveDistance +...
                       crtArea.weightedCenter.disTo(lastArea.weightedCenter);
                   crtArea.displacement_distance_ratio = (crtArea.weightedCenter.disTo(obj.firstWCStable)) /...
                       obj.WCMoveDistance;
                   if isnan(crtArea.displacement_distance_ratio)
                       crtArea.displacement_distance_ratio = -1;
                   end
               end
               
           end
           
           % 维护lastReportedID
           if obj.firstReportedAreaID ~= -1 && obj.reportID >= 0 && areaVector.at(newID).reportID < 0 && obj.lastReportedAreaID == -1
               obj.lastReportedAreaID = obj.areaIDs(end - 1);
           end
           if areaVector.at(newID).reportNum > 1
               obj.multipleFrameNum = obj.multipleFrameNum + 1;
           end
           
       end
       
%        function showVideo(obj, whiteNum, frameVector, areaVector)
%            totalFrame = length(obj.areaIDs);
%            for i = 1: totalFrame
%                crtArea = areaVector.at(obj.areaIDs(i));
%                crtFrame = frameVector.at(crtArea.frameID);
%                crtFrame.showFrame(whiteNum);
%                pause
%            end
%        end
        function showVideo(obj, whiteNum, frameVector, areaVector)
           totalFrame = length(obj.areaIDs);
           fig = gcf;
           i=0;
           while(i<totalFrame)
               i = i+1;
           % for i = 1: totalFrame
               image = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM);
               crtArea = areaVector.at(obj.areaIDs(i));
               crtFrame = frameVector.at(crtArea.frameID);
               subplot(1,4,1)
               for j = 1:crtArea.areaSize
                   x = crtArea.rangeInfo(1,j);
                   y = crtArea.rangeInfo(2,j);
                   image(x,y) = crtFrame.capacity(x,y) / whiteNum;
                   imshow(image','InitialMagnification','fit');
               end
               title(['areaID: ', int2str(obj.areaIDs(i)), ...
                   '; first reportedID: ', int2str(obj.firstReportedAreaID)]);
               subplot(1,4,2)
               crtFrame.showFrame(whiteNum);
               title(['touchEventID: ', int2str(crtArea.touchEventID)]);
               
               
               subplot(1,4,3)
               crtFrame.showAreas(whiteNum,frameVector, areaVector);
               title(['areas in frame No.', int2str(crtArea.frameID)]);

               subplot(1,4,4)
               image = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM);
               imshow(image','InitialMagnification','fit');
               %title([obj.getLabel(), ' frame ', int2str(i), ':', int2str(length(obj.areaIDs))]);
               
               skip = false;
               while(true)
                   w = waitforbuttonpress;
                   if w == 0
                   else
                       if(fig.CurrentCharacter == 'n')
                           skip = true;
                           break;
                       elseif(fig.CurrentCharacter == ' ')
                           break;
                       elseif(fig.CurrentCharacter == 'p')
                           i = i-2;
                           if(i<0)
                            i = 0;
                            beep();
                           end
                           break;
                       end
                   end
               end
               if(skip)
                   break;
               end
           end
           subplot(1,4,4)
           imshow(rand(28,16),'InitialMagnification','fit');
           pause
        end
        
   end
   
   
   % 注意  touchEvent没有拷贝的要求
    
end