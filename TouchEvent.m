classdef TouchEvent < handle
   properties
      areaIDs;% ��һ��1ά������ ÿ��Ԫ�������ǹ��ɸ�touchEvent��Area�����
      firstReportedAreaID;
      ID;
   end
   
   methods
       
       function obj = TouchEvent(id)
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
           obj.ID = id;
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