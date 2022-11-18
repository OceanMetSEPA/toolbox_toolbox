function op=camelCase(ip)
% Convert string (or struct fieldnames) to camelCase
% 1) first chacter lower case
% 2) characters after ' ' or '_' capitalised
% 
% INPUT:
% ip - char/cellstr or struct 
%
% OUTPUT:
% op - char/cellstr or struct converted to camelCase
%
% EXAMPLES:
% camelCase('fish face')
% camelCase(struct('X',1:10,'Y_Variable',pi))
%

if nargin==0
    help camelCase
    return
end

if isstruct(ip) % struct input - convert fieldnames to camelCase
    fn=fieldnames(ip);
    fn=camelCase(fn);
    op=renameStructFields(ip,fn);
    return
end

% We've dealt with struct above so if we're here we've got a char/cellstr
% (or should have - no tests for numeric inputs etc!)

str=cellstr(ip);
Ns=length(str);
if Ns>1 % Multiple strings to process? 
    op=cellfun(@camelCase,str,'unif',0); % Recursive call to process them
    return
end
% Now we should have a single cellstr. Convert back to char:
str=char(str);
% First character should be lower case:
str(1)=lower(str(1));
% Find character markers:
seps=find(str==' ' | str=='_');
N=length(seps);
for i=1:N
    k=seps(i);
    try % to make next character UPPER CASE
        str(k+1)=upper(str(k+1));
    catch
        % oh well
    end
end
% Remove markers:
str(seps)=[];
% And we're done! 
op=str;