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
      state;
      ID; %touchevent�����ID,�������а�����Area����������touchEventID
      %
   end
   
   methods
       
       function obj = TouchEvent(id)
           obj.areaIDs = [];
           obj.firstReportedAreaID = -1;
           obj.state = TouchEvent.Undefined;
           obj.ID = id;
       end
           
       function addAreaID(obj, newID, areaVector)
           obj.areaIDs = [obj.areaIDs, newID];
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID > 0 %�����˱����Area
               obj.firstReportedAreaID = newID;
               obj.state = TouchEvent.Uncertain;%�ɽ���Classify
           end
       end
       
   end

   % ע��  touchEventû�п�����Ҫ��
    
end