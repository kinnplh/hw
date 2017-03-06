classdef Classifier < handle
    
    
    
    methods (Static)
        function ret = getEventTypeSimple(area1, area2, globalData) 
            %使用4个像素作为阈值  如果两者均有报点，并且报点距离之差超过4个像素
            if area1.reportedID == -1 || area2.reportedID == -1
                ret = Enum.UNKNOWN;
                return;
            else
                frame1 = globalData.frames.at(area1.frameID);
                frame2 = globalData.frames.at(area2.frameID);
                p1 = frame1.touchPosPixel.at(frame1.touchIDs == area1.reportedID);
                p2 = frame2.touchPosPixel.at(frame2.touchIDs == area2.reportedID);
                if p1.disTo(p2) >= 4
                    ret = Enum.SLIDE;
                else
                    ret = Enum.CLICK;
                end
            end
        end
        
        function newAreaReceived(crtArea, globalData) 
            crtEvent = globalData.evts.at(crtArea.touchEventID);
            crtRes = globalData.testResults.at(crtArea.touchEventID);
            assert(crtEvent.areaIDs(end) == crtArea.ID);
            %最多往前看Consts.FRAME_STROE_SIZE帧
            totalLength = length(crtEvent.areaIDs);
            start = max(totalLength - Consts.FRAME_STROE_SIZE, 1);
            ret = Enum.UNKNOWN;
            for i = start: totalLength - 1
                focusArea = globalData.areas.at(crtEvent.areaIDs(i));
                
                ret = getEventTypeSimple(crtArea, focusArea, globalData);
                
            end
            crtRes.status.push_back(ret);
            if ret == Enum.UNKNOWN || ret == Enum.CLICK
                if crtEvent.firstReportedAreaID == -1
                    crtRes.actualReportPos.push_back(Pos(-1, -1));
                elseif crtEvent.lastReportedAreaID == -1
                    f = globalData.frames.at(globalData.areas.at(firstReportedAreaID).frameID);
                    crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
                else
                    f = globalData.frames.at(globalData.areas.at(lastReportedAreaID).frameID);
                    crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
                end
            else %slide
                if crtArea.reportID == -1
                    crtRes.actualReportPos.push_back(Pos(-1, -1));
                else
                    f = globalData.frames.at(crtArea.frameID);
                    crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
                end
            end 
        end 
    end
end