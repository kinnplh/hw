classdef Area < handle
    properties
       weightedCenter; %���� Pos
       areaSize;% ���
       average;% ��������ƽ��ֵ
       capacitysum;%�������ݼӺ�ֵ
       rangeInfo;% 2 * size��ÿ�ж�Ӧ������ÿһ�����ӣ���һ��Ϊx���꣬�ڶ���Ϊy����
       xSpan;% ��x�����ϵĿ��
       ySpan;% ��y�����ϵĿ��
       LU;% Area��Χ�����Ͻ����� Pos
       RD;% Area��Χ�����½����� Pos
       ID;% �Լ��ı��
       frameID;% ������Frame���
       reportID;% �����touch���� ���û�б���Ļ���-1
       
       touchEventID;% ������touchEvent���
       nextID;% ��һ��Area���
       previousID;% ��һ��Area���
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
            
            % �ж�������δ�����area������һ������һ��û���㣨�ڲ���֡��������Ƿ񹹳��໥���ӵĹ�ϵ
            % Ҫ�������С��area��������������ϴ��area�ڲ�
            
            
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
            
            % �ж���������Ƿ񱨵�
            % �������֡�����еı��㣬�����ĸ��������������Area��
            % ������Ӧ��ֻ��һ���������������Area�м� ��������鷺�㷨������λ�Ļ�  �п��ܳ��ֶ������ͬʱ����һ����ͨ���ڵ����
            
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