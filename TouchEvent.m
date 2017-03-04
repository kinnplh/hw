classdef TouchEvent < handle
   properties
      areaIDs;% ��һ��1ά������ ÿ��Ԫ�������ǹ��ɸ�touchEvent��Area�����
      firstReportedAreaID;
   end
   
   methods
       
       function obj = TouchEvent()
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
       end
           
       function addAreaID(obj, newID, areaVector)
           obj.areaIDs = [obj.areaIDs, newID];
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID > 0
               obj.firstReportedAreaID = newID;
           end
       end
   end
   
   
   % ע��  touchEventû�п�����Ҫ��
    
end