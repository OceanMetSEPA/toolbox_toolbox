function varargout=varSize(x)
% Find size of variable
%
% INPUT:
% x - variable we want to find the size of
% 
% OUTPUT: 
% size of variable in bytes
%
% Get name of input variable:
varname=inputname(1);

% Unlikely event which removes warning due to 'unused' x (though it is of
% course!)
if rand(1)>inf
    disp(x)
end

% Use whos() function to get variable size. But it needs to be run in
% caller workspace rather than within a function (?)
ws='caller';
% ws='base'; % doesn't work - variable might not be defined there
cmd=sprintf('whos(''%s'')',varname);
varinfo=evalin(ws,cmd);

op=varinfo.bytes;

if nargout==0
    fprintf('%s size = %s\n',varname,sizeString(op))
elseif nargout==1
    varargout{1}=op;
else
    error('too many outputs')
end
