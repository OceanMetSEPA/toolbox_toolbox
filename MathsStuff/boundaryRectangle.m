function [ xBoundary,yBoundary ] = boundaryRectangle(varargin)
% Generate rectangle enclosing input coordinates x,y
%
% This is a trimmed down version of boundaryPolygon which uses
% MinBoundSuite package and allows a bunch of shape options (circle,
% parallelogram, triangle etc).
%
% INPUTS:
% x,y
%
% Optional Inputs:
% shape ['minmax'] - boundary shape to fit
% dx [0] - extra horizontal space
% dy [0] - extra vertical space
% N [50] - number of points used for fitting circle
% plot [false] - plot input points and boundary
% closeBoundary [true] - keep last element of boundary equal to first element
%
% OUTPUT- dependent on number of output arguments
% nargout == 2:
%   [xBoundary,yBoundary] - coordinates of boundary as separate variables
% nargout < 2:
%   xy - 2 column matrix of x,y boundary coordinates
%
% Example:
% boundaryPolygon(x,y,'shape','dx',1e3) % fit circle to data with extra boundary in x direction
%


% 20220923 - changed to allow single input (bounding box [x,y])
ip=varargin;
firstChar=find(cellfun(@ischar,varargin),1,'first');
varargin=ip(firstChar:end);
if ~isempty(firstChar)
    ip=ip(1:firstChar-1);
end

switch length(ip)
    case 1
        ip=cell2mat(ip);
        x=ip(:,1);
        y=ip(:,2);
    case 2
        x=ip{1};
        y=ip{2};
end
% if nargin<2
%     help boundaryPolygon
%     return
% end

% Sort optional arguments / default settings
options=struct;
options.dx=[];
options.dy=[];
options.plot=false;
options.axis=false;
options.closeBoundary=true;
options.polyshape=false;

options=checkArguments(options,varargin);

% Abbreviations:
dx=options.dx;
dy=options.dy;

% Some error checking:
if ~isequal(size(x),size(y))
    error('Mismatch in x,y sizes')
end

% Remove NaNs
k=isnan(x) | isnan(y);
x(k)=[];
y(k)=[];

% If only 2 values passed, use these to generate grid
if length(x)==2
    [x,y]=meshgrid(x,y);
    x=x(:);
    y=y(:);
end

% 20210622 Change to dx,dy - if we specify just one, assume by default the
% other is the same
if ~isempty(dx)
    if isempty(dy)
        dy=dx;
    end
end
if ~isempty(dy)
    if isempty(dx)
        dx=dy;
    end
end
%fprintf('dx = %f; dy= %f\n',dx,dy)

if length(x)==1
    x2Fit=x+[0;0;dx;dx]-dx/2;
    y2Fit=y+[0;dy;dy;0]-dy/2;
else
    % Make sure we've got column vectors:
    x=x(:);
    y=y(:);
    % Get convex hull (used to determine boundary):
    ch=convhull(x,y);
    
    % If we want some extra spacing round our x,y coordinates, add rectangle of
    % size (2*dx, 2*dy) round each point of convex hull.
    if ~dx==0
        x2Fit=[x(ch);x(ch)-dx;x(ch)-dx;x(ch)+dx;x(ch)+dx];
    else
        x2Fit=x(ch);
    end
    if ~dy==0
        y2Fit=[y(ch);y(ch)-dy;y(ch)+dy;y(ch)+dy;y(ch)-dy];
    else
        y2Fit=y(ch);
    end
end
% Remove duplicate points:
xy=[x2Fit,y2Fit];
xy=unique(xy,'rows');
x2Fit=xy(:,1);
y2Fit=xy(:,2);


minx=min(x2Fit);
maxx=max(x2Fit);
miny=min(y2Fit);
maxy=max(y2Fit);
xBoundary=[minx,minx,maxx,maxx,minx];
yBoundary=[miny,maxy,maxy,miny,miny];

xBoundary=xBoundary(:);
yBoundary=yBoundary(:);

if ~options.closeBoundary
    xBoundary(end)=[];
    yBoundary(end)=[];
end

if options.plot
    prepareFigure;
    line(xBoundary,yBoundary,'Color','g','LineWidth',5)
    scatter(x,y,50,'b','filled');
end

if options.axis
    xBoundary=[min(xBoundary),max(xBoundary),min(yBoundary),max(yBoundary)];
    return
end

if options.polyshape
    xBoundary=polyshape(xBoundary,yBoundary);
    return
end

if nargout<2
    xBoundary=[xBoundary,yBoundary];
end

end