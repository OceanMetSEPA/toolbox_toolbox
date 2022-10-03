function varargout=varSize(x,sf)
% Find size of variable

if nargin<2
    sf=[];
end

% Get name of input variable:
varname=inputname(1);

% Use whos() function to get variable size. But it needs to be run in
% caller workspace rather than within a function (?)
ws='caller';
% ws='base'; % doesn't work - variable might not be defined there
cmd=sprintf('whos(''%s'')',varname);
varinfo=evalin(ws,cmd);
%structSizeGB=varinfo.bytes/1e9;

op=varinfo.bytes;

if ~isempty(sf)
    scaleOptions={'KB','MB','GB'};
    k=contains(scaleOptions,sf,'ig',1);
    if sum(k)==0
        error('unrecognised scale ''%s''',sf)
    elseif sum(k)>1
        error('ambiguous scale ''%s''',sf)
    else
        k=find(k);
        scaleOption=scaleOptions{k};
        op=op/power(10,k*3);
    end
else 
    scaleOption=' bytes';
end
if nargout==0
    fprintf('%s size = %f%s\n',varname,op,scaleOption)
elseif nargout==1
    varargout{1}=op;
else
    error('too many outputs')
end