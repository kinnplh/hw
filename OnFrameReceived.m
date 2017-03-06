function OnFrameReceived(frame, globalData)
    % 注意要处理数据中的插入帧
    % 需要对所有的Area进行处理
    
    for i = length(frame.areaIDs)
        Classifier.newAreaReceived(globalData.areas.at(frame.areaIDs(i)), globalData);
    end
    
    
end