function [boundaryIndices, xb, yb] = meshBoundary(F, varargin)
% meshBoundary  Fast, backward-compatible boundary extractor
%
% BACKWARD COMPATIBILITY:
%   - Call with meshStruct:
%       [boundaryIndices, xb, yb] = meshBoundary(meshStruct)
%   - Call with faces, x, y:
%       [boundaryIndices, xb, yb] = meshBoundary(faces, x, y)
%
% NOTES:
%   - Reproduces the edge-following logic from the verified working version.
%   - Speed: vectorized edge extraction + compact local indexing + a
%     hash-based merge step for joining loops that share endpoints.
%
% OUTPUTS:
%   boundaryIndices : vector of vertex indices; NaN separates loops
%   xb, yb          : coordinates (empty if not requested / not provided)

tAll = tic;

% --- Input handling ---
if isstruct(F)
    faces = F.meshIndices;
    xMesh = F.xMesh;
    yMesh = F.yMesh;
elseif nargin >= 3
    faces = F;
    xMesh = varargin{1};
    yMesh = varargin{2};
else
    error('Either pass meshStruct or (faces,x,y).');
end

Nc = size(faces,1);
nvPer = size(faces,2);

% --- Step 1: boundary edges ---
if nvPer == 3
    edges = [faces(:,[1 2]); faces(:,[2 3]); faces(:,[3 1])];
else
    edges = [faces(:,[1 2]); faces(:,[2 3]); faces(:,[3 4]); faces(:,[4 1])];
end
edges = sort(edges,2);
[uniqueEdges,~,ic] = unique(edges,'rows');
counts = accumarray(ic,1);
boundaryEdgesAll = uniqueEdges(counts==1,:);
m = size(boundaryEdgesAll,1);

if m == 0
    boundaryIndices = [];
    xb = []; yb = [];
    return;
end

% --- Step 2: compact boundary vertex indexing ---
boundaryVertsGlobal = unique(boundaryEdgesAll(:));
NvB = numel(boundaryVertsGlobal);
maxGlobal = max(boundaryVertsGlobal);
map = zeros(maxGlobal,1);
map(boundaryVertsGlobal) = 1:NvB;
localToGlobal = boundaryVertsGlobal(:);

BE = [map(boundaryEdgesAll(:,1)), map(boundaryEdgesAll(:,2))];

% --- Step 3: vertex->edge lookup ---
edgeIDs = (1:m).';
vRep = BE(:);
eRep = repmat(edgeIDs, 2, 1);
vertexEdgeList = accumarray(vRep, eRep, [NvB,1], @(v){v});

% --- Step 4: walk edges ---
visited = false(m,1);
loops = {}; loopsCount = 0;
for startE = 1:m
    if visited(startE), continue; end
    a = BE(startE,1); b = BE(startE,2);
    visited(startE) = true;
    prev = a; curr = b;
    chain = [prev; curr];
    while true
        eList = vertexEdgeList{curr};
        nextE = 0; nextV = 0;
        for ei = eList(:)'
            if visited(ei), continue; end
            p = BE(ei,1); q = BE(ei,2);
            if p == curr, cand = q; else cand = p; end
            if cand ~= prev
                nextE = ei;
                nextV = cand;
                break;
            end
        end
        if nextE == 0
            break;
        end
        visited(nextE) = true;
        prev = curr;
        curr = nextV;
        chain(end+1,1) = curr; %#ok<AGROW>
        if curr == chain(1)
            break;
        end
    end
    loopsCount = loopsCount + 1;
    loops{loopsCount} = chain; %#ok<AGROW>
end

% --- Step 5: merge loops sharing endpoints ---
starts = cellfun(@(L)L(1), loops);
ends   = cellfun(@(L)L(end), loops);
changed = true;
while changed
    changed = false;
    keyStart = containers.Map('KeyType','double','ValueType','double');
    for i = 1:numel(loops)
        s = starts(i);
        if ~isKey(keyStart, s)
            keyStart(s) = i;
        end
    end
    i = 1;
    while i <= numel(loops)
        e = ends(i);
        if isKey(keyStart, e)
            j = keyStart(e);
            if j ~= i
                loops{i} = [loops{i}; loops{j}(2:end)];
                loops(j) = [];
                starts(i) = loops{i}(1);
                ends(i) = loops{i}(end);
                starts(j) = [];
                ends(j) = [];
                changed = true;
                continue;
            end
        end
        i = i + 1;
    end
end

% --- Step 6: convert to global indices ---
boundaryIndices = [];
for i = 1:numel(loops)
    localLoop = loops{i};
    gl = localToGlobal(localLoop);
    if gl(1) ~= gl(end)
        gl(end+1) = gl(1);
    end
    boundaryIndices = [boundaryIndices; gl(:); NaN]; %#ok<AGROW>
end

% --- Step 7: coordinates ---
if nargout > 1
    xb = nfilter(xMesh, boundaryIndices);
    yb = nfilter(yMesh, boundaryIndices);
else
    xb = []; yb = [];
end

%fprintf('meshBoundary: done in %.2fs, loops=%d, boundaryEdges=%d\n', toc(tAll), numel(loops), m);
end
