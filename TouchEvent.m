classdef TouchEvent < handle
   properties
      areaIDs;% 是一个1维向量， 每个元素依次是构成该touchEvent的Area的序号
      firstReportedAreaID;
      lastReportedAreaID;
      reportID;
      ID;
   end
   
   methods
       
       function obj = TouchEvent(id)
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
           obj.lastReportedAreaID = -1;
           obj.reportID = -1;
           obj.ID = id;
       end
           
       function addAreaID(obj, newID, areaVector)
           obj.areaIDs = [obj.areaIDs, newID];
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID >= 0
               obj.firstReportedAreaID = newID;
               obj.reportID = areaVector.at(newID).reportID;
               return;
           end
           if obj.reportID > -1 &&  areaVector.at(newID).reportID > -1
               assert(obj.reportID == areaVector.at(newID).reportID);
           end
           
           if obj.firstReportedAreaID ~= -1 && obj.reportID >= 0 && areaVector.at(newID).reportID < 0
               obj.lastReportedAreaID = obj.areaIDs(end - 1);
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