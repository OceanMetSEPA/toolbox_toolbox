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
ttic=now;

fprintf('Variable ''%s'' has size %eGB\n',varname,structSizeGB)
if structSizeGB>2
    matfileVersion='-v7.3'; % compressed
else
    matfileVersion='-v6'; % uncompressed
end
fprintf('Saving data to ''%s'' with flag ''%s''\n',matfileName,matfileVersion)
% Can't do this:
%save(matfileName,varname,matfileVersion)
% because variable called varname not found. 
% Maybe we could reassign it within this function? Or evaluate in caller
% workspace
cmd=sprintf('save(''%s'',''%s'',''%s'')',matfileName,varname,matfileVersion);
evalin(ws,cmd)
timeTaken=(now-ttic)*(24*60*60);
fprintf('Saving took %f seconds\n',timeTaken)

