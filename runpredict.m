for fileId = 1: length(mainPaths)
    
    truelist = Vector('TouchEvent');
    falselist = Vector('TouchEvent');
    
    framePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d.mat', fileId);
    areaPath = sprintf('./areas/areaVector%d.mat', fileId);
    eventPath = sprintf('./touchEvents/touchEventVector%d.mat', fileId);
    
load(framePath);
load(eventPath);
load(areaPath);
    
    globalData = GD(frameVector, touchEventVector, areaVector);

    %有一种特殊情况，down帧就是该event的最后一帧，而如果在down帧判定出来是Uncertain，evt就会保持这个状态
    %针对这种特殊情况，应该将之统一赋为False

    while globalData.hasNextFrame()
        crtFrame = globalData.getNextFrame();
        OnFrameReceived(globalData,crtFrame);
    end
    
    for i = 1:globalData.evts.size()
        evt = globalData.evts.at(i);
        if(evt.state == TouchEvent.True)
            truelist.push_back(evt);
        elseif(evt.state == TouchEvent.False || evt.state == TouchEvent.Uncertain)
            falselist.push_back(evt);
        end
    end
    
    savePath = sprintf('./predictlists/truelist%d.mat',fileId);
    save(savePath, 'truelist');
    savePath = sprintf('./predictlists/falselist%d.mat',fileId);
    save(savePath, 'falselist');
     
end    