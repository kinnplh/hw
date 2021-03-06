classdef Classifier < handle
    properties
        testResultVector
        poss
        step
        max_X
        max_Y
        size_X
        size_Y
    end
    methods (Static)
        function ret = getEventTypeNaive(~, ~, ~)
            % 一直被判断成滑动
            ret = Enum.SLIDE;
        end     
        function ret = getEventTypeBad(~, ~, ~)
            ret = Enum.CLICK;
        end
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
        function [pos, neg] = calFeatureN(area1, area2, globalData)
            % from area1 to area2
            pos = 0;
            neg = 0;
            wcChangeOri = [area2.weightedCenter.x - area1.weightedCenter.x, ...
                area2.weightedCenter.y - area1.weightedCenter.y];
            wcChangeOri = wcChangeOri / sqrt(wcChangeOri * wcChangeOri');
            wcMid = [area1.weightedCenter.x + area2.weightedCenter.x, ...
                area1.weightedCenter.y + area2.weightedCenter.y] / 2;
            area1Range = area1.getFullRange();
            area2Range = area2.getFullRange();
            totalRange = area1Range | area2Range;
            [r, c] = find(totalRange == 1);
            frame1 = globalData.frames.at(area1.frameID);
            frame2 = globalData.frames.at(area2.frameID);
            diffM = (frame2.capacity - frame1.capacity);
            totalRangeSize = length(r);
            for i = 1: totalRangeSize
                x = r(i);
                y = c(i);
                midWCToP = [x, y] - wcMid;
                midWCToP = midWCToP / sqrt(midWCToP * midWCToP');
                if midWCToP * wcChangeOri' >= 0
                    pos = pos + diffM(x, y);
                else
                    neg = neg + diffM(x, y);
                end
            end
        end
        function ret = areaReceivedForStat(crtArea, globalData)
            % ret 第一列是pos 第二列是neg 第三列是label
            % 只有当报点之后才会开始统计
            ret = [];
            if crtArea.reportID == -1
                return;
            end
            
            % 只统计与down帧
            
            crtEvent = globalData.evts.at(crtArea.touchEventID);
            reportArea = globalData.areas.at(crtEvent.firstReportedAreaID);
            [pos, neg] = Classifier.calFeatureN(reportArea, crtArea, globalData);
            ret = [pos, neg, crtArea.getLabel(globalData)];
            
            
            
            %最多往前看Consts.FRAME_STROE_SIZE帧
%             crtEvent = globalData.evts.at(crtArea.touchEventID);
%             totalLength = find(crtEvent.areaIDs == crtArea.ID);
%             start = max(totalLength - Consts.FRAME_STROE_SIZE, 1);
%             
%             for i = start: totalLength - 1
%                 lastArea = globalData.areas.at(crtEvent.areaIDs(i));
%                 [pos, neg] = Classifier.calFeatureN(lastArea, crtArea, globalData);
% %                 if pos == 0 && neg == 0
% %                     'interest'
% %                 end
%                 ret = [ret; pos, neg, crtArea.getLabel(globalData)];
%             end

        end
        
        function ret = getTypeFromSingleArea(crtArea, testRes, globalData)
            if crtArea.reportID < 0 || crtArea.previousID <= 0% 没有报点
                ret = Enum.CLICK;
                return;
            end
            
            if crtArea.maxCapSmoothed < testRes.maxCapEver * Consts.VALID_REPORT_CAP_RATIO
                testRes.maxCapEver = testRes.maxCapEver * 0.75;
                ret = Enum.CLICK;
                return;
            end
            
            lastArea = crtArea;
            res = nan;
            while isnan(res) && lastArea.previousID > 0
                
                lastArea = globalData.areas.at(lastArea.previousID);
                if lastArea.reportID < 0 || lastArea.reportPos.isEqual(crtArea.reportPos)
                    ret = Enum.CLICK;
                    return;
                end
                [N1, N2] = Classifier.calFeatureN(lastArea, crtArea, globalData);
                if N1 <= 0 || N2 >= 0
                    ret = Enum.CLICK;
                    return;
                end
                res = abs(N1 + N2) / lastArea.weightedCenter.disTo(crtArea.weightedCenter);
            end
            
            if isnan(res)
                ret = Enum.CLICK;
                return;
            end
            
            if res > testRes.capDiffThreshold
                ret = Enum.CLICK;
                %testRes.capDiffThreshold = testRes.capDiffThreshold * 2;
                return;
            end
            
            
            % 判断ratio  决定是不是滑动
            
            if crtArea.displacement_distance_ratio == -1
                ret = Enum.CLICK;
                return;
            end
            
            crtEvent = globalData.evts.at(crtArea.touchEventID);
            if crtArea.displacement_distance_ratio > 0.4
                if crtArea.reportPos.disTo(crtEvent.downReportPos) > 4
                    ret = Enum.SLIDE;
                    return;
                else
                    ret = Enum.CLICK;
                    return;
                end
            end

            if crtArea.displacement_distance_ratio < 0.2
                if crtArea.reportPos.disTo(crtEvent.downReportPos) > 24
                    ret = Enum.SLIDE;
                    return;
                else
                    ret = Enum.CLICK;
                    return;
                end
            end
            
            if crtArea.reportPos.disTo(crtEvent.downReportPos) > 12
                ret = Enum.SLIDE;
                return;
            else
                ret = Enum.CLICK;
                return;
            end
            
        end
    end
    
    methods
        function obj = Classifier(Poss_SMOOTH, step, max_X, max_Y)
            obj.testResultVector = Vector('TestResult');
            obj.poss = Poss_SMOOTH;
            obj.step = step;
            obj.max_X = max_X;
            obj.max_Y = max_Y;
            obj.size_X = ceil(max_X / step);
            obj.size_Y = ceil(max_Y / step);
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
            crtRes.maxCapEver = max(crtRes.maxCapEver, crtArea.maxCapSmoothed);
            
            totalLength = find(crtEvent.areaIDs == crtArea.ID);
            assert(length(totalLength) == 1);
            
            if isempty(crtRes.status)
                ret = Enum.UNKNOWN;
            else
                ret = crtRes.status(end);
            end
            
            if (~(ret == Enum.SLIDE))
                
                ret = obj.getTypeFromSingleArea(crtArea, crtRes, globalData);
                if ret == Enum.SLIDE
                    crtRes.area1ID = crtArea.previousID;
                    crtRes.area2ID = crtArea.ID;
                end
            end
            
            crtRes.status = [crtRes.status, ret];
            crtRes.areaIDs = [crtRes.areaIDs, crtArea.ID];
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
%                     if crtArea.maxCapSmoothed < crtRes.maxCapEver * Consts.VALID_REPORT_CAP_RATIO
%                         crtRes.actualReportPos.push_back(crtRes.actualReportPos.last());
%                     else
                        crtRes.actualReportPos.push_back(f.touchPosPixel.at(f.touchIDs == crtEvent.reportID));
%                     end
                    
                end
            end 
        end 
        function ret = getEventType(obj, area1, area2, globalData)
            % 即使没有报点  也可以做出判断
            [pos, neg] = obj.calFeatureN(area1, area2, globalData);
            if pos <= 0 || neg >= 0
                ret = Enum.CLICK;
                return;
            end
            
            x = ceil(abs(pos / obj.step));
            y = ceil(abs(neg / obj.step));
            if x  > obj.size_X || y > obj.size_Y
                ret = Enum.SLIDE;
                return;
            end
            if obj.poss(x, y) > Consts.BE_SLIDE_RATIO
                ret = Enum.SLIDE;
            else
                ret = Enum.CLICK;
            end
            
        end
        
        function newAreaReceivedForStat(obj, crtArea, globalData)
%             crtEvent = globalData.evts.at(crtArea.touchEventID);
            crtRes = obj.getTestResultByID(crtArea.touchEventID);
            if crtArea.reportID < 0 || crtArea.previousID <= 0% 没有报点
                %crtRes.eiff = [crtRes.eiff, [-1; -1; -1]];
                return;
            end
            
            lastArea = crtArea;
            res = nan;
            while isnan(res) && lastArea.previousID > 0
                
                lastArea = globalData.areas.at(lastArea.previousID);
                if lastArea.reportID < 0 || lastArea.reportPos.isEqual(crtArea.reportPos)
                    %crtRes.eiff = [crtRes.eiff, [-1; -1; -1]];
                    return;
                end
                [N1, N2] = Classifier.calFeatureN(lastArea, crtArea, globalData);
                res = abs(N1 + N2) / lastArea.weightedCenter.disTo(crtArea.weightedCenter);
            end
            if(isnan(res))
                %crtRes.eiff = [crtRes.eiff, [-1; -1; -1]];
                return;
            else
                crtRes.eiff = [crtRes.eiff, [N1; N2; res]];
                return;
            end
            
        end
    end
    
    
end