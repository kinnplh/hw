function OnFrameReceived(frame)
% 此处显示有关此函数的摘要

% 处理每帧基本情况
frame.parse();
DG.BuildTouchevent(frame);

% 处理每个报点的情况，利用触点形成的特征 ？？

truelist = Vector('TouchEvent');

for i=1:GD.evts.size()
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.Uncertain) % && evt.areaIDs.size() == evt.firstReportedAreaID)
        if(Classifier.ClassifyEmerge(evt) == TouchEvent.True)
            truelist.add(evt);    
        end
    end
end

% 处理每个报点的情况，利用触点消失的特征 ？？
for i=1:GD.evts.size(),
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.Uncertain) % && evt.areaIDs.size() == evt.firstReportedAreaID)
        if(Classifier.ClassifyDisappear(evt) == TouchEvent.True)
            truelist.add(evt);    
        end
    end
end

% 根据疑似报点的情况，执行全局特征判断
if (list.count>0)
    if(Classifier.GlobalChange())
        list.clear();
    end
end

% 确定报点
for i=1:list.size()
    evt = list.at(i);
    evt.state = TouchEvent.True;
end

% 处理滑动判断
for i=1:GD.evts.size(),
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.True)
        [ret, x, y] = Swipe.Parse(evt);
        if(ret)
            
        end
    end
end

end