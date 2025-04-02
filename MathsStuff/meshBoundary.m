function varargout = meshBoundary(F,varargin)
%function boundaryIndices = meshBoundaries(F)
%
% ChatGPT improved original version immensely!
%
% Extracts boundary loops from a mesh and returns them as a 1D array
% with NaN separating different loops.
%
% Input:
%   - F: Face connectivity (Nx3 or Nx4 matrix for triangles/quads)
% Optional Inputs (for backward compatability):
%   x,y
% Output:
%   - boundaryIndices: 1D array of boundary node indices, with NaN separating loops

xySpecified=nargin>1;
if xySpecified
    try
        x=varargin{1};
        y=varargin{2};
    catch err
        disp(err)
        error('Invalid input arguments!')
    end
end

% Step 1: Extract all unique boundary edges
if size(F, 2) == 3  % Triangles
    edges = [F(:, [1,2]); F(:, [2,3]); F(:, [3,1])];
elseif size(F, 2) == 4  % Quadrilaterals
    edges = [F(:, [1,2]); F(:, [2,3]); F(:, [3,4]); F(:, [4,1])];
else
    error('Unsupported element type');
end

edges = sort(edges, 2);  % Sort edge pairs to handle direction
[uniqueEdges, ~, idx] = unique(edges, 'rows');
counts = accumarray(idx, 1);  % Count occurrences of each edge
boundaryEdges = uniqueEdges(counts == 1, :);  % Select edges that appear only once

% Step 2: Group edges into separate closed loops
loops = groupBoundaryLoops(boundaryEdges);

% Step 3: Convert loops into 1D array with NaNs separating them
boundaryIndices = [];
for i = 1:length(loops)
    loop = loops{i}(:, 1);  % Extract ordered node indices
    boundaryIndices = [boundaryIndices; loop; NaN]; %#ok<AGROW> % Add NaN separator
end

% Prepare output
if nargout==0
    % Waste of time!
    return
end
if nargout>1 && ~xySpecified
    error('Specify x,y as input arguments to get boundary coordinates')
end
varargout{1}=boundaryIndices;
if nargout==1
    % Our work here is done
    return
end

% If we get here, we've got coordinates to filter
xb=nfilter(x,boundaryIndices);
yb=nfilter(y,boundaryIndices);
if nargout==2
    varargout{2}=[xb,yb];
elseif nargout==3
    varargout{2}=xb;
    varargout{3}=yb;
else
    error('Too many output arguments')
end


    function loops = groupBoundaryLoops(boundaryEdges)
        % Groups boundary edges into multiple closed loops
        loops = {};
        while ~isempty(boundaryEdges)
            loop = boundaryEdges(1, :);  % Start with first edge
            boundaryEdges(1, :) = [];  % Remove from list

            % Build the loop
            while true
                lastNode = loop(end, 2);
                nextIdx = find(boundaryEdges(:, 1) == lastNode, 1);

                if isempty(nextIdx)
                    nextIdx = find(boundaryEdges(:, 2) == lastNode, 1);
                    if ~isempty(nextIdx)
                        boundaryEdges(nextIdx, :) = fliplr(boundaryEdges(nextIdx, :));
                    end
                end

                if isempty(nextIdx)
                    break;  % No more connected edges, loop is complete
                end

                % Append to loop and remove from list
                loop = [loop; boundaryEdges(nextIdx, :)];
                boundaryEdges(nextIdx, :) = [];
            end

            loops{end+1} = loop;
        end
    end
end
