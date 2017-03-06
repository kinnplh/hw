function ret=getfilepaths(maindir)

maindir = 'F:\NewEx\test\';
subdir  = dir( maindir );

% data/ name parse outputx
filepaths{:}=[];

len = 0;

kk = length(subdir);
for i = 1 : kk
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        ~subdir( i ).isdir)
        subdir( i ).name
        
        if(strfind(subdir( i ).name,'output')>0)
           datpath = [maindir, subdir( i ).name];
           len = len+1;
           filepaths{len}=datpath;
        end
        
        continue;
    end
%     subdirpath = [maindir, subdir( i ).name, '\'];
%     dat = dir( subdirpath ); 
% 
%     for j = 1 : length( dat )
%         name = dat(j).name;
%         if(strfind(name,'output')>0)
%            datpath = [subdirpath, name];
%            len = len+1;
%            filepaths{len}=datpath;
%         end
%     end


end

ret=filepaths;