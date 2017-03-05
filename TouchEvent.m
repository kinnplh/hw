classdef TouchEvent < handle
   properties (Constant)
       Undefined = -1
       Uncertain = 0
       True = 1
       False = 2       
   end 
   properties
      areaIDs;% 是一个1维向量， 每个元素依次是构成该touchEvent的Area的序号
      firstReportedAreaID;
      state;
      ID; %touchevent本身的ID,等于其中包含的Area归属回来的touchEventID
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
           if obj.firstReportedAreaID == -1 && areaVector.at(newID).reportID > 0 %出现了报点的Area
               obj.firstReportedAreaID = newID;
               obj.state = TouchEvent.Uncertain;%可进入Classify
           end
       end
       
   end

   % 注意  touchEvent没有拷贝的要求
    
end