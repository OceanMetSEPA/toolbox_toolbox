function id=whichPolyshape(x,y,ps,varargin)
% Find which polyshape (if any) contains coordinates x,y
%
% INPUTS:
% x - longitude coordinate
% y - latitude coordinate
% ps - array of polyshapes, or struct array with Polyshape field
%
% Optional inputs:
% closest [false] - if point outwith ps, find closest
% maxArea [true] - if point within multiple ps, return largest
% inpolygon [true] - use inpolygon function rather than isinterior
%
% OUTPUT:
% id - index of wspz struct, or false if coordinates outside
%
% EXAMPLE: find water body of every cell in model domain
% id=whichPolyshape(meshInfo.x,meshInfo.y,wspz); % takes ~ 4 minutes
%
% Notes:
% This is a consolidated version of several functions for identifying which
% polyshape/polygon contains one or more points. It is used extensively for
% encoding the fish tracks, identifying which WSPZ each track passes
% through and the water body where it ends up.
% * The maxArea option was adopted for track end points, which are intended
% to straddle two water bodies. The larger of these is likely to be the
% offshore water body where the track ends up, so this option set to true
% by default.
% * closest - some points may be (slightly) outwith WSPZ (e.g. the starting
% points defined in terms of rivers). Setting closest==true returns the
% nearest polyshape rather than nan.
% * inpolygon - points were originally tested against polygons using
% inpolygon function. While it would appear to make more sense to use
% isinterior function for polyshapes, this results in the occasional
% discrepancy. Set inpolygon=true to use inpolygon rather than isinterior
% for backward compatability with track description.
%
options=struct;
options.closest=false;
options.maxArea=true;
options.inpolygon=true;
options=checkArguments(options,varargin);


if isstruct(ps)
    if ~isfield(ps,'Polyshape')
        error('Struct input must have Polyshape field')
    end
    ps=[ps.Polyshape];
end

Nx=length(x);
% If multiple x,y points to test, call function recursively
if Nx>1
    id=arrayfun(@(i)whichPolyshape(x(i),y(i),ps,varargin),1:Nx,'unif',0)';
    try
        id=vertcat(id{:});
    catch err
        disp(err)
    end
    return
end

Nps=length(ps);
% Check whether point in any of the polygons
%
% NB for some polyshapes, get different results for
% isinterior(ps,x,y) and
% inpolygon(x,y,ps.Vertices(:,1),ps.Vertices(:,2));
%
% According to ChatGPT:
% **isinterior(polyshape, x, y)** checks if the point is inside or on the edge of a properly
%  constructed polygon, including holes, overlapping regions, and ensuring correct winding, etc.
% **inpolygon(x, y, xp, yp)** checks if the point is inside/on a simple polygon defined
%  by its vertex list only — it does not handle:
%   * holes
%   * self-intersections
%   * overlapping boundaries
%   * multiple disjoint regions
%
% So if ps is a complex polyshape (with holes, multiple regions, or self-intersections), its
% .Vertices list does not necessarily represent a valid input for inpolygon in the way you expect.
%
% However, track names originally based on inpolygon function. To ensure backwards
% compatability, use:

if options.inpolygon
    % id=find(arrayfun(@(i)inpolygonPolyshape(ps(i),x,y),1:Nps));
    id=find(arrayfun(@(i)inpolygon(x,y,ps(i).Vertices(:,1),ps(i).Vertices(:,2)),1:Nps));
else
    id=find(arrayfun(@(i)isinterior(ps(i),x,y),1:Nps));
end
% How many polyshapes contain point?
switch length(id)
    case 0
        if options.closest
            % Find closest polyshape (should maybe use nearestvertex
            % property?)
            dist=arrayfun(@(i)distanceBetweenPoints(x,y,ps(i).Vertices(:,1),ps(i).Vertices(:,2),'min'),1:Nps);
            id=find(dist==min(dist));
        else
            id=nan;
        end
    case 1
        % default - single value
    otherwise
        % Multiple matches!
        if options.maxArea % find containing polyshape with max area
            psArea=arrayfun(@(i)area(ps(i)),id);
            k=psArea==max(psArea);
            id=id(k);
        end
end
