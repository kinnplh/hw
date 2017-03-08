classdef GD < handle
    %UNTITLED7 此处显示有关此类的摘要
    %   此处显示详细说明
    properties
        evts;
        frames;
        areas;
        testResults;
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
            obj.testResults = Vector('TestResult');
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
            assert(obj.frames.at(obj.frames.size()).time == obj.frameVector.at(obj.frames.size()).time);
            
            % 添加在该frame中的所有area
            for i = 1: length(crtFrame.areaIDs) %对应于所有的新的area  顺序应该是和生成的时候是一样的
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
                        crtEvent.reportID = crtArea.reportID;
                    end
                    if crtEvent.firstReportedAreaID ~= -1 && crtEvent.reportID > 0 && crtArea.reportID == -1
                        crtEvent.lastReportedAreaID = crtArea.ID;
                    end
                else
                    %新建一个touchEvent
                    crtEvent = TouchEvent(obj.evts.size() + 1);
                    crtTestResult = TestResult(crtEvent.ID);
                    obj.evts.push_back(crtEvent)
                    obj.testResults.push_back(crtTestResult);
                    
                    assert(crtTestResult.touchEventID == obj.testResults.size());
                    
                    crtEvent.areaIDs = crtArea.ID;
                    assert(crtArea.ID == obj.touchEventVector.at(crtTestResult.touchEventID).areaIDs(1));
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

