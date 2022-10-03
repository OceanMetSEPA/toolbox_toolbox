function [ xSplit,ind ] = splitby(x,splitBy,varargin)
% Split input into parts, separated by 'splitBy'
%
% Splitting strings, cells and numeric arrays all require separate methods.
% This function uses the appropriate method depending on input class.
%
% INPUT:
% x - object to split
% splitBy - value to split by / indices to split at
%
% Optional Inputs:
% type [] - specify whether to split by value or index. If  empty, the
%           function will try to guess based on class / size of splitBy input
% includeSplitValue [0] - include value used to split input.
%           0 - don't include split value
%          -1 - split BEFORE value (i.e. split value occurs at start of
%               subsequent split sections)
%           1 - split AFTER value (split value occurs at end of split
%               sections
% cellOutput [false] - return input as cell even if splitBy value not found
%
% OUTPUT:
% xSplit - cell array, where each cell contains sections of original object
%          separated by 'splitBy'
% splitByIndices - indices where splitBy found in 'x'
%
% EXAMPLES:
% splitby(fileread(which('splitby')),' ')
% splitby([1,2,3,NaN,4,5,6,7,NaN,8,9,10],NaN)
% splitby(splitby('the quick brown fox jumps over the lazy dog',' '),'the')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   splitby.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Jul 31 2015 11:57:56  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help splitby
    return
end

%% Check options
options=struct;
options.type=[];
options.includeSplitValue=0;
options.cellOutput=false; % return unsplit arrays as cells
options=checkArguments(options,varargin);
includeSplitValue=options.includeSplitValue;

% Are we splitting by value or index?
if isempty(options.type) % not specified in options- try to work it out
    if isnumeric(splitBy) && length(splitBy)>1 % Multiple numeric values?
        type='index';
    elseif islogical(splitBy) && length(splitBy)==length(x) % logical values?
        type='index';
    else % scaler numeric, char, cell etc
        type='value'; % Default
    end
else
    validOptions={'value','index'};
    type=char(stringFinder(validOptions,options.type));
    if isempty(type)
        disp(validOptions)
        error('Invalid option ''%s''; please select one of the above',options.type)
    end
end

% Make sure input is 1d:
if ~isvector(x)
    error('Function requires vector input (size [1,N] or [N,1])')
end
rowVector = size(x,1)==1; % true for row, false for column
if rowVector
    if size(splitBy,1)>1
        %        fprintf('Transposing splitBy argument to row vector\n');
        splitBy=splitBy';
    end
else
    if size(splitBy,2)>1
        %       fprintf('Transposing splitBy argument to column vector\n');
        splitBy=splitBy';
    end
end
Nx=length(x);

%% CASE : SPLIT BY VALUE
switch type
    case 'value'
        %        fprintf('Spitting by value...\n')
        % Find indices where split occurs:
        if ischar(x)
            ind=regexp(x,splitBy);
            xSplit=regexp(x,splitBy,'split');
            return
        elseif iscell(x)
            ind=find(cellfun(@(xi)isequal(xi,splitBy),x));
        else
            if isnan(splitBy) % Need special case for NaNs, since NaN==NaN is false
                ind=find(isnan(x));
            else
                try
                    ind=find(x==splitBy);
                catch
                    warning('Incompatable input values')
                    ind=[];
                end
            end
        end
    case 'index'
        %        fprintf('Spliting by index...\n')
        ind=splitBy;
        ind(ind>Nx)=Nx+1;
        if islogical(ind)
            ind=find(ind);
        end
    otherwise
        error('INVALID TYPE')
end
ind=unique(ind);
Nind=length(ind);


if Nind>0 % Did we find any splits?
    if rowVector
        ind2Split=[0,ind,Nx+1];
    else
        ind2Split=[0;ind;Nx+1];
    end
    Nop=Nind+1;
    xSplit=cell(Nop,1); % store splits here
    for i=1:Nop;
        switch includeSplitValue % where should we split ?
            case 0 % AT split index (don't include in split value)
                ithSplitIndices=ind2Split(i)+1:ind2Split(i+1)-1;
            case 1 % AFTER split index (include at end of split sections)
                ithSplitIndices=ind2Split(i)+1:min([ind2Split(i+1),Nx]);
            case -1 % BEFORE split index (include at start of split sections)
                ithSplitIndices=max([ind2Split(i),1]):ind2Split(i+1)-1;
            otherwise
                error('Invalid ''includeSplitValue'' argument (should be -1,0 or 1)');
        end
        xSplit{i}=x(ithSplitIndices); % populate cell array
    end
    xSplit=xSplit(~cellfun(@isempty,xSplit)); % remove empty splits
else
    xSplit=x; % return original input if no matches found
    if options.cellOutput
        xSplit={xSplit};
    end
    %    disp(splitBy)
    %    warning('No occurences of split value found\n')
end

if rowVector % If input was row, make output row too
    xSplit=xSplit';
end
end
