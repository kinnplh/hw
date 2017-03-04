classdef GD < handle
    %UNTITLED7 此处显示有关此类的摘要
    %   此处显示详细说明
    properties
        evts;
        frames;
        areas;
    end
    
    properties (Access = 'private')
        %“上帝视角”的数据，不能够直接访问
        frameVector;
        touchEventVector;
        areaVector;
        
        crtFrameIndex;
    end
    
    methods
        function obj = GD(frameVector, touchEventVector, areaVector)
            obj.frameVector = frameVector;
            obj.touchEventVector = touchEventVector;
            obj.areaVector = areaVector;
            obj.crtFrameIndex = 0;
            obj.evts = Vector('TouchEvent');
            obj.frames = Vector('Frame');
            obj.areas = Vector('Area');
        end
        function ret = hasNextFrame(obj)
            ret = obj.crtFrameIndex < obj.frameVector.size();
        end
        function ret = getNextFrame(obj)
            obj.crtFrameIndex = obj.crtFrameIndex + 1;
            
            % 从上帝视角中拷贝相应的frame，并push到frames中去
            % frame本身的信息没有什么需要改动的
            crtFrame = obj.frameVector.at(obj.crtFrameIndex).copyFrame();
            obj.frames.push_back(crtFrame);
            assert(obj.frames.size() == crtFrame.ID);
            % 添加在该frame中的所有area
            for i = 1: length(crtFrame.areaIDs)
                crtArea = obj.areaVector.at(crtFrame.areaIDs(i)).copyArea();
                obj.areas.push_back(crtArea);
                assert(obj.areas.size() == crtArea.ID);
                crtArea.nextID = -1;
                if crtArea.previousID ~= -1
                    % 和上一个Area相连接
                    obj.areas.at(crtArea.previousID).nextID = crtArea.ID;
                    % 对对应的touchEvent进行更新
                    crtEvent = obj.evts.at(crtArea.touchEventID);
                    crtEvent.areaIDs = [crtEvent.areaIDs, crtArea.ID];
                    if crtEvent.firstReportedAreaID == -1 && crtArea.reportID ~= -1
                        crtEvent.firstReportedAreaID = crtArea.ID;
                    end
                else
                    %新建一个touchEvent
                    crtEvent = TouchEvent();
                    obj.evts.push_back(crtEvent)
                    assert(obj.evts.size() == crtArea.touchEventID);
                    
                    crtEvent.areaIDs = crtArea.ID;
                    if crtArea.reportID ~= -1
                        crtEvent.firstReportedAreaID = crtArea.ID;
                    else
                        crtEvent.firstReportedAreaID = -1;
                    end
                end
            end
            ret = crtFrame;
        end
        
    end
    
end

