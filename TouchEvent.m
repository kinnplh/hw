classdef TouchEvent < handle
   properties
      areaIDs;% ��һ��1ά������ ÿ��Ԫ�������ǹ��ɸ�touchEvent��Area�����
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
           
           if obj.firstReportedAreaID ~= -1 && obj.reportID >= 0 && areaVector.at(newID).reportID < 0
               obj.lastReportedAreaID = newID;
           end
           
       end
       
       function showVideo(obj, whiteNum, frameVector, areaVector)
           totalFrame = length(obj.areaIDs);
           for i = 1: totalFrame
               crtArea = areaVector.at(obj.areaIDs(i));
               crtFrame = frameVector.at(crtArea.frameID);
               crtFrame.showFrame(whiteNum);
               pause
           end
       end
   end
   
   
   % ע��  touchEventû�п�����Ҫ��
    
end