classdef Classifier
    %UNTITLED4 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
    end
    
    methods (Static)
        
    function ret = IsValidShape(area, ei, term)
        ret = 0;
        if(strcmp(term,'fromedge'))
            ret = area.size <= 25 && area.xSpan/area.ySpan>=0.5;
        elseif(strcmp(term, 'onedge'))
            if(area.xSpan == 0 || area.ySpan == 0)
                ret = 0;
            else
                ret = (area.ySpan/area.xSpan <= 3 && ei.edgelen < 10);
            end 
        elseif(strcmp(term, 'middle'))
            if(area.xSpan == 0 || area.ySpan == 0)
                ret = 0;
            else
                ret = area.ySpan/area.xSpan <= 3 && ei.edgelen < 10;
            end
        end
    end
        
        function ret = ClassifyEmerge(evt)
            
            Uncertain = 0;
            True = 1;
            False = 2;
            %���߳��ֵĳ�ʼ֡�����Ե��Ϣ
            birthArea = areas(evt.areaIDs(1));
            Bei = EdgeInfo.FromArea(birthArea);
            %ϵͳ��down֡�����Ե��Ϣ
            downArea = areas.at(evt.firstReportedAreaID);
            Dei = EdgeInfo.FromArea(downArea);
            %�����߳��ֵĳ�ʼ֡��ϵͳ��down֡�����ĺ�����
            timelength = frames.at(downArea.frameID).time - frames.at(birthArea.frameID).time;
            
            if(Bei.onedge)%���߳����ڱ�Ե��
                switch(Bei.edge)
                    case top,bottom%���߳��������±�Ե
                       if(Classifier.IsValidShape(downArea,Dei,'onedge'))%����ʱ��ͨ���Ǳ�Ե�ϵ���Ч��״
                           %TOUCHEDGE & SWIPEEDGE ��Ե��� & ��Ե����
                           ret = True;
                       else
                           %QUARTERGRIP �������ʱ�Ĳ���ճ���
                           ret = False;
                       end
                       
                    case left,right%���߳��������ұ�Ե
                       if(~Bei.fromedge)%���߲��Ǵӱ�Ե����������
                           if(Classifier.IsValidShape(birthArea,Bei,'fromedge'))%����ʱ��ͨ���Ǳ�Ե�ϵ���Ч��״
                               %TOUCHNEAR & SWIPENEAR �ӽ���Ե�ĵ�� & ����
                               ret = True;
                           else
                               %MOVEBIG & STRANGE ���Ե��������������� & ���Ե����������������
                               ret = False;
                           end
                       else%���ߴӱ�Ե��������
                           if(Classifier.IsValidShape(birthArea,Bei,'fromedge'))%����ʱ��ͨ���Ǳ�Ե�ϵ���Ч��״
                                 if(timelength>70)%���߳��ֵ�ϵͳ��down��ʱ�䳬��70ms
                                     %GRIPFINGER �ճ���ָ
                                     ret = False;
                                 elseif(downArea.average>1400)%����ʱ��ͨ�����ͼ��ƽ��ֵ����1400
                                     %TOUCHEDGE & SWIPEEDGE ��Ե��� & ����
                                     ret = True;
                                 else
                                     %TOUCHEDGE & SWIPEEDGE & GRIPFINGER
                                     %�������ֵ����� & ���� �� ���ճ�
                                     ret = Uncertain;
                                 end
                           else%����ʱ��ͨ���Ǳ�Ե�ϵ���Ч��״
                               %GRIPBIG ���մ����
                               ret = False;
                           end
                       end
                       
                    %case lt,ld,rt,rd
                        %���߳������ĸ��߽�
                        
                    case mid%���߳��ֲ��ڱ�Ե
                       if(~Classifier.IsValidShape(downArea,Dei,'middle'))
                           %MOVEBIG & STRANGE �����Ե��������������� & �����Ե��������������
                           ret = False;
                       else
                           %TOUCHMID & SWIPEEDGE Զ����Ļ�ĵ�� & ����
                           ret = True;
                       end
                end
            end
          
        end
        
        function ret = ClassifyDisappear(evt,crtFrame)
           find = 0;
           for i = 1: length(crtFrame.areaIDs)
               checkArea = obj.areas.at(crtFrame.areaIDs(i));
               if(checkArea.touchEventID == evt.ID)
                   curArea = checkArea;
                   find = 1;
               end
           end
           
           if(find == 0)
               ret = False;%ʵ���ϻ���Uncertain
           else
               %��ȡ��ǰ֡�ĵ�ǰ���ǵ�event�ĵ�ǰarea
               timedis = frames.at(curArea.frameID).time - frames.at(downArea.frameID).time;
               capacitydis = abs(curArea.capacitysum - downArea.capacitysum);
               disappearRatio =  (capacitydis+1)/(timedis+1);

               if(timedis >= 30 && disappearRatio > 50)
                   ret = True;
               else
                   ret = False;%ʵ���ϻ���Uncertain
               end
           end
           
        end
     
%         function GlobalChange()
%             
%         end
%         
%         function IsSwipe()
%             
%         end
    
    end
end
