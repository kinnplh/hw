%���Ľ׶ζԵõ��ķ��������в���
%modified by Violynne

truerecord = [];
trueoutput = [];
falserecord = [];
falseoutput = [];
TP = 0;
FP = 0;
TN = 0;
FN = 0;
ret = [];

for fileId = 1: length(mainPaths)

    truePath = sprintf('./predictlists/truelist%d.mat', fileId);
    falsePath = sprintf('./predictlists/falselist%d.mat', fileId);
    
    load(truePath);
    load(falsePath);
    
    for i=1:truelist.size()
        evt = truelist.at(i);

        %�б����event�����label�ǣ�
        checkarea = globalData.areas.at(evt.firstReportedAreaID);
        checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
        checkindex = find(checkframe.touchIDs==checkarea.reportID);
        checklabel = checkframe.labels.at(checkindex);

        %checklabel�Ǿŷ��� ��Ҫת��Ϊ������
        if(strcmp(cell2mat(checklabel),'TOUCHEDGE')||strcmp(cell2mat(checklabel),'TOUCHNEAR')||strcmp(cell2mat(checklabel),'TOUCHMID')||strcmp(cell2mat(checklabel),'SWIPEMID')||strcmp(cell2mat(checklabel),'SWIPEEDGE'))
            TP = TP + 1;
        else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
            FP = FP + 1;
        end

        %ͬʱ��¼�������ϵͳdown����ʱ��:
        timedelay = crtFrame.time - checkframe.time;

        %�洢ÿ��event������Ϣ�Ա�֮�����
        truerecord = [evt.ID,evt.state,checklabel,timedelay];
        trueoutput = [trueoutput;truerecord];
    end

    for i=1:falselist.size()
        evt = falselist.at(i);
        evt.state = TouchEvent.False;

        %�б����event�����label�ǣ�
        checkarea = globalData.areas.at(evt.firstReportedAreaID);
        checkframe = globalData.frames.at(globalData.areas.at(evt.firstReportedAreaID).frameID);
        checkindex = find(checkframe.touchIDs==checkarea.reportID);
        checklabel = checkframe.labels.at(checkindex);

        %checklabel�Ǿŷ��� ��Ҫת��Ϊ������
        if(strcmp(cell2mat(checklabel),'TOUCHEDGE')||strcmp(cell2mat(checklabel),'TOUCHNEAR')||strcmp(cell2mat(checklabel),'TOUCHMID')||strcmp(cell2mat(checklabel),'SWIPEMID')||strcmp(cell2mat(checklabel),'SWIPEEDGE'))
            TN = TN + 1;
        else% GRIPBIG MOVEBIG GRIPFINGER QUARTERGRIP 
            FN = FN + 1;
        end

        %ͬʱ��¼�������ϵͳdown����ʱ��:
        timedelay = crtFrame.time - checkframe.time;

        %�洢ÿ��event������Ϣ�Ա�֮�����
        falserecord = [evt.ID,evt.state,checklabel,timedelay];
        falseoutput = [falseoutput;falserecord];
    end
    
    savePath = sprintf('./predictrecords/trueoutput%d.mat',fileId);
    save(savePath, 'trueoutput');
    savePath = sprintf('./predictrecords/falseoutput%d.mat',fileId);
    save(savePath, 'falseoutput');
        
end

[TP,FP,TN,FN]
eventsum = TP+FP+TN+FN
accuracy = TP/(TP+TN)
callback = FN/(FN+FP)
F1score = 2 / (1 / accuracy + 1 / callback)

%���Ľ׶δ���������õ�����ֵ��trueoutput falseoutput�����ں��ڷ���