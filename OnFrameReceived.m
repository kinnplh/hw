function OnFrameReceived(frame, globalData)
    % ע��Ҫ���������еĲ���֡
    % ��Ҫ�����е�Area���д���
    
    for i = length(frame.areaIDs)
        Classifier.newAreaReceived(globalData.areas.at(frame.areaIDs(i)), globalData);
    end
    
    
end