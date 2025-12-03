function neighbors = findCellNeighbours(F)
% FINDCELLNEIGHBOURS_FIXED  Reliable neighbour builder for polygonal meshes.
%
%   neighbors = findCellNeighbours_fixed(F)
%
%   Inputs:
%     F - nCells x nVertsPerCell (can be 3 for triangles, 4 for quads, or
%         padded with NaN/0 for variable-length cells).
%
%   Outputs:
%     neighbors - nCells x maxEdgesPerCell matrix (zero-padded) listing
%                 neighbour cell indices for each cell; 0 means boundary/no neighbor.
%
%   Notes:
%    - Works for triangular/quadrilateral/any polygon cells.
%    - Robust to NaN or 0 padding in F.
%    - Uses sortrows + run detection to avoid any hashing/indexing pitfalls.
%

% --- sanitize input - convert zeros to nan and detect variable-length cells
%Forig = F;
F(F==0) = NaN;

[nCells, ~] = size(F);

% Determine actual vertex counts per cell (allow variable-length rows)
nVertsPerCell = sum(~isnan(F),2);
maxV = max(nVertsPerCell);

% Preallocate edges: each cell contributes as many edges as it has vertices
% We'll build a list of (v_i, v_next) pairs.
totalEdges = sum(nVertsPerCell);
edges = zeros(totalEdges,2);
cellId = zeros(totalEdges,1);
localEdgeIdx = zeros(totalEdges,1);

ptr = 0;
for c = 1:nCells
    nv = nVertsPerCell(c);
    if nv < 3
        continue
    end
    verts = F(c,1:nv);
    nextVerts = verts([2:nv, 1]);
    idxs = (1:nv) + ptr;
    edges(idxs,1) = verts(:);
    edges(idxs,2) = nextVerts(:);
    cellId(idxs) = c;
    localEdgeIdx(idxs) = 1:nv;
    ptr = ptr + nv;
end

% Trim any unused prealloc (shouldn't be necessary but safe)
edges = edges(1:ptr, :);
cellId = cellId(1:ptr);
%localEdgeIdx = localEdgeIdx(1:ptr);

% Canonical ordering of each edge (so [a b] == [b a])
edgesSorted = sort(edges, 2);

% Use sortrows to group identical edges, but keep permutation mapping I
[edgesSortedRows, I] = sortrows(edgesSorted);  % we get sorted edges and the mapping I

% Reorder the supporting arrays to match edgesSortedRows
cellId_sorted = cellId(I);
%localEdgeIdx_sorted = localEdgeIdx(I);

% Find runs of identical rows in edgesSortedRows
if isempty(edgesSortedRows)
    neighbors = zeros(nCells, 0);
    return
end

sameNext = all(edgesSortedRows(1:end-1,:) == edgesSortedRows(2:end,:), 2);
% run boundaries:
runStarts = [1; find(~sameNext) + 1];
runEnds   = [find(~sameNext); size(edgesSortedRows,1)];

% pre-allocate neighbour matrix with maximum edges per cell
maxEdges = maxV;
neighbors = zeros(nCells, maxEdges);

% Process runs
for r = 1:numel(runStarts)
    s = runStarts(r);
    e = runEnds(r);
    runLen = e - s + 1;
    if runLen == 1
        % boundary edge (only one cell uses this edge) -> nothing to do
        continue
    elseif runLen == 2
        % normal interior edge, exactly two cells share it
        idxA = s;
        idxB = s+1;
        tA = cellId_sorted(idxA);
        tB = cellId_sorted(idxB);
%        eA = localEdgeIdx_sorted(idxA);
%        eB = localEdgeIdx_sorted(idxB);

        % Place neighbour into the first empty slot for each triangle
        posA = find(neighbors(tA,:)==0,1,'first');
        posB = find(neighbors(tB,:)==0,1,'first');
        if isempty(posA) || isempty(posB)
            error('Unexpected: no free neighbour slot for triangle %d or %d', tA, tB);
        end
        neighbors(tA, posA) = tB;
        neighbors(tB, posB) = tA;

    else
        % >2 cells share same edge (non-manifold). Warn and cyclic-assign.
        warning('Non-manifold edge: %d cells share the same edge [%d %d].', runLen, edgesSortedRows(s,1), edgesSortedRows(s,2));
        triList = cellId_sorted(s:e);
        for k = 1:runLen
            a = triList(k);
            b = triList(mod(k,runLen)+1);
            posA = find(neighbors(a,:)==0,1,'first');
            if isempty(posA)
                error('No free neighbour slot for triangle %d during non-manifold assignment', a);
            end
            neighbors(a,posA) = b;
        end
    end
end

end
