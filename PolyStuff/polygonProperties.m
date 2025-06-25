function [ op ] = polygonProperties( varargin )
% Calculate properties of 2d polygon:
% * area
% * Lengths of sides
% * angles between sides
% * perimeter
%
% INPUTS:
% x - coordinates, with vertices in separate columns
% y - coordinates, as above
%
% OUTPUT:
% struct containing fields 'area','edges', 'angles' (in degrees)
%
% Examples:
%
% polygonProperties([0,3,3],[0,0,4]) % 3,4,5 pythagorean triangle
% polygonProperties(mikeMesh.xMesh(mikeMesh.tri),mikeMesh.yMesh(mikeMesh.tri)) % cell properties in MIKE mesh
%
% Notes:
% For a triangle, the vertices are points 1,2,3. This function calculates:
% 1) Edge lengths:
%        The edge lengths are calculated using pythagoras's theorem from the
%        vectors between points [1,2], [2,3] and [3,1].
% 2) Area:
%        use matlab polyarea function
% 3) Angles: 
%        define vectors connecting vertices, then use dot/cross product
% 4) Perimeter: 
%        sum up edge lengths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   polygonProperties.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Aug 12 2020 15:39:18  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help polygonProperties
    return
elseif nargin==1
    xy=varargin{1};
    x=xy(:,1)';
    y=xy(:,2)';
else
    x=varargin{1};
    y=varargin{2};
end
if isvector(x)
    x=reshape(x,1,[]);
    y=reshape(y,1,[]);
end

% Want polygon to be closed, so we can calculate last edge more easily
% Check to see if it is (compare 1st and last column coordinates)
closed=all(x(:,1)==x(:,end))&&all(y(:,1)==y(:,end));
if ~closed % repeat first column at end
    x(:,end+1)=x(:,1);
    y(:,end+1)=y(:,1);
end

[Np,Nv]=size(x);
Nv=Nv-1; % Number of vertices (take one off since we've closed it)
%
%fprintf('Getting polygon stats for %d polygons with %d vertices\n',Np,Nv)

pp=cell(Np,1); % cell array to store polygon stats
angs=NaN(Nv,1);
for polyIndex=1:Np % loop through polygons
    % Extract coordinates for this polygon
    xi=x(polyIndex,:);
    yi=y(polyIndex,:);
    % Differences in coordinates:
    dx=diff(xi);
    dy=diff(yi);
    % Lengths:
    edges=sqrt(dx.^2+dy.^2);
    % Area
    area=polyarea(xi,yi);
    % Now for angles:
    for vertexIndex=1:Nv % loop through vertices
        % Define vector corresponding to edge connecting vertices
        % https://uk.mathworks.com/matlabcentral/answers/101590-how-can-i-determine-the-angle-between-two-vectors-in-matlab
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % We need to define vectors defining our vertices. 
        % mod function give integers in range 0:Nv-1
        % The code below shifts this to 1:Nv which is what we're after
        i0=mod(vertexIndex-1,Nv)+1;
        i1=mod(vertexIndex-2,Nv)+1;
        a=[dx(i0),dy(i0),0];
        b=-[dx(i1),dy(i1),0]; % Need to flip one of them about (hence negative sign)  
        % This gives the angle between vectors in degrees (see
        % mathworks link above)
        angs(vertexIndex)=atan2d(norm(cross(a,b)), dot(a,b));
    end
    pp{polyIndex}=struct('area',area,'edges',edges,'angles',angs','perimeter',sum(edges));
end
op=vertcat(pp{:});
op=struct2struct(op);

end
