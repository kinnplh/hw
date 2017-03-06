classdef Classifier
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    %modified by Violynne
    
    properties
    end
    
    methods (Static)
        
    function ret = IsValidShape(area, ei, term)
        ret = 0;
        if(strcmp(term,'fromedge'))
            ret = area.areaSize <= 25 && area.xSpan/area.ySpan>=0.5;
        elseif(strcmp(term, 'onedge'))
            if(area.xSpan == 0 || area.ySpan == 0)
                ret = 0;
            else
                ret = (area.ySpan/area.xSpan <= 3 && ei.edgelen < 10);
            end 
        elseif(strcmp(term, 'middle'))
            if(area.xSpan == 0 || area.ySpan == 0)
                ret = 0;
            else
                ret = area.ySpan/area.xSpan <= 3 && ei.edgelen < 10;
            end
        end
    end
        
        function ret = ClassifyEmerge(globalData,evt)
            
            Uncertain = 0;
            True = 1;
            False = 2;
            
            areas = globalData.areas;
            evts = globalData.evts;
            frames = globalData.frames;
            
            %亮斑出现的初始帧及其边缘信息
            birthArea = areas.at(evt.areaIDs(1));
            Bei = EdgeInfo.FromArea(frames,birthArea);
            %系统报down帧及其边缘信息
            downArea = areas.at(evt.firstReportedAreaID);
            Dei = EdgeInfo.FromArea(frames,downArea);
            %从亮斑出现的初始帧到系统报down帧经历的毫秒数
            timelength = frames.at(downArea.frameID).time - frames.at(birthArea.frameID).time;
            
            if(Bei.onedge)%亮斑出现于边缘上
                if((Bei.edge == 3) || (Bei.edge == 4))%亮斑出现于上下边缘
                       if(Classifier.IsValidShape(downArea,Dei,'onedge'))%报点时连通域是边缘上的有效形状
                           %TOUCHEDGE & SWIPEEDGE 边缘点击 & 边缘滑动
                           ret = True;
                       else
                           %QUARTERGRIP 横屏情况时的侧边握持误触
                           ret = False;
                       end
                       
                elseif((Bei.edge == 1) || (Bei.edge == 2)) %亮斑出现于左右边缘
                       if(~Bei.fromedge)%亮斑不是从边缘生长起来的
                           if(Classifier.IsValidShape(birthArea,Bei,'fromedge'))%报点时连通域是边缘上的有效形状
                               %TOUCHNEAR & SWIPENEAR 接近边缘的点击 & 滑动
                               ret = True;
                           else
                               %MOVEBIG & STRANGE 与边缘相连的连带大鱼际 & 与边缘相连的其他异形误触
                               ret = False;
                           end
                       else%亮斑从边缘生长起来
                           if(Classifier.IsValidShape(birthArea,Bei,'fromedge'))%报点时连通域是边缘上的有效形状
                                 if(timelength>70)%亮斑出现到系统报down的时间超过70ms
                                     %GRIPFINGER 握持手指
                                     ret = False;
                                 elseif(downArea.average>1400)%报点时连通域电容图像平均值超过1400
                                     %TOUCHEDGE & SWIPEEDGE 边缘点击 & 滑动
                                     ret = True;
                                 else
                                     %TOUCHEDGE & SWIPEEDGE & GRIPFINGER
                                     %较难区分的轻点击 & 滑动 和 快握持
                                     ret = Uncertain;
                                 end
                           else%报点时连通域不是边缘上的有效形状
                               %GRIPBIG 持握大鱼际
                               ret = False;
                           end
                       end
                       
                    % lt,ld,rt,rd
                        %亮斑出现在四个边角
                end    
                else%亮斑出现不在边缘
                       if(~Classifier.IsValidShape(downArea,Dei,'middle'))
                           %MOVEBIG & STRANGE 不与边缘相连的连带大鱼际 & 不与边缘相连的其他异形
                           ret = False;
                       else
                           %TOUCHMID & SWIPEEDGE 远离屏幕的点击 & 滑动
                           ret = True;
                       end
                end
        end
        
        function ret = ClassifyDisappear(globalData,evt,crtFrame)
           Uncertain = 0;
           True = 1;
           False = 2;
           areas = globalData.areas;
           evts = globalData.evts;
           frames = globalData.frames;
           
           downArea = areas.at(evt.firstReportedAreaID);
           Dei = EdgeInfo.FromArea(frames,downArea);
           
           find = 0;
           for i = 1: length(crtFrame.areaIDs)
               checkArea = areas.at(crtFrame.areaIDs(i));
               if(checkArea.touchEventID == evt.ID)
                   curArea = checkArea;
                   find = 1;
               end
           end
           
           if(find == 0)
               ret = False;%实际上还是Uncertain
           else
               %获取当前帧的当前考虑的event的当前area
               timedis = frames.at(curArea.frameID).time - frames.at(downArea.frameID).time;
%              capacitydis = abs(curArea.capacitysum - downArea.capacitysum);
               capacitydis = abs(curArea.average * curArea.areaSize - downArea.average * downArea.areaSize);
               disappearRatio =  (capacitydis+1)/(timedis+1);

               if(timedis >= 30 && disappearRatio > 50)
                   ret = True;
               else
                   ret = False;%实际上还是Uncertain
               end
               ret = Uncertain;
           end
           
        end
     
%         function GlobalChange()
%             
%         end
%         
%         function IsSwipe()
%             
%         end
    end
end
