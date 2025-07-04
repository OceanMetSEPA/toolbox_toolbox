function op = loadMatfile(matfileName)
%LOADMATFILE Load .mat file(s) and return contained variable directly
%
%   op = loadMatfile(filename)
%   op = loadMatfile({filename1, filename2, ...})
%
% This function loads .mat file(s) efficiently using `load` and returns
% the contents without wrapping in a struct. If a .mat file contains only
% one variable, that variable is returned directly. If it contains multiple
% variables, the struct is returned as-is.
%
% Compared to `importdata`, this method is significantly faster (~3x).
%
% Examples:
%   op = loadMatfile('data1.mat');
%   op = loadMatfile({'data1.mat', 'data2.mat'});

% Ensure input is a cell array of strings
matfileName = cellstr(matfileName);

% Handle multiple files recursively
if numel(matfileName) > 1
    % Load each file individually
    results = cellfun(@loadMatfile, matfileName, 'UniformOutput', false);
    try
        % Try to concatenate results if possible
        op = vertcat(results{:});
    catch
        % Otherwise, return as cell array
        op = results;
    end
    return;
end

% Single file case
matfileName = char(matfileName);
if ~isfile(matfileName)
    error('File not found: %s', matfileName);
end

% Load file
data = load(matfileName);

% Attempt to extract the only field if there’s just one
fields = fieldnames(data);
if numel(fields) == 1
    op = data.(fields{1});
else
%    warning('Multiple variables found in file ''%s''. Returning full struct.', matfileName);
    op = data;
end

end
