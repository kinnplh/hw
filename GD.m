classdef GD < handle
    %UNTITLED7 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    properties
        % ����ֻ�ǰ��������ݽṹ�򵥵ط���һ��
        frames;
        evts;
        areas;
    end
    
    methods
        function obj = GD(frameVector, touchEventVector, areaVector)
            obj.frames = frameVector;
            obj.evts = touchEventVector;
            obj.areas = areaVector;
            
        end
        
    end
    
end

