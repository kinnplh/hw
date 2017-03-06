classdef Vector < handle
    properties(SetAccess = protected)
       elemQueue
    end
    
    methods
        function obj = Vector(t)
          obj.elemQueue = Queue(t);
        end
        
        function clear(obj)
            obj.elemQueue = Queue(t);
        end
        
        function push_back(obj, newElem)
           obj.elemQueue.offer(newElem);
        end
        
        function res = at(obj, index)
           res = obj.elemQueue.at(index);
        end
        
        function res = first(obj)
           res = obj.elemQueue.at(1); 
        end
        
        function res = last(obj)
           res = obj.elemQueue.at(obj.elemQueue.size()); 
        end
        
        function res = size(obj)
           res =  obj.elemQueue.size();
        end
        
        function merge(obj, v)
           totalSize = v.size();
           for i = 1: totalSize
               obj.push_back(v.at(i));
           end
        end
    end

end