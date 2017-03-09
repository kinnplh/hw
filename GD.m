classdef GD < handle
    %UNTITLED7 此处显示有关此类的摘要
    %   此处显示详细说明
    properties
        % 现在只是把三个数据结构简单地放在一起
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

