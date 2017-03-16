classdef Pos
   properties
      x
      y
      minillum
   end
   
   methods
       function obj = Pos(x, y)
          obj.x = x;
          obj.y = y;
       end
       
       function res = add(obj, p)
          res = Pos(0, 0);
          res.x = obj.x + p.x;
          res.y = obj.y + p.y;
       end
       
       function res = sub(obj, p)
          res = Pos(0, 0);
          res.x = obj.x - p.x;
          res.y = obj.y - p.y;
       end
       
       function res = div(obj, p)
          res = Pos(0, 0);
          res.x = obj.x / p;
          res.y = obj.y / p;
       end
       
       function res = mul(obj, p)
          res = Pos(0, 0);
          res.x = obj.x * p;
          res.y = obj.y * p;
       end
       
       function res = toUp(obj)
          res = Pos(0, 0);
          res.x = obj.x;
          res.y = obj.y - 1;
       end
       
       function res = toDown(obj)
          res = Pos(0, 0);
          res.x = obj.x;
          res.y = obj.y + 1;
       end
       
       function res = toLeft(obj)
          res = Pos(0, 0);
          res.x = obj.x - 1;
          res.y = obj.y;
       end
       
       function res = toRight(obj)
          res = Pos(0, 0);
          res.x = obj.x + 1;
          res.y = obj.y;
       end
       
       function res = disTo(obj, p)
           res = sqrt((obj.x - p.x)^2 + (obj.y - p.y)^2);
       end
       
       function res = IsDiff(obj, p)
           if(obj.x == p.x && obj.y == p.y)
               res = false;
           else
               res = true;
           end
       end
       function res = round(obj)
           res = Pos(round(obj.x), round(obj.y));
       end
       function res = isEqual(obj, p)
           res = (obj.x == p.x && obj.y == p.y);
       end
   end
end