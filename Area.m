classdef Area < handle
    properties
       weightedCenter; %重心 Pos
       areaSize;% 面积
       average;% 电容数据平均值
       capacitysum;%电容数据加和值
       rangeInfo;% 2 * size，每列对应区域中每一个格子，第一行为x坐标，第二行为y坐标
       xSpan;% 在x方向上的跨度
       ySpan;% 在y方向上的跨度
       LU;% Area包围盒左上角坐标 Pos
       RD;% Area包围盒右下角坐标 Pos
       ID;% 自己的编号
       frameID;% 所属的Frame编号
       reportID;% 报点的touch坐标 如果没有报点的话是-1
       
       touchEventID;% 所属的touchEvent编号
       nextID;% 上一个Area编号
       previousID;% 下一个Area编号
    end
    methods(Static)
        function ret = isConnected(area1, area2, frameVector)
            if abs(frameVector.at(area1.frameID).time - frameVector.at(area2.frameID).time)...
                    > Consts.CONNECTED_AREA_LARGEST_TIME_OFFSET
                ret = false;
                return;
            end
            
            if area1.reportID ~= area2.reportID && area1.reportID ~= -1 && area2.reportID ~= -1
                ret = false;
                return;
            end
            
            
            if area1.reportID ~= -1 && area2.reportID ~= -1 
                ret = true;
                return;
            end
            
            % 判断两个均未报点的area，或者一个报点一个没报点（内部插帧的情况）是否构成相互连接的关系
            % 要求体积较小的area的重心落在体积较大的area内部
            
            
            area1WCRounded = area1.weightedCenter.round();
            area2WCRounded = area2.weightedCenter.round();
            if sum(ismember(area1.rangeInfo', [area2WCRounded.x, area2WCRounded.y], 'rows')) > 0 && ...
                    sum(ismember(area2.rangeInfo', [area1WCRounded.x, area1WCRounded.y], 'rows')) > 0
                ret = true;
            else
                ret = false;
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
            % 对于未找到下家的lastAreas可以不作处理
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
                    if Area.isConnected(crtNewArea, crtLastArea, frameVector)
                        crtLastArea.nextID = newAreaIds(newAreaIndex);
                        crtNewArea.previousID = lastAreaIds(lastAreaIndex);
                        crtNewArea.touchEventID = crtLastArea.touchEventID;
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
            
            obj.weightedCenter = Pos(0, 0);
            obj.average = 0;
            crtWeightX = 0;
            crtWeightY = 0;
            theFrame = frameVector.at(obj.frameID);
            for i = 1: obj.areaSize
                crtCapValue = theFrame.capacity(obj.rangeInfo(1, i), obj.rangeInfo(2, i));
                obj.average = obj.average + crtCapValue;
                crtWeightX = obj.rangeInfo(1, i) * crtCapValue + crtWeightX;
                crtWeightY = obj.rangeInfo(2, i) * crtCapValue + crtWeightY;
%                 obj.weightedCenter = obj.weightedCenter.add(...
%                     Pos(obj.rangeInfo(1, i), obj.rangeInfo(2, i)).mul(crtCapValue));
            end
            
            obj.weightedCenter = Pos(crtWeightX / obj.average, crtWeightY / obj.average); 
            obj.capacitysum = obj.average;
            obj.average = obj.average / obj.areaSize;
            
            % 判断这个区域是否报点
            % 遍历这个帧上所有的报点，看看哪个报点落在了这个Area中
            % 理论上应该只有一个报点落在了这个Area中间 但是如果洪泛算法不够到位的话  有可能出现多个报点同时落在一个联通域内的情况
            
            frameTouchPointSize = theFrame.touchPosBlock.size();
            obj.reportID = -1;
            for i = 1: frameTouchPointSize
                crtPos = theFrame.touchPosBlock.at(i);
                if sum(ismember(obj.rangeInfo', [crtPos.x, crtPos.y], 'rows')) > 0
                    if obj.reportID ~= -1
                        'Multiple touch events in one area!'
                    end
                    
                    obj.reportID = theFrame.touchIDs(i);
                    break;
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
    end
end