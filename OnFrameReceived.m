function OnFrameReceived(globalData,crtFrame)
% 此处显示有关此函数的摘要
    areas = globalData.areas;
    evts = globalData.evts;
    frames = globalData.frames;

%crtFrame中不是所有的area都有报点，对于有reportedID的area，才观察它所在的touchevent
for i = 1:length(crtFrame.areaIDs)
    areaIndex = crtFrame.areaIDs(i);
    checkarea = areas.at(areaIndex);
    evt = evts.at(checkarea.touchEventID);
    
    % 处理每个报点的情况，利用触点形成的特征
    % 能进入ClassifyEmerge判断：当前帧是当前观察的event的系统报down的那一帧
    
    if((evt.state == TouchEvent.Undefined) && (checkarea.ID == evt.firstReportedAreaID))
        predictEmerge = Classifier.ClassifyEmerge(evt);
        if(predictEmerge == TouchEvent.True)
            truelist.add(evt);
            evt.state = TouchEvent.True;
            %对于已经判定为true的，不再会进入判断
        elseif(predictEmerge == TouchEvent.False)
            falselist.add(evt);
            evt.state = TouchEvent.False;
        else % predictEmerge == TouchEvent.Uncertain
            evt.state = TouchEvent.Uncertain;
        end
    end
    
    % 处理每个报点的情况，利用触点消失的特征
    % 能进入ClassifyDisappear判断：当前帧是当前观察的event的系统报down之后的帧，且在报down时的结果是Uncertain，而且这个结果只能在down之后30ms计算
    
    if((evt.state == TouchEvent.Uncertain)  && (crtFrame.time - frames.at(areas.at(evt.firstReportedAreaID).frameID).time > 30))
        predictDisappear = Classifier.ClassifyDisappear(evt,crtFrame);
        if(predictDisappear == TouchEvent.True)
            truelist.add(evt);
            evt.state = TouchEvent.True;
        elseif(predictDisappear == TouchEvent.False)
            falselist.add(evt);
            evt.state = TouchEvent.False;
        end
    end
    
    
end

% 根据疑似报点的情况，执行全局特征判断
% if (list.count>0)
%     if(Classifier.GlobalChange())
%         list.clear();
%     end
% end

% % 确定报点
% for i=1:truelist.size()
%     evt = truelist.at(i);
%     evt.state = TouchEvent.True;
%     
%     %有报点的event本身的label是：
%     checkarea = evt.areas.at(firstReportedAreaID);
%     checkframe = evt.frames.at(evt.areas.at(firstReportedAreaID).frameID);
%     checkindex = find(touchIDs==checkarea.reportedID);
%     checklabel = checkframe.labels.at(checkindex);
%    
%     %同时记录报点距离系统down的延时差:
%     timedelay = crtFrame.time - checkframe.time;
% end

% 处理滑动判断
% for i=1:GD.evts.size()
%     evt = GD.evts.at(i);
%     if(evt.state == TouchEvent.True)
%         [ret, x, y] = Swipe.Parse(evt);
%         if(ret)
%             
%         end
%     end
% end

end