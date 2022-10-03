function joinedUp = joinby(x,joinBy )
% join cells in cell array (argument 1), connected by 2nd argument
%
% INPUT:
% x - cell array of row / column vectors
% joinBy - object to connect x's cells by
%
% OUTPUT:
% joinedUp - connected vector of cells / numeric values
%
% EXAMPLES:
% joinby(splitby([1,2,3,NaN,4,5,6,7,NaN,8,9,10],NaN),-999)
% joinby(splitby([1,2,3,NaN,4,5,6,7,NaN,8,9,10],NaN),'Hello')
% joinby({[1,2,3],[7,8,9],[15,20,25,30]'},NaN)
% joinby({[1,2,3];[7,8,9];[15,20,25,30]'},Inf)
% joinby({1,2,3,'frog',pi},'FISH')
% joinby({[1,2,3],'frog',pi},'hedgehog')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   joinby.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Jul 31 2015 11:55:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
for i=1:Nx % Loop through cells of cell array
    xi=x{i};
    if isnumeric(xi) || islogical(xi)
        x{i}=num2cell(xi); % convert numeric/logical to cells. This means we can join by non-numeric/logical classes
    elseif ischar(xi)
        x{i}=cellstr(xi);
    end
end

joinedUp=arrayfun(@(i){[x{i},joinBy]},1:(Nx-1)); % Connect cells with 'joinBy' value
joinedUp=[horzcat(joinedUp{:}),x{end}]; % combine row vectors with end bit

try % Try to convert back to numeric
    joinedUp=cell2mat(joinedUp);
catch
    % don't worry about it - leave as cell array
end

if ~rowVector
    joinedUp=reshape(joinedUp,[],1);
end

end
