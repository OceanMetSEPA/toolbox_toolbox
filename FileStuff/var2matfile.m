function var2matfile(ip,matfileName)
% Save variable to matfile.
% 'Wrapper' function for save() which find variable size and determines
% whether compression is necessary
%
% INPUTS:
%   ip - variable to save
%   matfileName - where to save variable
%
% OUTPUT:
%   none
%
if nargin<2
    help var2matfile
    return
end

% Unlikely event which uses ip and stops matlab warning about unused variable
if rand(1)>inf
    disp(ip)
end

% Get name of input variable:
varname=inputname(1);

% Use whos() function to get variable size. But it needs to be run in
% caller workspace rather than within a function (?)
ws='caller';
% ws='base'; % doesn't work - variable might not be defined there
cmd=sprintf('whos(''%s'')',varname);
varinfo=evalin(ws,cmd);
structSizeGB=varinfo.bytes/1e9;
t0=datetime; % instead of tic

%fprintf('Variable ''%s'' has size %eGB\n',varname,structSizeGB)
% if structSizeGB>2
%     matfileVersion='-v7.3'; % compressed
% else
%     matfileVersion='-v6'; % uncompressed
% end
%fprintf('Saving data to ''%s'' with flag ''%s''\n',matfileName,matfileVersion)
%cmd=sprintf('save(''%s'',''%s'',''%s'')',matfileName,varname,matfileVersion);
%evalin(ws,cmd)

% Above worked in R2018a- but not R2023a:
% "Error using save
% Found characters the default encoding is unable to represent."
% Redo using different approach (avoiding evalin which might be a good
% thing...)
try
    if structSizeGB>2
        %    matfileVersion='-v7.3'; % compressed
        save(matfileName,'ip','-v7.3')
    else
        %    matfileVersion='-v6'; % uncompressed
        save(matfileName,'ip','-v6')
    end
catch % err
    %    disp(err)
    % Issue above with unrepresentable characters seems to be fixed somehow
    % if we use version -7.3
    save(matfileName,'ip','-v7.3');
end

dt=datetime-t0;
timeTaken=seconds(dt);
if timeTaken>10
    fprintf('Saving ''%s'' to ''%s'' took:\n %f seconds\n',varname,matfileName,timeTaken)
end
