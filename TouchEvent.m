classdef TouchEvent < handle
   properties (Constant)
       Undefined = -1
       Uncertain = 0
       True = 1
       False = 2       
   end  
   properties
      areaIDs;% ��һ��1ά������ ÿ��Ԫ�������ǹ��ɸ�touchEvent��Area�����
      firstReportedAreaID;
      lastReportedAreaID;
      reportID;
      ID;
      state;
   end
   
   methods
       
       function obj = TouchEvent(id)
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
           obj.lastReportedAreaID = -1;
           obj.reportID = -1;
           obj.ID = id;
           obj.state = TouchEvent.Undefined;
       end
           
       function addAreaID(obj, newID, areaVector)
           obj.areaIDs = [obj.areaIDs, newID];
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID >= 0
               obj.firstReportedAreaID = newID;
               obj.reportID = areaVector.at(newID).reportID;
               obj.state = TouchEvent.Undefined;%�ɽ���Classify
               return;
           end
           
           if obj.firstReportedAreaID ~= -1 && obj.reportID >= 0 && areaVector.at(newID).reportID < 0
               obj.lastReportedAreaID = newID;
           end
           
       end
   end
   
   
   % ע��  touchEventû�п�����Ҫ��
    
end