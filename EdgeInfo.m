classdef EdgeInfo
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        edge
        edgecapacity
        secondcapacity
        onedge
        normallen
        edgelen
        center2edge
        fromedge
    end
    
    methods (Static) 
        function obj = FromArea(frames,area)
           
           
           
           WIDTH = Consts.CAPACITY_BLOCK_X_NUM;
           HEIGHT = Consts.CAPACITY_BLOCK_Y_NUM;


           n = area.areaSize;
           x = [];
           y = [];
           
           ret = [0,0,0,0,0,0,0,0];
           if(n == 0)
               sprintf('EdgeInfo--size==0--error')
               ret = [0,0,0,0,0,0,0,0];
               %return
           end
           
           for i=1:n
               x = [x,area.rangeInfo(1,i)];
               y = [y,area.rangeInfo(2,i)];
           end
           
           % left edge
           minx = min(x);
           dis = minx - 1;
           edgecapacity = 0;
           secondcapacity = 0;
           if(dis == 0)
               % contact
               I = find(x == 1);
               y_x1 = y(I);
               J = find(x == 2);
               y_x2 = y(J);
               for j = min(y_x1):max(y_x1)
                edgecapacity = edgecapacity + frames.at(area.frameID).capacity(1,j);
                
                
               end
               if(~isempty(y_x2))
                   for m = min(y_x2):max(y_x2)
                    secondcapacity = secondcapacity + frames.at(area.frameID).capacity(2, m);
                   end
               end
               edgelen = max(y_x1)-min(y_x1)+1;
               edgedeep = max(x);
               edge2center = area.weightedCenter.x - 1;
               
               if(edge2center < 0.3 && area.weightedCenter.x > 1.3)
                   center2edge = edge2center
                   weightedCenter = area.weightedCenter.x
               end
               
                   
               retl = [1, edgedeep, edgelen, edgecapacity,secondcapacity,edge2center];

           else
               edge2center = area.weightedCenter.x - 1;
               retl = [0, 0, 0, 0, 0, edge2center];
           end
           
           % right edge
           maxx = max(x);
           dis = WIDTH - maxx;
           if(dis == 0)
               % contact
               I = find(x == WIDTH);
               y_xwidth = y(I);
               J = find(x == WIDTH-1);
               y_xwidth2 = y(J);
               for j = min(y_xwidth):max(y_xwidth)
                edgecapacity = edgecapacity + frames.at(area.frameID).capacity(WIDTH, j);
               end
               if(~isempty(y_xwidth2))
                   for m = min(y_xwidth2):max(y_xwidth2)
                    secondcapacity = secondcapacity + frames.at(area.frameID).capacity(WIDTH-1, m);
                   end
               end
               edgelen = max(y_xwidth)- min(y_xwidth) + 1;
               edgedeep = WIDTH - max(x) + 1;
               edge2center = WIDTH - area.weightedCenter.x;
               retr = [1,edgedeep, edgelen,edgecapacity, secondcapacity, edge2center];

           else
               edge2center = WIDTH - area.weightedCenter.x;
               retr = [0, 0, 0, 0,0, edge2center];
           end
           
           % Top edge
           miny = min(y);
           dis = miny - 1;
           if(dis == 0)
               % contact
               I = find(y == 1);
               x_y1 = x(I);
               J = find(y == 2);
               x_y2 =x(J);
               for j = min(x_y1):max(x_y1)
                edgecapacity = edgecapacity + frames.at(area.frameID).capacity(j, 1);
               end
               if(~isempty(x_y2))
                   for m = min(x_y2):max(x_y2)
                    secondcapacity = secondcapacity +frames.at(area.frameID).capacity(m, 2);
                   end
               end
               edgelen = max(x_y1)-min(x_y1)+1;
               edgedeep = max(y);
               edge2center = area.weightedCenter.y - 1;
               rett = [1,edgedeep, edgelen,edgecapacity,secondcapacity, edge2center];

           else
               edge2center = area.weightedCenter.y - 1;
               rett = [0, 0, 0, 0,0, edge2center];
           end
           
           % bottom edge
           maxy = max(y);
           dis = HEIGHT - maxy;
           if(dis == 0)
               % contact
               I = find(y == HEIGHT);
               x_yheight = x(I);
               J = find(y == HEIGHT-1);
               x_yheight2 = x(J);
               for j = min(x_yheight):max(x_yheight)
                edgecapacity = edgecapacity + frames.at(area.frameID).capacity(j, HEIGHT);
               end
               if(~isempty(x_yheight2))
                   for m = min(x_yheight2):max(x_yheight2)
                    secondcapacity = secondcapacity + frames.at(area.frameID).capacity(m, HEIGHT-1);
                   end
               end
               edgelen = max(x_yheight)- min(x_yheight) + 1;
               edgedeep = HEIGHT - max(y) + 1;
               edge2center = HEIGHT - area.weightedCenter.y;
               retb = [1,edgedeep, edgelen, edgecapacity,secondcapacity,edge2center];

           else
               edge2center = HEIGHT - area.weightedCenter.y;
               retb = [0, 0, 0, 0,0, edge2center];
           end
           
           ret = [retl;retr;rett;retb];
           
           if(max(ret(:,1))==0)
               ret = [0,0,0,0,0,0,0,0];
           else
               [Y,I] = max(ret(:,3));
               [M,N] = min(ret(:,6));
               %ret = [I,ret(I,:),ret(I,end)<0.3];
               ret = [I,ret(I,1:5),ret(N,6),ret(N,end)<0.3];
           end

           obj = EdgeInfo(ret(1),ret(2), ret(3), ret(4), ret(5), ret(6),ret(7),ret(8));
            %obj = 1;
        end
    end
    
    methods
        function obj = EdgeInfo(edge,onedge,normallen,edgelen,edgecapacity,secondcapacity,center2edge,fromedge)
%             switch(edge)
%                 case 0
%                     obj.edge = mid;
%                 case 1
%                     obj.edge = left;
%                 case 2
%                     obj.edge = right;
%                 case 3
%                     obj.edge = top;
%                 case 4
%                     obj.edge = bottom;
%             end
            obj.edge = edge;
            obj.edgecapacity = edgecapacity;
            obj.secondcapacity = secondcapacity;
            obj.onedge = onedge;
            obj.normallen = normallen;
            obj.edgelen = edgelen;
            obj.center2edge = center2edge;
            obj.fromedge = fromedge;
        end
    end
    
end
