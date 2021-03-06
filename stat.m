

mainPaths = getfilepaths('edge/');

displacement_distance_ratio_edge = []; % 与down一帧统计   当然 down帧是不能被算上的

for fileId = 1: length(mainPaths)
    tic
    path = mainPaths(fileId)
    savePath = sprintf('./frameVectorsFlooded/frameVectorFlooded%d_temedge.mat', fileId);
    load(savePath);
    savePath = sprintf('./areas/areaVector%d_temedge.mat', fileId);
    load(savePath);
    savePath = sprintf('./touchEvents/touchEventVector%d_temedge.mat', fileId);
    load(savePath);    
    
    
    eventSize = touchEventVector.size();
    for eventID = 1: eventSize
        crtEvent = touchEventVector.at(eventID);
        if crtEvent.firstReportedAreaID == -1 % 没有报点
            continue;
        end
        
        areaStartIndex = find(crtEvent.areaIDs == crtEvent.firstReportedAreaID);
        if crtEvent.lastReportedAreaID == -1
            areaEndIndex = length(crtEvent.areaIDs);
        else
            areaEndIndex = find(crtEvent.areaIDs == crtEvent.lastReportedAreaID);
        end
        downAreaWeightedCenter = areaVector.at(crtEvent.firstReportedAreaID).weightedCenter;
        
        crtDistance = 0;
        for areaIndex = areaStartIndex + 1: areaEndIndex 
            % down 本身显然不会去计算  然而down之后一帧也不会
            % 不过这个计算出来的1   可以作为事件的分割
            crtArea = areaVector.at(crtEvent.areaIDs(areaIndex));
            lastArea = areaVector.at(crtEvent.areaIDs(areaIndex - 1));
            crtDistance = crtDistance + crtArea.weightedCenter.disTo(lastArea.weightedCenter);
            displacement_distance_ratio_edge = [displacement_distance_ratio_edge;...
                crtArea.weightedCenter.disTo(downAreaWeightedCenter) / crtDistance];
        end
        
        
    end
    toc
    
end
