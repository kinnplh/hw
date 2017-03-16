classdef Frame < handle
    properties
       time;
       filePath;
       ID;
       capacity;% 记录电容数据
       areaInfo;% 表征该帧上的区域信息，16 * 28的矩阵，1表示这个电容格子输入某一个area中间，0表示不在任意一个Area中，-1表示尚未经过洪泛
       touchIDs;% 每个元素是在该Frame上的touchId
       touchPosPixel;% 每个元素类型是Pos的Vector，记录点击位置的像素坐标值，应该与touchID相对应
       touchPosBlock;% 记录每个报点位置落在哪个电容格子里
       areaIDs;% 是一个1维向量，每个元素都是在该Frame上的Area的序号
       
       labels;% 对于每个touchId的标记
       isValid;% 判断数据是否合法
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
            obj.filePath = varargin{10};
            
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
            % 将f和本帧合并在一起
            % 要求obj和f的时间是一样的，只是对应于不同的touchId
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
            ret = [];
            frame = obj;
            WIDTH = Consts.CAPACITY_BLOCK_X_NUM; 
            HEIGHT = Consts.CAPACITY_BLOCK_Y_NUM;
            
            data = frame.capacity;
            
            localmax = [];
            for x = 1:WIDTH,
                for y = 1:HEIGHT,
                    xx = max([x-1,1]):min([WIDTH,x+1]);
                    yy = max([y-1,1]):min([HEIGHT,y+1]);
                    d = data(xx,yy);
                    [m,I] = max(d(:));
                    if(m(1) == data(x,y) && m(1) >= Consts.AREA_CAPACITY_THRESHOLD)
                        localmax = [localmax; x y m(1)];
                    end
                end
            end
            
            if(isempty(localmax))
                % non-local-max
            else
                % sort the local max
                [~,I] = sort(localmax(:,3),'descend');
                localmax = localmax(I,:);

                obj.areaInfo = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM) - 1;
                ret = [];
                                
                for ii = 1:length(localmax(:,1))
                    % (x, y) ??????????Area?é????????
                    x = localmax(ii,1);
                    y = localmax(ii,2);
                    maxillum = localmax(ii,3);
                    
                    if(isempty(maxillum))
                                a = 1;
                    end
                            
                    if obj.areaInfo(x, y) ~= -1
                        continue;
                    end
                   
                    obj.areaInfo(x, y) = 1;
                    
                    % a new area
                    areaRangeInfo = [];
                    posQueue = Queue('Pos');
                    newpos = Pos(x, y);
                    newpos.minillum = maxillum;
                    posQueue.offer(newpos);
                    
                    while ~posQueue.isempty()
                        crtPos = posQueue.poll();
                        areaRangeInfo = [areaRangeInfo, [crtPos.x; crtPos.y; obj.capacity(crtPos.x, crtPos.y)]];
                        
                        for iii = 1: 4
                            switch(iii)
                                case 1
                                    temPos = Pos(crtPos.x - 1, crtPos.y);
                                case 2
                                    temPos = Pos(crtPos.x + 1, crtPos.y);
                                case 3
                                    temPos = Pos(crtPos.x, crtPos.y - 1);
                                case 4
                                    temPos = Pos(crtPos.x, crtPos.y + 1);
                            end
                            
                            if temPos.x <= 0 || temPos.y <= 0 ||...
                                    temPos.x > Consts.CAPACITY_BLOCK_X_NUM || temPos.y > Consts.CAPACITY_BLOCK_Y_NUM...
                                    || obj.areaInfo(temPos.x, temPos.y) ~= -1
                                continue;
                            end
                            
                            % connect and update minillum
                            illum = frame.capacity(temPos.x, temPos.y);
                            lastillum = frame.capacity(crtPos.x, crtPos.y);
                            minillum = crtPos.minillum;
                            
                            
                            if obj.IsConnected(illum, lastillum, minillum, maxillum)
                                obj.areaInfo(temPos.x, temPos.y) = 1;
                                if(illum<minillum)
                                    temPos.minillum = illum;
                                else
                                    temPos.minillum = minillum;
                                end
                                posQueue.offer(temPos);
                                if(isempty(temPos.minillum))
                                    a = 1;
                                end
                            end
                        end
                    end
                    
                    area = Area(areaRangeInfo, obj.ID, frameVector, areaVector.size() + 1);
                    areaVector.push_back(area);
                    ret = [ret, areaVector.size()];
                end
            end
            obj.areaIDs = ret;
        end
        function res = IsConnected(obj, illum, lastillum, minillum, maxillum) %????????????????
            % res = obj.rawData.capacityData(p.x, p.y) > min(obj.threshold, illum/6); 
            % illum = obj.capacity(p.x, p.y);
            
            th = 50;
            if(maxillum < 250)
                th = 50;
            elseif(maxillum<2000)
                th = maxillum/5;
            else
                th = 400;
            end

            if(illum > th && illum<=1.2*minillum)
            %if(illum > 50 && illum>0.3*illum0 && illum<=2*illum0)
                res = 1;
            else
                res = 0;
            end
        end
        function ret = flooding1(obj, areaVector, frameVector)
            % 对该帧进行洪泛
            % 确定并生成本帧上所有的Area实例，并且添加到一个全局的Area列表（areaVector）中
            % 返回该帧上新出现的Area实例在全局Area列表上编号的起止
            if sum(sum(obj.capacity > Consts.AREA_CAPACITY_THRESHOLD)) == 0
                ret = [];
                return;
            end
            
            
            obj.areaInfo = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM) - 1;
            ret = [];
            for x = 1: Consts.CAPACITY_BLOCK_X_NUM
                for y = 1: Consts.CAPACITY_BLOCK_Y_NUM
                    % (x, y) 应该是这个Area洪泛的起点
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
        function res = isInArea(obj, p) % 后续根据实际的要求修改
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
            ret.filePath = obj.filePath;
            touchPosSize = obj.touchPosPixel.size();
            for i = 1: touchPosSize
                ret.touchPosPixel.push_back(obj.touchPosPixel.at(i));
                ret.touchPosBlock.push_back(obj.touchPosBlock.at(i));
                ret.labels.push_back(obj.labels.at(i));
            end
            ret.areaIDs = obj.areaIDs;
            ret.isValid = obj.isValid;
        end
        function showFrame(obj, whiteNum) 
            image = obj.capacity / whiteNum;
            imshow(image','InitialMagnification','fit');
        end
        function showAreas(obj, whiteNum, frameVector, areaVector)
            image = zeros(Consts.CAPACITY_BLOCK_X_NUM, Consts.CAPACITY_BLOCK_Y_NUM);
            for i=1:length(obj.areaIDs)
                crtArea = areaVector.at(obj.areaIDs(i));
                crtFrame = frameVector.at(crtArea.frameID);
                for j = 1:crtArea.areaSize
                    x = crtArea.rangeInfo(1,j);
                    y = crtArea.rangeInfo(2,j);
                    image(x,y) = crtFrame.capacity(x,y) / whiteNum;
                end
            end
            imshow(image','InitialMagnification','fit');
        end
    end
end