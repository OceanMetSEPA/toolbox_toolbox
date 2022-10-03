function new = struct2struct(old)
%struct2struct: Convert from/to struct-array to/from structure of arrays
% usage: new = struct2struct(old)
%
% If 'old' is a scalar struct containing arrays (each with the same number
% of rows, N) then 'new' will be an N-by-1 struct-array whose fields have a
% single row.
%
% If 'old' is an N-by-1 struct-array whose fields have a single row (e.g.
% as returned above) then 'new' will be a scalar structure whose fields
% have N rows.
%
% Examples:
%
%  % Either representation can have advantages for representing basic
%  % spreadsheet or database information. For example, starting with:
%  person(1).name = 'John'; person(1).age = 23;
%  person(2).name = 'Mary'; person(2).age = 45;
%  person(3).name = 'Bob';  person(3).age = 67;
%  person(1), names = char(person.name)
%
%  % Converting to a struct of arrays allows fields to be added and removed
%  % more easily and eases computation of filtering or sorting indices.
%  % (A struct of arrays is also the format returned from csv2struct.)
%  data = struct2struct(person);
%  data.gender = {'Male'; 'Female'; 'Male'}
%  male_filter = strcmpi(data.gender, 'male');
%  [names_sorted names_sort_inds] = sort(data.name);
%
%  % Converting (back) to a struct-array makes it easier to apply filtering
%  % and sorting operations using the above-computed indices/indicators.
%  person = struct2struct(data);
%  male = person(male_filter)
%  male_names = char(male.name)
%  sorted = person(names_sort_inds); % all fields simultaneously sorted
%  sorted_names = char(sorted.name)
%  sorted_gender = char(sorted.gender)
%
% Take care when combining sorting and filtering operations on one struct!
%
% See also: struct2cell, cell2struct, csv2struct
% csv2struct is available from the MATLAB Central File Exchange:
%  http://www.mathworks.com/matlabcentral/fileexchange/26106-csv2struct
% Look out for future updates, which may include a basic
% spreadsheet/database class, that would simplify sorting and filtering...
%  http://www.mathworks.com/matlabcentral/fileexchange/authors/27434
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   struct2struct.m  $
% $Revision:   1.0  $
% $Author:   Ted.Schlicke  $
% $Date:   Nov 17 2020 18:03:20  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Copyright 2010 Ged Ridgway

%% Common code
fields = fieldnames(old);
F = numel(fields);

%% Decide direction of conversion
if isscalar(old)
    %% Convert from scalar struct of array fields to struct-array
    % First check dimensions and ensure fields are cell arrays
    N = size(old.(fields{1}), 1);
    for f = 1:F
        field = old.(fields{f});
        NRows=size(field,1);
        if NRows~=N && NRows>0
            error('Struct contains fields with different numbers of rows')
        end
        if ischar(field)
            field = cellstr(field);
        elseif ~iscell(field) || numel(field) ~= N
            try
                field = num2cell(field, 2:ndims(field));
                %            catch %#ok (want backwards compatibility so don't catch object)
            catch
                error(['Failed to convert field %d to cell, ' ...
                    'try manually converting first'], f)
            end
        end
        old.(fields{f}) = field;
    end
    %%
    % Build struct() arguments and create new struct
    args = repmat(fields', 2, 1); % 2-by-F
    for f = 1:F
        args{2, f} = old.(fields{f});
    end
    new = struct(args{:}); % column-wise vectorisation pairs names & values
else
    %% Convert from struct-array to scalar structure of array fields
    % First check that each field has a single row
    for f = 1:F
        fSize=size(old(1).(fields{f}));
        if fSize(1) > fSize(2) % Transpose - might avoid error below
            old(1).(fields{f})=old(1).(fields{f})';
        end
        if size(old(1).(fields{f}), 1) > 1
            error('Struct-array contains fields with more than one row')
        end
    end
    %%
    % Add fields to new scalar structure
    new = struct;
    for f = 1:F
        % original approach commented out below breaks if struct array contains fields
        % with different sized numeric / cell values. Here we try to fix that
        if isstruct(old(1).(fields{f})) % Combine struct fields as cells
            new.(fields{f})={old.(fields{f})}';
        else
            try % to combine fields as matrix
                new.(fields{f})=cat(1,old.(fields{f}));
                % If we've got a char matrix, convert to cells
                if ischar(new.(fields{f}))&&min(size(new.(fields{f})))>1
                    new.(fields{f})=cellstr(new.(fields{f}));
                end
            catch % if error thrown (e.g. different size fields), bundle into cell array
                new.(fields{f})={old.(fields{f})}';
            end
            
            %        if ~ischar(old(1).(fields{f}))
            %            new.(fields{f}) = cat(1, old.(fields{f}));
            %        else
            %            % cat(1, struct.cellstr) tries to build character array and
            %            % fails if any strings are different lengths; we build cellstr
            %            new.(fields{f}) = {old.(fields{f})}';
            %        end
        end
    end
end
