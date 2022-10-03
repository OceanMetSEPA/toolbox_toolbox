function [ news ] = structFilter( s,items2Keep,filterType )
% Pass this function a struct and some conditions, and it'll return a
% cropped struct where the conditions are fulfilled.
%
% The function can filter either:
% 1) the fields
% 2) the values of the fields
%
% When filtering fields, all false members of the filter will be removed.
%
% When filtering values, all false rows/columns of the array will be removed.
% If the field is a multidimentional matrix, each dimension of the matrix with
% length = length(keep) will be filtered.
%
% INPUT:
%  s          -    struct to filter
%  items2Keep -    This can be an array of logical values whose length matches:
%                    Either:
%                     1) the number of fields
%                     2) one of the dimensions of the field values
%                   Alternatively, it can be a char / cell array of strings
%                   in which case matching fields will be retained.
%  filterType -    'fields' or 'values'. Determines which parameter to filter. If this
%                  argument is omited, the function will attempt to determine which option
%                  to perform based on the size of the filter, k.
%                  In the event of ambiguity, an error will be thrown.
%
% OUTPUT:
%   s - struct whose fields have been filtered
%
%  For matrices of N dimensions, the first dimension whose size matches the
%  length of 'items2Keep' will be filtered.
%
% EXAMPLES:
% s=struct('A','fish','b',1:5,'x',meshgrid(1:5),'p',reshape(1:30,6,5),'q',false(6,7))
% structFilter(s,[1,1,0,0,1],'val')
%ans =
%    A: 'fish'   % unfiltered
%    b: [1 2 5]  % 3rd,4th values removed
%    x: [3x5 double] % 3rd,4th rows removed
%    p: [6x3 double] % 3rd,4th columns removed
%    q: [6x7 logical] % unfiltered
%
% structFilter(s,{'A','p'}) % keep 2 specified fields
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   structFilter.m  $
% $Revision:   1.3  $
% $Author:   ted.schlicke  $
% $Date:   Jul 04 2017 10:07:42  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help structFilter
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Struct stuff:
fieldNames=fieldnames(s);
numberOfFieldNames=length(fieldNames);
fieldSizes=unique(cell2mat(struct2cell(structfun(@size,s,'Unif',0))')); % Dimensions of fields

% Filter stuff:
if ischar(items2Keep) || iscell(items2Keep) % Assume we're specifying fieldnames
    items2Keep=stringFinder(fieldNames,items2Keep,'type','or','output','bool');
    if ~exist('filterType','var')
        filterType='fields';
    end
elseif isnumeric(items2Keep)
    items2Keep=logical(items2Keep);
end
if ~islogical(items2Keep)
    error('Argument ''items2Keep'' should be array of logical values')
end
numberOfFilterValues=length(items2Keep);

% What to filter:
validFilterTypes={'fields','values'};
fieldSizeMatch=numberOfFilterValues==numberOfFieldNames;
valueSizeMatch=ismember(numberOfFilterValues,fieldSizes);
if ~exist('filterType','var')
    if  fieldSizeMatch && ~valueSizeMatch
        filterType='fields';
    elseif ~fieldSizeMatch && valueSizeMatch
        filterType='values';
    else
        if fieldSizeMatch && valueSizeMatch % ambiguity!
            errorString=sprintf('Filter size (%d) matches both number of fieldnames and at least one field dimensions;\nPlease specify ''filterType'' to remove ambiguity',numberOfFilterValues);
        else
            errorString=sprintf('Filter size (%d) doesn''t match number of fields or field dimensions',numberOfFilterValues);
        end
        fprintf('Number of fields = %d\n',numberOfFieldNames)
        fprintf('Unique Field dimensions = \n')
        disp(fieldSizes')
        error(errorString)
    end
elseif ~ischar(filterType)
    disp(validFilterTypes)
    error('Argument 3 should be one of the above chars')
else
    filterType=char(stringFinder(validFilterTypes,filterType));
    if isempty(filterType)
        disp(validFilterTypes)
        error('Argument 3 should be one of the above chars')
    end
end

%fprintf('Filtering ''%s''\n',filterType)

news=s; % new struct
switch filterType
    case 'fields'
        if ~fieldSizeMatch
            error('Mismatch between size of logical array and number of fields')
        end
        fields2Remove=fieldNames(~items2Keep);
        news=rmfield(s,fields2Remove);
    case 'values'
        for i=1:numberOfFieldNames % For each field
            fnc=fieldNames{i}; % field name
            field=news.(fnc); % field data
            sf=size(field);   % size of data
            mi=find(numberOfFilterValues==sf); % which dimensions of data match length of conditions?
            if ~isempty(mi) % Did any match?
                % If so, generate a string expression for filtering matrix:
                % 1) non matching dimensions - string = ':' i.e. return all values
                % 2) matching dimensions - string = 'keep' values
                %%%%%%%%%%%%%%%%%%%%%%%%
                % First up, generate matrix where all dimensions are ':', e.g.
                % (:,:,:)
                bm=strcat('(',repmat(':,',1,length(size(field))));
                bm(length(bm))=')'; % replace last comma with bracket
                % Find index of string where char = ':'
                rx=regexp(bm,':');
                % which of these corresponds to our matching dimension?
                rx=rx(mi);
                % Now replace this ':' with our 'keep' variable
                bm=[bm(1:(rx-1)),'items2Keep',bm((rx+1):end)];
                % generate our command (a filter of the multi-dimensional data):
                command=sprintf('field%s',bm);
                % evaluate command:
                field=eval(command);
                % replace field in new struct:
                news.(fnc)=field;
            end
        end
    otherwise
        error('Shouldn''t get here!')
end

end

