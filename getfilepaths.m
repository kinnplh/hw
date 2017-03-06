function ret=getfilepaths(maindir)

% maindir = 'F:\Experiment\data\';
subdir  = dir( maindir );

% data/ name parse outputx
filepaths{:}=[];

len = 0;

kk = length(subdir);
for i = 1 : kk
    if( isequal( subdir( i ).name, '.' )||...
        isequal( subdir( i ).name, '..')||...
        isequal( subdir( i ).name, '.DS_Store')||...
        ~subdir( i ).isdir)               % ??????????????????
        subdir( i ).name
        continue;
    end
    subdirpath = [maindir, subdir( i ).name, '/'];
    dat = dir( subdirpath );               % ??????????????????dat??????

    for j = 1 : length( dat )
        name = dat(j).name;
        if(strfind(name,'output')>0)
           datpath = [subdirpath, name];
           
%            fullfile( maindir, subdir( i ).name, dat( j ).name);
           len = len+1;
           filepaths{len}=datpath;
        end
        % fid = fopen( datpath );
        % ?????????????????????????? %
    end
end

ret=filepaths;