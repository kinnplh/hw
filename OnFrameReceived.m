function OnFrameReceived(frame, gd, cls)
    % ע��Ҫ���������еĲ���֡
    % ��Ҫ�����е�Area���д���
    
    for i = 1: length(frame.areaIDs)
        cls.newAreaReceived(gd.areas.at(frame.areaIDs(i)), gd);
    end
    
    
end