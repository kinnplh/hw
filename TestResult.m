classdef TestResult < handle
    
    % ��Ҫ�����ܹ�����down����һ֡
    properties
       touchEventID;% ʵ���϶�Ӧ��Ҳ�����Լ���ID
       actualReportPos; % �����TouchEvent�е�ÿ��Area�����û�б�������һ���Ƿ���λ��
       areaIDs; % ������Ӧ�ú�touchEvent�е�һ��  �������ں��񲢲���������
       status;
    end
    
    methods
        function obj = TestResult(evtID)
            obj.touchEventID = evtID;
            obj.actualReportPos = Vector('Pos');
            obj.status = [];
            obj.areaIDs = [];
            
        end
        
    end
    
end