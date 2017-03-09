classdef TestResult < handle
    
    % 需要让我能够访问down的那一帧
    properties
       touchEventID;% 实际上对应的也就是自己的ID
       actualReportPos; % 针对于TouchEvent中的每个Area，如果没有报点则是一个非法的位置
       status;
    end
    
    methods
        function obj = TestResult(evtID)
            obj.touchEventID = evtID;
            obj.actualReportPos = Vector('Pos');
            obj.status = [];
        end
        
    end
    
end