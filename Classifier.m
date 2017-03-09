classdef Classifier < handle
    properties
        testResultVector
    end
    methods (Static)
        function ret = getEventTypeSimple(area1, area2, globalData) 
            %使用4个像素作为阈值  如果两者均有报点，并且报点距离之差超过4个像素
            if area1.reportID == -1 || area2.reportID == -1
                ret = Enum.UNKNOWN;
                return;
            else
                frame1 = globalData.frames.at(area1.frameID);
                frame2 = globalData.frames.at(area2.frameID);
                p1 = frame1.touchPosPixel.at(frame1.touchIDs == area1.reportID);
                p2 = frame2.touchPosPixel.at(frame2.touchIDs == area2.reportID);
                if p1.disTo(p2) >= 4
                    ret = Enum.SLIDE;
                else
                    ret = Enum.CLICK;
                end
            end
        end
    end
    
    methods
        
        function obj = Classifier()
            obj.testResultVector = Vector('TestResult');
        end
        function ret = getTestResultByID(obj, id)
            if obj.testResultVector.size() >= id
                ret = obj.testResultVector.at(id);
            else
                while obj.testResultVector.size() < id
                    obj.testResultVector.push_back(TestResult(obj.testResultVector.size() + 1));
                end
                ret = obj.testResultVector.at(id);
            end
        end
        
        function newAreaReceived(obj, crtArea, globalData) 
            crtEvent = globalData.evts.at(crtArea.touchEventID);
            crtRes = obj.getTestResultByID(crtArea.touchEventID);
            
            %最多往前看Consts.FRAME_STROE_SIZE帧
            
            totalLength = find(crtEvent.areaIDs == crtArea.ID);
            assert(length(totalLength) == 1);
            
            start = max(totalLength - Consts.FRAME_STROE_SIZE, 1);
            if isempty(crtRes.status)
                ret = Enum.UNKNOWN;
            else
                ret = crtRes.status(end);
            end
            
            for i = start: totalLength - 1
                if ret == Enum.SLIDE % 现在的处理方式是，如果之前判断出是一个滑动  那么我们就默认滑动会继续下去
                    break;
                end
                focusArea = globalData.areas.at(crtEvent.areaIDs(i));% 每个都和crtArea进行比较
                
                ret = obj.getEventTypeSimple(crtArea, focusArea, globalData);
            end
            
            crtRes.status = [crtRes.status, ret];
            if ret == Enum.UNKNOWN || ret == Enum.CLICK
                %判断现在的这个Area有没有报点
                %没有报点的话就报非法的值
                if crtArea.reportID < 0
                    crtRes.actualReportPos.push_back(Pos(-1, -1));
                else %否则，则报一个down的点    后续应该还要考虑点击-滑动两种状态的切换情况 
                    f = globalData.frames.at(globalData.areas.at(crtEvent.firstReportedAreaID).frameID);%找到了刚刚报点的那一帧
                    crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
                end
            else %slide
                if crtArea.reportID < 0
                    crtRes.actualReportPos.push_back(Pos(-1, -1));
                else
                    f = globalData.frames.at(crtArea.frameID);
                    crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
                end
            end 
        end 
        
    end
    
    
end