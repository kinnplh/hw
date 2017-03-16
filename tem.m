singleAreaStartTime = [];
multipleEventNum = 0;
for i = 1: touchEventVector.size()
crtEvent = touchEventVector.at(i);
if crtEvent.firstReportedAreaID > -1 && length(crtEvent.areaIDs) == 1
singleAreaStartTime = [singleAreaStartTime, frameVector.at(areaVector.at(crtEvent.areaIDs(1)).frameID).time];
end
if crtEvent.multipleFrameNum > 0
    multipleEventNum = multipleEventNum + 1;
end
end
singleAreaStartTime
multipleEventNum