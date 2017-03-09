function OnFrameReceived(frame, gd, cls)
    % 注意要处理数据中的插入帧
    % 需要对所有的Area进行处理
    
    for i = 1: length(frame.areaIDs)
        cls.newAreaReceived(gd.areas.at(frame.areaIDs(i)), gd);
    end
    
    
end