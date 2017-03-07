truelist = Vector('TouchEvent');
falselist = Vector('TouchEvent');
TP = 0;
FP = 0;
TN = 0;
FN = 0;
ret = [];
evtfileinfo = [];
for fileId = 1: length(mainPaths)
        
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
        
        fileinfo = [evt.ID,fileId];
        evtfileinfo = [evtfileinfo;fileinfo];
        
        if(evt.state == TouchEvent.True)
            truelist.push_back(evt);
            evt.state = TouchEvent.True;
            checkarea = globalData.areas.at(evt.firstReportedAreaID);
            checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
        
            if(isempty(checkframe.touchIDs))
                FP = FP + 1;
            else
                checkindex = find(checkframe.touchIDs==checkarea.reportID);
                checklabel = checkframe.labels.at(checkindex);
                if(strcmp(cell2mat(checklabel),'TOUCHEDGE')||strcmp(cell2mat(checklabel),'TOUCHNEAR')||strcmp(cell2mat(checklabel),'TOUCHMID')||strcmp(cell2mat(checklabel),'SWIPEMID')||strcmp(cell2mat(checklabel),'SWIPEEDGE'))
                    TP = TP + 1;
                else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
                    FP = FP + 1;
                end
            end
            
        elseif(evt.state == TouchEvent.False || evt.state == TouchEvent.Uncertain)
            falselist.push_back(evt);
            evt.state = TouchEvent.False;
            checkarea = globalData.areas.at(evt.firstReportedAreaID);
            checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
            checkindex = find(checkframe.touchIDs==checkarea.reportID);
            checklabel = checkframe.labels.at(checkindex);

            %checklabel是九分类 需要转换为二分类
            if(strcmp(cell2mat(checklabel),'TOUCHEDGE')||strcmp(cell2mat(checklabel),'TOUCHNEAR')||strcmp(cell2mat(checklabel),'TOUCHMID')||strcmp(cell2mat(checklabel),'SWIPEMID')||strcmp(cell2mat(checklabel),'SWIPEEDGE'))
                TN = TN + 1;
            else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
                FN = FN + 1;
            end
        end
    end
    
%     savePath = sprintf('./predictlists/truelist%d.mat',fileId);
%     save(savePath, 'truelist');
%     savePath = sprintf('./predictlists/falselist%d.mat',fileId);
%     save(savePath, 'falselist');
     
end

[TP,FP,TN,FN]
eventsum = TP+FP+TN+FN
accuracy = TP/(TP+TN)
callback = FN/(FN+FP)
F1score = 2 / (1 / accuracy + 1 / callback)

save evtfileinfo.mat evtfileinfo