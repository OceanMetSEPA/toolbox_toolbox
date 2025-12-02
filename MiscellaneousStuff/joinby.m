function joinedUp = joinby(x,joinBy )
% join cells in cell array (argument 1), connected by 2nd argument

if nargin<2
    help joinby
    return
end

if ~iscell(x)
    error('Function requires cell array')
end
if ~isvector(x)
    error('Function requires a vector')
end

rowVector=size(x,1)==1;
x=cellfun(@(xi){xi(:)'},x);
if ~rowVector
    x=x';
end

Nx=length(x);
for i=1:Nx
    xi=x{i};
    if isnumeric(xi) || islogical(xi)
        x{i}=num2cell(xi);
    elseif ischar(xi)
        x{i}=cellstr(xi);
    end
end

% --- FIX: handle single-element case ------------------------------------
if Nx == 1
    joinedUp = x{1};  % nothing to join
    try
        joinedUp = cell2mat(joinedUp);
    catch
    end
    if ~rowVector
        joinedUp = joinedUp(:);
    end
    return;
end
% ------------------------------------------------------------------------

joinedUp=arrayfun(@(i){[x{i},joinBy]},1:(Nx-1));
joinedUp=[horzcat(joinedUp{:}),x{end}];

try
    joinedUp=cell2mat(joinedUp);
catch
end

if ~rowVector
    joinedUp=reshape(joinedUp,[],1);
end

end
