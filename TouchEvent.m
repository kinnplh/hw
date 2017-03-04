classdef TouchEvent < handle
   properties
      areaIDs;% 是一个1维向量， 每个元素依次是构成该touchEvent的Area的序号
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
   
   
   % 注意  touchEvent没有拷贝的要求
    
end