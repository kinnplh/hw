function OnFrameReceived(frame)
% �˴���ʾ�йش˺�����ժҪ

% ����ÿ֡�������
frame.parse();
DG.BuildTouchevent(frame);

% ����ÿ���������������ô����γɵ����� ����

truelist = Vector('TouchEvent');

for i=1:GD.evts.size()
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.Uncertain) % && evt.areaIDs.size() == evt.firstReportedAreaID)
        if(Classifier.ClassifyEmerge(evt) == TouchEvent.True)
            truelist.add(evt);    
        end
    end
end

% ����ÿ���������������ô�����ʧ������ ����
for i=1:GD.evts.size(),
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.Uncertain) % && evt.areaIDs.size() == evt.firstReportedAreaID)
        if(Classifier.ClassifyDisappear(evt) == TouchEvent.True)
            truelist.add(evt);    
        end
    end
end

% �������Ʊ���������ִ��ȫ�������ж�
if (list.count>0)
    if(Classifier.GlobalChange())
        list.clear();
    end
end

% ȷ������
for i=1:list.size()
    evt = list.at(i);
    evt.state = TouchEvent.True;
end

% ���������ж�
for i=1:GD.evts.size(),
    evt = GD.evts.at(i);
    if(evt.state == TouchEvent.True)
        [ret, x, y] = Swipe.Parse(evt);
        if(ret)
            
        end
    end
end

end