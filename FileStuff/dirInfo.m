function op = dirInfo(f, varargin)
% dirInfo - Enhanced dir() wrapper for multiple files/folders with sorting.
%
% INPUT:
%   f              - File/folder name or cell array of them.
%   sortOption     - ('size','date','name')  [optional]
%   ascending      - true/false or numeric (default: true)
%
% OUTPUT:
%   Table with fields:
%       name, folder, date (datetime), bytes, isdir, sizeLabel, fullfile
%
% EXAMPLES:
%   dirInfo(userpath)                % list all files in path
%   dirInfo(pwd,'size',-1)           % sort by size descending
%
% -------------------------------------------------------------------------

if nargin < 1
    help(mfilename);
    return
end

% --- Handle input & sorting options
if ~isempty(varargin)
    sortOptions = {'size','date','name'};
    sortOption  = resolveOption(varargin,sortOptions);
    ascending   = resolveOption(varargin,[true,false]);
else
    sortOption = [];
    ascending  = true;
end

f = cellstr(f);
Nf = numel(f);
diCellArray = cell(Nf,1);

for index = 1:Nf
    fi = f{index};
    if ~isfile(fi) && ~isfolder(fi)
        warning('%s not file/folder!!', fi);
        continue
    end

    dii = dir(fi);  % struct array

    % --- Convert date string to datetime safely
    try
        for k = 1:numel(dii)
            dii(k).date = datetime(dii(k).date, 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
        end
    catch
        % fallback if format differs
        for k = 1:numel(dii)
            dii(k).date = datetime(dii(k).date);
        end
    end

    % Remove datenum field if it exists
    if isfield(dii,'datenum')
        dii = rmfield(dii,'datenum');
    end

    % --- Add sizeLabel
    fsize = arrayfun(@(x) sizeString(x.bytes), dii, 'UniformOutput', false);
    [dii.sizeLabel] = fsize{:};

    % --- Add fullfile path
    ff = arrayfun(@(x) fullfile(x.folder, x.name), dii, 'UniformOutput', false);
    [dii.fullfile] = ff{:};

    diCellArray{index} = dii;
end

% --- Merge into single struct array
diStructArray = vertcat(diCellArray{:});

% --- Optional sorting
if ~isempty(sortOption)
    switch char(sortOption)
        case 'size'
            vals2Sort = [diStructArray.bytes];
        case 'date'
            vals2Sort = [diStructArray.date];  % now datetime, no need for datenum
        case 'name'
            vals2Sort = {diStructArray.name};
        otherwise
            error('Invalid sort option %s', sortOption);
    end

    if ascending
        order = 'ascend';
    else
        order = 'descend';
    end
    fprintf('Sorting by ''%s'' in %sing order\n', sortOption, order);

    [~, indexOrder] = sort(vals2Sort, order);
    diStructArray = diStructArray(indexOrder);
end

% --- Convert to table for easier use
op = struct2table(diStructArray);

end
