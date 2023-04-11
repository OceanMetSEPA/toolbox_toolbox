function varargout=combos(varargin)
% Wrapper for Gautam Vallabha's handy 'combinations' function
% which bundles the cell array returned by the function into a struct.
%
% INPUTS:
%   variables that we want to find combinations of
%
% OUTPUT:
%   struct with all combinations
%
% Note: if inputs are named variables, then their names are used as the struct
% fieldnames. If they are arrays, then they are labelled input1, input2 etc
%
% EXAMPLES:
% a=[1,2];
% b={'c','d'};
% combos(a,b) % struct with fields 'a' and 'b'
%     'a'    'b'
%     [1]    'c'
%     [2]    'c'
%     [1]    'd'
%     [2]    'd'
% combos([1,2],{'c','d'}) % struct with fields 'input1' and 'input2'
%
% For Ni inputs, combinations returns an array of size [Nc,Ni]
% where Nc is the product of the length each input vector i.e.
% prod(cellfun(@numel,varargin))

if nargin==0
    help combos
    return
end

c=combinations(varargin{:}); % Need {:}!

op=struct;
for i=1:nargin
    argi=varargin{i};
    iname=inputname(i);
    if isempty(iname)
        iname=sprintf('input%d',i);
    end
    % Extract combination value of i'th input:
    vals=c(:,i);
    % If i'th input wasn't a cell, try to convert it back to its original class
    if ~iscell(argi)
        % combinations function returns cells if any input is a cell;
        % otherwise as doubles by default. Convert cell if applicable:
        if iscell(vals)
            vals=cell2mat(vals);
        end
        % and now back to original class:
        vals=cast(vals,class(argi));
    end
    if ismember(iname,fieldnames(op))
        iname=sprintf('%s_%d',iname,i);
    end
    % Pop into our struct:
    op.(iname)=vals;
end

switch nargout
    case 0
        dispStruct(op)
    case 1
        varargout{1}=op;
    otherwise
        error('too many outputs')
end



