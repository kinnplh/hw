classdef Area < handle
    properties
       weightedCenter; %重心 Pos
       areaSize;% 面积
       average;% 电容数据平均值
       rangeInfo;% 2 * size，每列对应区域中每一个格子，第一行为x坐标，第二行为y坐标, 第三行为电容值
       % 电容值需要在洪泛的时候添加
       xSpan;% 在x方向上的跨度
       ySpan;% 在y方向上的跨度
       LU;% Area包围盒左上角坐标 Pos
       RD;% Area包围盒右下角坐标 Pos
       ID;% 自己的编号
       frameID;% 所属的 Frame 编号
       reportID;% 报点的编号 如果没有报点的话是-1
       inheritedReportID;% 如果这个area的祖先曾今报过点的话
       reportPos; % 该area报点的位置 无报点则(-1, -1)
       maxCapSmoothed; % 最大值及其附近的共9个block的电容的均值
       
       touchEventID;% 所属的 touchEvent 编号
       nextID;% 上一个 Area 编号
       previousID;% 下一个 Area 编号
       
       reportNum;
    end
    methods(Static)
        function ret = isConnected(area1, area2, frameVector, touchEventVector)
            %?增加单调性的判断
            %时间差过大，不予考虑
            if abs(frameVector.at(area1.frameID).time - frameVector.at(area2.frameID).time)...
                    > Consts.CONNECTED_AREA_LARGEST_TIME_OFFSET
                ret = false;
                return;
            end
            
            %如果两Area的TouchID都不是-1的话，通过TouchID来进行判断
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
            else % 时间相同，说明在同一帧中
                ret = false;
                return;
            end
            
            
            % 判断两个均未报点的area，或者一个报点一个没报点（内部插帧的情况）是否构成相互连接的关系

%             area1WCRounded = area1.weightedCenter.round();
%             area2WCRounded = area2.weightedCenter.round();
%单调性使用最亮值
            if sum(ismember(area1.rangeInfo(1:2, :)', area2.rangeInfo(1:2, :)', 'rows')) >= min(area1.areaSize, area2.areaSize) / 2
                lastEvent = touchEventVector.at(oldArea.touchEventID);
                if lastEvent.firstReportedAreaID ~= -1 && lastEvent.lastReportedAreaID == -1 % 在down和up之间
                    ret = true;
                elseif lastEvent.firstReportedAreaID == -1 % 在down之前  要求后续的area不能够过小
                    %if youngArea.areaSize * youngArea.average >= oldArea.areaSize * oldArea.average / 1.1
                    if youngArea.average >= oldArea.average / 1.1
                        ret = true;
                    else
                        ret = false;
                    end
                else% 在up之后，要求后续的area不能变大
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
                % 特殊判断
                % 要求降低为 两个格子有一条边重合
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
            % 输入和输出都是相邻两帧上的Area的ID组成的一位矩阵
            % 寻找两帧上Area的关系
            %   Area没有后续 结束一个TouchEvevt
            %   Area没有前驱 生成一个新的TouchEvent，并加入到touchEventVector
            %   连接2个有承接关系的Area并维护相应的数据结构
            % 返回的是未找到后续的所有的Area，也就是所有的newAreaIds
            % 对于未找到“上家”的newAreas来说都需要新建一个事件
            % 对于未找到下家的lastAreas可以不作处理？    
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
            
      
            
            % 判断这个区域是否报点
            % 遍历这个帧上所有的报点，看看哪个报点落在了这个Area中
            % 理论上应该只有一个报点落在了这个Area中间 但是如果洪泛算法不够到位的话  有可能出现多个报点同时落在一个联通域内的情况
            
            frameTouchPointSize = theFrame.touchPosBlock.size();
            obj.reportID = -1;
            obj.inheritedReportID = -1;
            obj.reportNum = 0;
            
            WCToReport = -1;
            for i = 1: frameTouchPointSize %对于没有报点的来说，frameTouchPointSize == -1
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
                    obj.inheritedReportID = theFrame.touchIDs(i); % 对于本身就报点的area来说  继承自己
                    
                    % 感觉应该加上报点信息
                    
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