function [ varargout ] = meshBoundary(varargin)
% find boundary(ies) of mesh
%
% A mesh is a series of non-intersecting lines connecting a collection of
% points, for example a Delaunay Triangulation. This function is a
% generalisation of the triangulationBoundary function and can process
% quadrilaterals (and beyond?) as well as triangles. It identifies the
% boundaries of such a mesh,  thereby defining regions within and outside
% the triangulated domain.
%
% Meshes are typically defined in terms of sets of indices of x,y arrays.
% For example, a mesh will contain an array of indices with one
% column for each of the 3 vertices defining a triangle, and one row for
% each triangle.
%
% For meshes consisting of polygons with differing numbers of points, e.g.
% as returned by 'voronoin', the indices are stored in a cell array.
%
% Once the boundary indices are identified, they are connected into closed
% loops.  External boundaries are stored in clockwise order; internal boundaries
% are store in anti-clockwise order. This ensures the inpolygon function
% works as intended. Multiply-nested boundaries are not (yet) implemented.
%
% Meshes can be passed to this function as indices or files (currently only
% DHI Mike files are supported).
%
% INPUTS:
% * meshIndices - cell array or matrix of indices
% plus:
% 1) [x,y], or
% 2  [x,y,z], or
% 3) x,y, or
% 4) x,y,z
% OR : matlab patch handle which contains faces/vertices needed for
% boundary calculation
%
% Files can be passed using the optional argument below
%
% Optional Inputs:
% cellOutput (false) - If true, return indices / coordinates in cell array, with one
%                      cell per edge grouping. If false, return data in NaN separated arrays
% mike ([]) - for specifying MIKE mesh file
%
% Plot Options:
% plot (false) - plot mesh edges, filling in clockwise groups
% fill (false) - fill in polygons
% edgeColour ('b') - polygon boundary colour
% cwColour ('b') - colour of clockwise polygons
% ccwColour ('w') - colour of anti-clockwise polygons
% lineWidth (2) - of polygons in plot
% meshColour ('none') - edge colour of mesh
% labelSpacing (0) - spacing between group number labels (0 means no labels)
% verbose (false) - messages indicating progress
%
% OUTPUTS (depending on number of output arguments specified)
% 1) edgeIndices - mesh vertices on edge
% 2) [edgeIndices,XY] - as above, plus 2 column array containing x,y coordinates
% 3) [edgeIndices,x,y] - as 1, plus separate x,y variables
%
% NB output options 2,3, and plot option, require coordinates to be passed
% to function (i.e. not input case 1)
%
% EXAMPLES:
% Load mesh file:
% meshFileName ='\\sepa-fp-01\DIR SCIENCE\EQ\Oceanmet\Projects\ocean\ShunaSound\ShunaMIKEGrid_50m_25mFFRefined_v1_Alt5.mesh';
% [meshIndices,nodes]=mzReadMesh(meshFileName);
% xMesh=nodes(:,1);
% yMesh=nodes(:,2);
% zMesh=nodes(:,3);
%
% [edgeIndices,xyCoordinates]=meshBoundary(meshIndices,xMesh,yMesh,'cell',0,'lineWidth',0,'label',100) % OK xy = 2 column cell array
% [edgeIndices,xyCoordinates]=meshBoundary(meshIndices,xMesh,yMesh,'cell',1,'plot',1,'cw','r') ; %OK, xy 2 column double array
% [edgeIndices,x,y]=meshBoundary(meshIndices,xMesh,yMesh,'cell',0,'mesh','k') % x,y, separate arrays
% meshBoundary('mike',meshFileName,'plot',1);
% plot(x,y) % Plot output
%
% DEPENDENCIES:
% mzPlot - from MIKE toolbox for plotting mesh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   meshBoundary.m  $
% $Revision:   1.4  $
% $Author:   Ted.Schlicke  $
% $Date:   Nov 24 2020 09:46:46  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help meshBoundary
    return
end

%% Process input arguments
if iscell(varargin{1}) % e.g. indices from voronoin function
    varargin{1}=paddedCell2Mat(varargin{1});
end
argClasses=cellfun(@ischar,varargin); % get classes of arguments
NNumArg=find(argClasses==1,1,'first')-1; % find first non-numeric argument
if isempty(NNumArg) % no non-numeric arguments? Then they're all numeric
    NNumArg=nargin;
end
numArgs=varargin(1:NNumArg);
varargin(1:NNumArg)=[]; % strip off numeric arguments - these are our options

meshIndices=[];
xMesh=[];
yMesh=[];
zMesh=[];
if NNumArg>0
    meshIndices=numArgs{1};
    if NNumArg==1
        if ishandle(numArgs{1}) % patch handle perhaps?
            try
                % Need to find faces & vertices
                faces=get(numArgs{1},'faces');
                vertices=get(numArgs{1},'Vertices');
                % Vertices not unique. Find unique ones...
                [a,~,c]=unique(vertices,'rows');
                xMesh=a(:,1);
                yMesh=a(:,2);
                zMesh=zeros(size(xMesh));
                % And map face indices to unique values
                meshIndices=c(faces);
            catch err
                disp(err)
                error('invalid handle (need patch)')
            end
        else
            error('No x,y coordinates supplied')
        end
    elseif NNumArg==2
        if size(numArgs{2},2)<2
            error('Expected array with x,y colums as second argument');
        else
            xMesh=numArgs{2}(:,1);
            yMesh=numArgs{2}(:,2);
        end
        if size(numArgs{2},2)>2
            zMesh=numArgs{2}(:,3);
        end
    elseif NNumArg>2
        xMesh=numArgs{2};
        yMesh=numArgs{3};
    end
    if NNumArg==4
        zMesh=numArgs{4};
    end
    if NNumArg>4
        error('Too many numeric inputs!')
    end
end
% Optional inputs:
options=struct;
options.mike=[];
options.plot=false;
options.verbose=false;
options.cellOutput=false;
options.fill=false;
options.cwColour='b';
options.ccwColour='w';
options.edgeColour='b';
options.meshColour='none';
options.lineWidth=3;
options.labelSpacing=0;
options=checkArguments(options,varargin);

if isempty(meshIndices) && ~isempty(options.mike)
    try
        [meshIndices,nodes]=mzReadMesh(options.mike);
        xMesh=nodes(:,1);
        yMesh=nodes(:,2);
        zMesh=nodes(:,3);
    catch
        error('Error reading MIKE mesh file ''%s''',options.mike)
    end
end

% Some final error checking before we get going:
if ~isequal(size(xMesh),size(yMesh))
    error('X, Y should be of equal size')
end
% Check for infinite values (which can occur in voronoi cells)
if any(isinf(xMesh)) || any(isinf(yMesh))
    k=intersect(find(isinf(xMesh)),find(isinf(yMesh)));
    meshIndices(any(ismember(meshIndices,k),2),:)=[]; % remove links to Inf
end
if isvector(meshIndices) % only one set of indices?
    meshIndices=meshIndices(:)'; % make sure it's a row vector
end
% That'll do for now- ready to get going
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Part 1 - identify boundary indices
NNodes=length(xMesh);
[NPolygons,NEdges]=size(meshIndices);
% Each polygon has NEdges sides
% Each side defined by 2 node indices.
% If given side occurs in 2 polygons, there must be a polygon either side.
% If given side only appears in single polygon, it must be an edge bit!
if options.verbose
    fprintf('Number of polygons = %d\nNumber of sides = %d\nNumber of nodes = %d\n',NPolygons,NEdges,NNodes)
    fprintf('Finding edge indices...\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%% Find Edge indices %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For meshes with different types of polygons, there may be zeros present.
% For example, a 4 column array used to specify quadrilaterals may contain
% rows with a single zero to represent a triangle.
% Successive indices in a given polygon are connected, and we don't want to
% consider non-connected sides. So it's easier to remove zeros before looking at edge combinations.
% We loop through the array of indices, grouping them by how many zeros per
% row they have. (We'll probably only ever have 3 or 4, but this should
% generalise it to polygons with more sides...)
NZerosPerRow=sum(meshIndices==0,2); % number of zeros in each row
uniqueNumberOfZeros=unique(NZerosPerRow);
NUniqueZeros=length(uniqueNumberOfZeros);
allPairs=cell(NUniqueZeros,1); % cell to store separate groupings
for i=1:NUniqueZeros
    meshi=meshIndices(NZerosPerRow==uniqueNumberOfZeros(i),:); % Get mesh indices with specified number of zeros
    NPolygons=size(meshi,1);
    m=cell2mat(arrayfun(@(rowi){meshi(rowi,meshi(rowi,:)>0)},1:NPolygons)'); % Loop through, removing zeros
    NVertex=size(m,2); % Number of vertices
    m=m'; % transpose for circshift function
    iPairs=arrayfun(@(i){circshift(m,i)},0:NVertex-1)'; % generate shifted versions of polygon indices
    iPairs=cell2mat(iPairs')'; % Convert back to array with NPolygons * NVertex rows
    iPairs=iPairs(:,1:2); % Keep the 1st 2 points.
    allPairs{i}=iPairs; % Store points for this number of zeros in our cell array
end
% Now generate array containing all edges in all polygons:
allPairs=vertcat(allPairs{:});
% Make sure first column < second column
allPairs=sort(allPairs,2);
% Make sure pairs don't contain 'forbidden' indices
%allPairs(any(ismember(allPairs,xy2Ignore),2),:)=[];
%assignin('base','allPairs',allPairs);
% Now check to see which vertex connections appear just once:
[C,~,ic]=unique(allPairs,'rows'); % Find unique values
%C(ic,:) % Bye the bye, this is how to use indices to create original matrix
counts=histc(ic,unique(ic)); % Find how many times each side occurs
edgeConnections=C(counts==1,:); %These are the ones we want (2d matrix defining edges)

%%  Part 2 - determine how these indices are connected together, and sort into groups
edgeNodeIndices=unique(edgeConnections); % Extact all indices (each one occurs twice in 'edgeConnections'
NEdgeIndices=length(edgeNodeIndices);

if options.verbose
    fprintf('Found %d edges (%d unique indices)\n',length(edgeConnections),NEdgeIndices)
    fprintf('Organising into groups...\n')
end

% Prepare cell array to store polygon groupings:
groupIndices=cell(NNodes,1);
groupIndex=1;
edges2Add=edgeConnections; % Need to add all edges at present-
previousNodeIndex=[];
while ~isempty(edges2Add)
    xEdge=xMesh(edges2Add); % Find furthest east point- start there
    edgeNodeIndex=edges2Add(xEdge==max(xEdge(:))); % Node index of furthest east point
    edgeNodeIndex=edgeNodeIndex(1); % in case there's multiples...
    % Prepare group array to store edge indices
    seq=NaN(NEdgeIndices,1);
    seq(1)=edgeNodeIndex; % Populate first entry
    % Loop through points looking for connections to last point in sequence
    keepLooping=true;
    while keepLooping
        seqIndex=find(~isnan(seq),1,'last'); % last index in sequence
        edgeNodeIndex=seq(seqIndex); % most recent edge node we've added
        % Find points connected to this edge node. Use our connection matrix:
        [edgeRows,~]=find(edges2Add==edgeNodeIndex);
        % Do we have something to add to our sequence?
        if ~isempty(edgeRows)
            %            edges2Add(edgeRows,:)
            % Found something? Then extract indices connected to current edge node
            connectedEdgeIndices=edges2Add(edgeRows,:);
            connectedEdgeIndices=unique(connectedEdgeIndices); % ignore duplicates
            connectedEdgeIndices(connectedEdgeIndices==edgeNodeIndex)=[]; % and edge node itself
            if length(connectedEdgeIndices)>1
                % Identify next edge in sequence (separate function, which processes angles of connected edges)
                nextIndex=nextIndexInSequence(edgeNodeIndex,previousNodeIndex,connectedEdgeIndices,xMesh,yMesh);
            else
                nextIndex=connectedEdgeIndices;
            end
            if isempty(nextIndex)
                error('No edges connected to %d',edgeNodeIndex)
            end
            if length(nextIndex)>1 % Shouldn't have multiple values if indices define consistent mesh
                fprintf('Index %d connected to edge points:\n',edgeNodeIndex)
                disp(nextIndex)
                error('Found multiple connection points; please check input indices')
            end
            seq(seqIndex+1)=nextIndex; % update sequence of points
            currentEdge=sort([edgeNodeIndex,nextIndex]);
            edge2Remove= ismember(edges2Add,currentEdge,'rows'); % Find edge containing current and previous indices...
            edges2Add(edge2Remove,:)=[]; % ... and remove it from list since it's been incorporated
        else % nothing to connect to this sequence.
            seq(isnan(seq))=[]; % remove nan values
            groupIndices{groupIndex}=seq;
            groupIndex=groupIndex+1; % update index
            keepLooping=false; % and exit loop
        end
    end
    if isempty(edges2Add)
        break
    end
    if seqIndex>NEdgeIndices % Emergency loop escape - shouldn't get here!
        break
    end
end

groupIndices=groupIndices(~cellfun(@isempty,groupIndices));
NGroups=length(groupIndices);
if options.verbose
    fprintf('Found %d edge groups\n',NGroups)
end
if NGroups==0
    error('No Edge Indices identified!');
end

% Function to identify which connected point. This was added after original
% function misbehaved if polygons interstected at a single point
    function nextIndex=nextIndexInSequence(currentNodeIndex,previousNodeIndex,contenderEdgeIndices,x,y)
        % Find next edge in sequence. This is next vector in clockwise
        % sequence from current Edge
        if isempty(previousNodeIndex) % Starting off?
            currentVector=[1,0]; % Use horizontal unit vector
        else % Use vector defined by previous edge
            currentVector=[x(currentNodeIndex)-x(previousNodeIndex),y(currentNodeIndex)-y(previousNodeIndex)];
        end
        previousAngle=mod(atan2(currentVector(2),currentVector(1)),2*pi);
        % Now define potential vectors to new points
        dx=x(contenderEdgeIndices)-x(currentNodeIndex);
        dy=y(contenderEdgeIndices)-y(currentNodeIndex);
        % Orientation of potential new points:
        currentAngle=mod(atan2(dy,dx),2*pi); % scale between 0 and 2pi, where 0 is +ve x axis
        % Angle between current point, previous boundary point and potential new point:
        boundaryAngle=mod(pi+currentAngle-previousAngle,2*pi);
        % Get max angle: this corresponds to last point as we rotate round points anticlockwise
        % (i.e. we're rotating clockwise round group)
        maxAngle=boundaryAngle==max(boundaryAngle);
        nextIndex=contenderEdgeIndices(maxAngle);
    end


%% Sort ordering of polygons (so inpolygon function works)
%
% Outermost polygon should be clockwise; internal ones anti-clockwise
% [ignoring nested meshs for now...]
% For each group, we check to see if it is entirely within another group.
% If it is, it's deemed to be enclosed. (Multiple nesting ignored...)
% For speed, we compare the corners of rectangles enclosing the group of
% points.
if ~isempty(xMesh)
    % Look for enclosed groups
    enclosingGroup=zeros(NGroups,1);
    for indexOfTestGroup=1:NGroups % for each group of indices, get its coordinates
        xi=xMesh(groupIndices{indexOfTestGroup});
        yi=yMesh(groupIndices{indexOfTestGroup});
        if length(unique(xi))>2 && length(unique(yi))>2 % get enclosing rectangle:
            [xi,yi]=boundaryRectangle(xi,yi,'close',0);
        end
        % Right, now test each of the other groups in turn.
        for indexOfSurroundingGroup=1:NGroups
            if indexOfTestGroup~=indexOfSurroundingGroup % don't compare group with itself!
                xj=xMesh(groupIndices{indexOfSurroundingGroup});
                yj=yMesh(groupIndices{indexOfSurroundingGroup});
                if length(unique(xj))>2 && length(unique(yj))>2
                    [xj,yj]=boundaryRectangle(xMesh(groupIndices{indexOfSurroundingGroup}),yMesh(groupIndices{indexOfSurroundingGroup}),'close',0);
                end
                % Is group being tested (outer loop) completely enclosed by
                % this group?
                if all(inpolygon(xi,yi,xj,yj))
                    enclosingGroup(indexOfTestGroup)=indexOfSurroundingGroup; % Store enclosing group
                    break % And don't bother checking others
                end
            end
        end
    end
    
    % Set orientation to clockwise/anti-clockwise depending on whether groups
    % are enclosed or not
    orderedGroups=cell(NGroups,1); % introduction of this variable mainly just to avoid warning of expanding size in loop below
    for i=1:NGroups
        xi=xMesh(groupIndices{i});
        yi=yMesh(groupIndices{i});
        flipit=false;
        if ispolycw(xi,yi) && enclosingGroup(i)
            flipit=true;
        elseif ~ispolycw(xi,yi) && ~enclosingGroup(i)
            flipit=true;
        end
        if flipit
            orderedGroups{i}=flipud(groupIndices{i});
        else
            orderedGroups{i}=groupIndices{i};
        end
    end
    groupIndices=orderedGroups;
end

%% Prepare Output
if options.cellOutput
    edgeNodeIndices=groupIndices(:);
    if ~isempty(xMesh)
        xEdges=cell(NGroups,1);
        yEdges=cell(NGroups,1);
        for i=1:NGroups
            if ~isempty(xMesh)
                xEdges{i}=xMesh(groupIndices{i});
                yEdges{i}=yMesh(groupIndices{i});
            end
        end
    end
else % Output as array
    if length(groupIndices)>1
        % Add NaN to each cell
        edgeNodeIndices=cellfun(@(x){[x;NaN]},groupIndices);
        % Convert cells to array
        edgeNodeIndices=vertcat(edgeNodeIndices{:});
    else
        edgeNodeIndices=groupIndices{:};
    end
    % Do same for coordinates if present
    if ~isempty(xMesh)
        xEdges=cellfun(@(x){[xMesh(x);NaN]},groupIndices);
        yEdges=cellfun(@(x){[yMesh(x);NaN]},groupIndices);
        xEdges=vertcat(xEdges{:});
        yEdges=vertcat(yEdges{:});
    end
end
% Allocate outputs, depending on how many requested by user
if nargout>=0 % changed from >0 - return something regardless
    varargout{1}=edgeNodeIndices;
    if nargout>1
        if isempty(xMesh)
            error('Too many outputs requested (no coordinates provided)')
        end
        if nargout==2
            varargout{2}=[xEdges,yEdges];
        elseif nargout==3
            varargout{2}=xEdges;
            varargout{3}=yEdges;
        else
            error('Too many outputs requested')
        end
    end
end

%% Plot mesh edges we've found?
if options.plot
    prepareFigure;
    lw=options.lineWidth;
    if isempty(zMesh)
        mzPlot(meshIndices,xMesh,yMesh,'EdgeColor',options.meshColour)
    else
        mzPlot(meshIndices,xMesh,yMesh,zMesh,'EdgeColor',options.meshColour);
    end
    for i=1:NGroups
        xi=xMesh(groupIndices{i});
        yi=yMesh(groupIndices{i});
        if options.fill
            if ispolycw(xi,yi) % fill in clockwise polygons
                c=options.cwColour;
            else
                c=options.ccwColour;
            end
            if lw==0
                fill(xi,yi,c,'EdgeColor','none','FaceAlpha',1);
            else
                fill(xi,yi,c,'LineWidth',lw,'FaceAlpha',1,'EdgeColor',options.edgeColour);
            end
        elseif lw>0
            plot(xi,yi,'LineWidth',lw,'Color',options.edgeColour)
        end
        k=1:options.labelSpacing:length(xi);
        text(xi(k),yi(k),num2str(i))
    end
end

end