singleAreaStartTime = [];
for i = 1: touchEventVector.size()
crtEvent = touchEventVector.at(i);
if crtEvent.firstReportedAreaID > -1 && length(crtEvent.areaIDs) == 1
singleAreaStartTime = [singleAreaStartTime, frameVector.at(areaVector.at(crtEvent.areaIDs(1)).frameID).time];
end
end