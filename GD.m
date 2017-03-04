classdef GD < handle
    %UNTITLED7 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties
        evts;
        frames;
        areas;
    end
    
    properties (Access = 'private')
        %���ϵ��ӽǡ������ݣ����ܹ�ֱ�ӷ���
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
            
            % ���ϵ��ӽ��п�����Ӧ��frame����push��frames��ȥ
            % frame�������Ϣû��ʲô��Ҫ�Ķ���
            crtFrame = obj.frameVector.at(obj.crtFrameIndex).copyFrame();
            obj.frames.push_back(crtFrame);
            assert(obj.frames.size() == crtFrame.ID);
            % ����ڸ�frame�е�����area
            for i = 1: length(crtFrame.areaIDs)
                crtArea = obj.areaVector.at(crtFrame.areaIDs(i)).copyArea();
                obj.areas.push_back(crtArea);
                assert(obj.areas.size() == crtArea.ID);
                crtArea.nextID = -1;
                if crtArea.previousID ~= -1
                    % ����һ��Area������
                    obj.areas.at(crtArea.previousID).nextID = crtArea.ID;
                    % �Զ�Ӧ��touchEvent���и���
                    crtEvent = obj.evts.at(crtArea.touchEventID);
                    crtEvent.areaIDs = [crtEvent.areaIDs, crtArea.ID];
                    if crtEvent.firstReportedAreaID == -1 && crtArea.reportID ~= -1
                        crtEvent.firstReportedAreaID = crtArea.ID;
                    end
                else
                    %�½�һ��touchEvent
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

