classdef Area < handle
    properties
       weightedCenter; %���� Pos
       areaSize;% ���
       average;% ��������ƽ��ֵ
       rangeInfo;% 2 * size��ÿ�ж�Ӧ������ÿһ�����ӣ���һ��Ϊx���꣬�ڶ���Ϊy����, ������Ϊ����ֵ
       % ����ֵ��Ҫ�ں鷺��ʱ�����
       xSpan;% ��x�����ϵĿ��
       ySpan;% ��y�����ϵĿ��
       LU;% Area��Χ�����Ͻ����� Pos
       RD;% Area��Χ�����½����� Pos
       ID;% �Լ��ı��
       frameID;% ������ Frame ���
       reportID;% ����ı�� ���û�б���Ļ���-1
       inheritedReportID;% ������area���������񱨹���Ļ�
       reportPos; % ��area�����λ�� �ޱ�����(-1, -1)
       maxCapSmoothed; % ���ֵ���丽���Ĺ�9��block�ĵ��ݵľ�ֵ
       
       touchEventID;% ������ touchEvent ���
       nextID;% ��һ�� Area ���
       previousID;% ��һ�� Area ���
       
       reportNum;
    end
    methods(Static)
        function ret = isConnected(area1, area2, frameVector, touchEventVector)
            %?���ӵ����Ե��ж�
            %ʱ�����󣬲��迼��
            if abs(frameVector.at(area1.frameID).time - frameVector.at(area2.frameID).time)...
                    > Consts.CONNECTED_AREA_LARGEST_TIME_OFFSET
                ret = false;
                return;
            end
            
            %�����Area��TouchID������-1�Ļ���ͨ��TouchID�������ж�
            if area1.reportID ~= -1 && area2.reportID ~= -1
                if area1.reportID == area2.reportID
                    ret = true;
                    return;
                else
                    ret = false;
                    return;
                end
                
            end
            
            if area1.inheritedReportID ~= -1 && area2.inheritedReportID ~= -1
                if area1.inheritedReportID == area2.inheritedReportID
                    ret = true;
                    return;
                else
                    ret = false;
                    return;
                end
                
            end
            
            if frameVector.at(area1.frameID).time > frameVector.at(area2.frameID).time
                oldArea = area2;
                youngArea = area1;
            elseif frameVector.at(area1.frameID).time < frameVector.at(area2.frameID).time
                oldArea = area1;
                youngArea = area2;
            else % ʱ����ͬ��˵����ͬһ֡��
                ret = false;
                return;
            end
            
            
            % �ж�������δ�����area������һ������һ��û���㣨�ڲ���֡��������Ƿ񹹳��໥���ӵĹ�ϵ

%             area1WCRounded = area1.weightedCenter.round();
%             area2WCRounded = area2.weightedCenter.round();
%������ʹ������ֵ
            if sum(ismember(area1.rangeInfo(1:2, :)', area2.rangeInfo(1:2, :)', 'rows')) >= min(area1.areaSize, area2.areaSize) / 2
                lastEvent = touchEventVector.at(oldArea.touchEventID);
                if lastEvent.firstReportedAreaID ~= -1 && lastEvent.lastReportedAreaID == -1 % ��down��up֮��
                    ret = true;
                elseif lastEvent.firstReportedAreaID == -1 % ��down֮ǰ  Ҫ�������area���ܹ���С
                    %if youngArea.areaSize * youngArea.average >= oldArea.areaSize * oldArea.average / 1.1
                    if youngArea.average >= oldArea.average / 1.1
                        ret = true;
                    else
                        ret = false;
                    end
                else% ��up֮��Ҫ�������area���ܱ��
                    %if youngArea.areaSize * youngArea.average <= oldArea.areaSize * oldArea.average * 1.1
                    if youngArea.average <= oldArea.average * 1.1
                        ret = true;
                    else
                        ret = false;
                    end
                    
                end
            else
                ret = false;
            end
            
            if ret == false && (area1.areaSize == 1 && area2.areaSize == 1)
                % �����ж�
                % Ҫ�󽵵�Ϊ ����������һ�����غ�
                if area1.areaSize == 1
                    singleRange = area1.rangeInfo;
                    multipleRange = area2.rangeInfo;
                else
                    singleRange = area2.rangeInfo;
                    multipleRange = area1.rangeInfo;
                end
                diffRange = abs(multipleRange - singleRange);
                diffRange = diffRange(1, :) + diffRange(2, :);
                if min(diffRange) <= 1
                    ret = true;
                end
            end
            
        end
        function ret = connectAreas(lastAreaIds, newAreaIds, areaVector, touchEventVector, frameVector)
            % ������������������֡�ϵ�Area��ID��ɵ�һλ����
            % Ѱ����֡��Area�Ĺ�ϵ
            %   Areaû�к��� ����һ��TouchEvevt
            %   Areaû��ǰ�� ����һ���µ�TouchEvent�������뵽touchEventVector
            %   ����2���гнӹ�ϵ��Area��ά����Ӧ�����ݽṹ
            % ���ص���δ�ҵ����������е�Area��Ҳ�������е�newAreaIds
            % ����δ�ҵ����ϼҡ���newAreas��˵����Ҫ�½�һ���¼�
            % ����δ�ҵ��¼ҵ�lastAreas���Բ�������    
            % NAIVE IMPLEMENT
            ret = newAreaIds;
            newNum = length(newAreaIds);
            lastNum = length(lastAreaIds);
            for newAreaIndex = 1: newNum
                
                isNewEvent = true;
                crtNewArea = areaVector.at(newAreaIds(newAreaIndex));
                
                for lastAreaIndex = 1: lastNum
                    crtLastArea = areaVector.at(lastAreaIds(lastAreaIndex));
                    if crtLastArea.nextID ~= -1
                        continue;
                    end
                    if Area.isConnected(crtNewArea, crtLastArea, frameVector, touchEventVector)
                        if crtLastArea.nextID ~= -1
                            'Multiple area connected'
                        end
                        crtLastArea.nextID = newAreaIds(newAreaIndex);
                        crtNewArea.previousID = lastAreaIds(lastAreaIndex);
                        crtNewArea.touchEventID = crtLastArea.touchEventID;
                        
                        if crtNewArea.inheritedReportID == -1
                            crtNewArea.inheritedReportID = crtLastArea.inheritedReportID;
                        end
                        
                        e = touchEventVector.at(crtLastArea.touchEventID);
                        e.addAreaID(newAreaIds(newAreaIndex), areaVector);
                        isNewEvent = false;
                        break;
                    end
                
                end
                    
                if isNewEvent
                    newEvent = TouchEvent(touchEventVector.size() + 1);
                    newEvent.addAreaID(newAreaIds(newAreaIndex), areaVector);
                    touchEventVector.push_back(newEvent);
                    crtNewArea.touchEventID = touchEventVector.size();
                end
                
            end
           
        end 
    end
    
    methods
        function obj =  Area(varargin)
            if nargin == 0
                return; 
            end
            
            rangeInfo = varargin{1};
            frameId = varargin{2};
            frameVector = varargin{3};
            id = varargin{4};
            
            obj.rangeInfo = rangeInfo;
            obj.frameID = frameId;
            obj.ID = id;
            obj.areaSize = size(obj.rangeInfo, 2);
            obj.LU = Pos(min(obj.rangeInfo(1, :)), min(obj.rangeInfo(2, :)));
            obj.RD = Pos(max(obj.rangeInfo(1, :)), max(obj.rangeInfo(2, :)));
            obj.xSpan = obj.RD.x - obj.LU.x + 1;
            obj.ySpan = obj.RD.y - obj.LU.y + 1;
            
            obj.touchEventID = -1;
            obj.nextID = -1;
            obj.previousID = -1;
            obj.reportPos = Pos(-1, -1);
            obj.weightedCenter = Pos(0, 0);
            obj.average = 0;
            theFrame = frameVector.at(obj.frameID);
            
            maxCap = max(obj.rangeInfo(3, :));
            maxCapX = obj.rangeInfo(1, obj.rangeInfo(3, :) == maxCap);
            maxCapY = obj.rangeInfo(2, obj.rangeInfo(3, :) == maxCap);
            if length(maxCapX) ~= 1
                %'quite strange'
                maxCapX = maxCapX(1);
                maxCapY = maxCapY(1);
            end
            
            diffRangeInfo = abs(obj.rangeInfo - [maxCapX; maxCapY; 0]);
            indexes = ((diffRangeInfo(1, :) <= 1) & (diffRangeInfo(2, :) <= 1)) == 1;
            diffRangeInfo = diffRangeInfo(:, indexes);
            obj.maxCapSmoothed = mean(diffRangeInfo(3, :));
            
            
            obj.average = mean(obj.rangeInfo(3,:));
            sumCap = sum(obj.rangeInfo(3,:));
            obj.weightedCenter = Pos((obj.rangeInfo(1,:) * obj.rangeInfo(3,:)') / sumCap, ...
                (obj.rangeInfo(2,:) * obj.rangeInfo(3,:)') / sumCap);
            
      
            
            % �ж���������Ƿ񱨵�
            % �������֡�����еı��㣬�����ĸ��������������Area��
            % ������Ӧ��ֻ��һ���������������Area�м� ��������鷺�㷨������λ�Ļ�  �п��ܳ��ֶ������ͬʱ����һ����ͨ���ڵ����
            
            frameTouchPointSize = theFrame.touchPosBlock.size();
            obj.reportID = -1;
            obj.inheritedReportID = -1;
            obj.reportNum = 0;
            
            WCToReport = -1;
            for i = 1: frameTouchPointSize %����û�б������˵��frameTouchPointSize == -1
                crtPos = theFrame.touchPosBlock.at(i);
                if sum(ismember(obj.rangeInfo(1:2,:)', [crtPos.x, crtPos.y], 'rows')) > 0
                    obj.reportNum = obj.reportNum + 1;
                    WCToReportTem = theFrame.touchPosPixel.at(i).disTo(Pos(...
                        obj.weightedCenter.x * Consts.BLOCK_WIDTH, obj.weightedCenter.y * Consts.BLOCK_HEIGHT));
                    if obj.reportID ~= -1
                        %'Multiple touch events in one area!'
                        
                        ppos = [];
                        for ij = 1: theFrame.touchPosBlock.size()
                        ppos = [ppos;theFrame.touchPosBlock.at(ij).x, theFrame.touchPosBlock.at(ij).y];
                        end;ppos
                        if WCToReport < WCToReportTem
                            continue;
                        end
                    end
                    
                    WCToReport = WCToReportTem;
                    obj.reportPos = theFrame.touchPosPixel.at(i);
                    obj.reportID = theFrame.touchIDs(i);
                    obj.inheritedReportID = theFrame.touchIDs(i); % ���ڱ���ͱ����area��˵  �̳��Լ�
                    
                    % �о�Ӧ�ü��ϱ�����Ϣ
                    
                    %break;
                end
                
            end
            
        end
        function ret = copyArea(obj)
            ret = Area();
            ret.weightedCenter = obj.weightedCenter;
            ret.areaSize = obj.areaSize;
            ret.average = obj.average;
            ret.rangeInfo = obj.rangeInfo;
            ret.xSpan = obj.xSpan;
            ret.ySpan = obj.ySpan;
            ret.LU = obj.LU;
            ret.RD = obj.RD;
            ret.ID = obj.ID;
            ret.frameID = obj.frameID;
            ret.reportID = obj.reportID;
            
            ret.touchEventID = obj.touchEventID;
            ret.nextID = obj.nextID;
            ret.previousID = obj.previousID;
        end
        function ret = getFullRange(obj) 
            ret = full(sparse(obj.rangeInfo(1, :), obj.rangeInfo(2, :), ...
                ones(1, length(obj.rangeInfo(1, :))), Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM));
        end
        function ret = getLabel(obj, globalData)
                touchID = obj.reportID;
                if touchID == -1
                    ret = Consts.UNKNOWN;
                    return;
                end
                crtFrame = globalData.frames.at(obj.frameID);
                label = cell2mat(crtFrame.labels.at(crtFrame.touchIDs == touchID));
                if strcmp(label, 'SLIDE')
                    ret = Consts.SLIDE;
                elseif strcmp(label, 'DRAG')
                    ret = Consts.DRAG;
                elseif strcmp(label, 'CLICK')
                    ret = Consts.CLICK;
                elseif strcmp(label, 'FORCE_CLICK')
                    ret = Consts.FORCE_CLICK;
                else
                    ret = Consts.UNKNOWN;
                end
        end
    end
end