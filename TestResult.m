classdef TestResult < handle
    
    % ��Ҫ�����ܹ�����down����һ֡
    properties
       touchEventID;% ʵ���϶�Ӧ��Ҳ�����Լ���ID
       actualReportPos; % �����TouchEvent�е�ÿ��Area�����û�б�������һ���Ƿ���λ��
       areaIDs; % ������Ӧ�ú�touchEvent�е�һ��  �������ں��񲢲���������
       status;
       
       area1ID; % �������¼����жϳɻ����Ļ�   ��¼һ����������area���µ�
       area2ID;
       
       maxCapEver;
       capDiffThreshold;
       
       eiff;
    end
    
    methods
        function obj = TestResult(evtID)
            obj.touchEventID = evtID;
            obj.actualReportPos = Vector('Pos');
            obj.status = [];
            obj.areaIDs = [];
            obj.area1ID = -1;
            obj.area2ID = -1;
            obj.maxCapEver = -1;
            obj.capDiffThreshold = 2000;
            obj.eiff = [];
        end
        
    end
    
end