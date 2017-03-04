classdef Frame < handle
    properties
       time;
       ID;
       capacity;% ��¼��������
       areaInfo;% ������֡�ϵ�������Ϣ��16 * 28�ľ���1��ʾ������ݸ�������ĳһ��area�м䣬0��ʾ��������һ��Area�У�-1��ʾ��δ�����鷺
       touchIDs;% ÿ��Ԫ�����ڸ�Frame�ϵ�touchId
       touchPosPixel;% ÿ��Ԫ��������Pos��Vector����¼���λ�õ���������ֵ��Ӧ����touchID���Ӧ
       touchPosBlock;% ��¼ÿ������λ�������ĸ����ݸ�����
       areaIDs;% ��һ��1ά������ÿ��Ԫ�ض����ڸ�Frame�ϵ�Area�����
       
       labels;% ����ÿ��touchId�ı��
       isValid;% �ж������Ƿ�Ϸ�
    end
       
    methods(Static)
        function res = isValidPos(p)
            if p.x > 0 && p.y > 0 &&...
                    p.x <= Consts.CAPACITY_BLOCK_X_NUM &&...
                    p.y <= Consts.CAPACITY_BLOCK_Y_NUM
                res = true;
            else
                res = false;
            end
        end
    end
    
    methods
        function obj = Frame(varargin)
            if nargin == 0
                return;
            end
            
            time = varargin{1};
            isReported = varargin{3};
            reportedID  = varargin{4};
            pixelX  = varargin{5};
            pixelY  = varargin{6};
            label  = varargin{7};
            cap  = varargin{8};
            id = varargin{9};
            
            obj.ID = id;
            capacityRawData = cell2mat(cap);
            [capacityDataLine] = strread(capacityRawData, '%d', 'delimiter', ';');
            
            if Consts.TOTAL_BLOCK_SIZE == length(capacityDataLine)
				obj.capacity = reshape(capacityDataLine,...
				 Consts.CAPACITY_BLOCK_Y_NUM, Consts.CAPACITY_BLOCK_X_NUM)';
				obj.isValid = true;
            else
				obj.isValid = false;
				return;
            end
            
            obj.touchIDs = [];
            obj.areaIDs = [];
            obj.labels = Vector('cell');
            obj.touchPosPixel = Vector('Pos');
            obj.touchPosBlock = Vector('Pos');            
            obj.time = time;
            
            if strcmpi(cell2mat(isReported), 'False')
                return;
            end
            
            obj.touchIDs = [obj.touchIDs, reportedID];
            obj.labels.push_back(label);
            obj.touchPosPixel.push_back(Pos(pixelX, pixelY));
            
            blockX = floor(pixelX / Consts.BLOCK_WIDTH) + 1;
            blockY = floor(pixelY / Consts.BLOCK_HEIGHT) + 1;
            if blockX > Consts.CAPACITY_BLOCK_X_NUM
                blockX = Consts.CAPACITY_BLOCK_X_NUM;
            end
            if blockY > Consts.CAPACITY_BLOCK_Y_NUM
                blockY = Consts.CAPACITY_BLOCK_Y_NUM;
            end
            obj.touchPosBlock.push_back(Pos(blockX, blockY));            
        end
        function merge(obj, f)
            % ��f�ͱ�֡�ϲ���һ��
            % Ҫ��obj��f��ʱ����һ���ģ�ֻ�Ƕ�Ӧ�ڲ�ͬ��touchId
            if obj.time ~= f.time
                'Different frames can not be merged!'
                return;
            end
            obj.touchIDs = [obj.touchIDs, f.touchIDs];
            obj.touchPosPixel.merge(f.touchPosPixel);
            obj.touchPosBlock.merge(f.touchPosBlock);
            obj.labels.merge(f.labels);
        end
        function ret = flooding(obj, areaVector, frameVector)
            % �Ը�֡���к鷺
            % ȷ�������ɱ�֡�����е�Areaʵ�����������ӵ�һ��ȫ�ֵ�Area�б���areaVector����
            % ���ظ�֡���³��ֵ�Areaʵ����ȫ��Area�б��ϱ�ŵ���ֹ
            if sum(sum(obj.capacity > Consts.AREA_CAPACITY_THRESHOLD)) == 0
                ret = [];
                return;
            end
            
            
            obj.areaInfo = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM) - 1;
            ret = [];
            for x = 1: Consts.CAPACITY_BLOCK_X_NUM
                for y = 1: Consts.CAPACITY_BLOCK_Y_NUM
                    % (x, y) Ӧ�������Area�鷺�����
                    if obj.areaInfo(x, y) ~= -1
                        continue;
                    end
                    if obj.capacity(x, y) < Consts.AREA_CAPACITY_THRESHOLD
                        obj.areaInfo(x, y) = 0;
                        continue;
                    end
                    obj.areaInfo(x, y) = 1;
                    
                    % a new area
                    areaRangeInfo = [];
                    posQueue = Queue('Pos');
                    posQueue.offer(Pos(x, y));
                    
                    while ~posQueue.isempty()
                        crtPos = posQueue.poll();
                        areaRangeInfo = [areaRangeInfo, [crtPos.x; crtPos.y]];
                        for i = 1: 4
                            switch(i)
                                case 1
                                    temPos = Pos(crtPos.x - 1, crtPos.y);
                                case 2
                                    temPos = Pos(crtPos.x + 1, crtPos.y);
                                case 3
                                    temPos = Pos(crtPos.x, crtPos.y - 1);
                                case 4
                                    temPos = Pos(crtPos.x, crtPos.y + 1);
                            end
                            
                            if temPos.x <= 0 || temPos.y <= 0 || ...
                                    temPos.x > Consts.CAPACITY_BLOCK_X_NUM || temPos.y > Consts.CAPACITY_BLOCK_Y_NUM...
                                    || obj.areaInfo(temPos.x, temPos.y) ~= -1
                               continue; 
                            end
                            
                            if obj.isInArea(temPos)
                                obj.areaInfo(temPos.x, temPos.y) = 1;
                                posQueue.offer(temPos);
                            else
                                obj.areaInfo(temPos.x, temPos.y) = 0;
                            end
                        end
                    end
                    areaVector.push_back(Area(areaRangeInfo, obj.ID, frameVector, areaVector.size() + 1));
                    ret = [ret, areaVector.size()];
                    
                end % for y
            end % for x
            
            obj.areaIDs = ret;
        end %function flooding
        function res = isInArea(obj, p) % ��������ʵ�ʵ�Ҫ���޸�
            if obj.capacity(p.x, p.y) >= Consts.AREA_CAPACITY_THRESHOLD 
                res = true;
            else
                res = false;
            end
        end
        
        function ret = copyFrame(obj)
            ret = Frame();
            ret.time = obj.time;
            ret.ID = obj.ID;
            ret.capacity = obj.capacity;
            ret.areaInfo = obj.areaInfo;
            ret.touchIDs = obj.touchIDs;
            ret.touchPosPixel = Vector('Pos');
            ret.touchPosBlock = Vector('Pos');
            ret.labels = Vector('cell');
            touchPosSize = obj.touchPosPixel.size();
            for i = 1: touchPosSize
                ret.touchPosPixel.push_back(obj.touchPosPixel.at(i));
                ret.touchPosBlock.push_back(obj.touchPosBlock.at(i));
                ret.labels.push_back(obj.labels.at(i));
            end
            ret.areaIDs = obj.areaIDs;
            ret.isValid = obj.isValid;
        end
    end
end