function dist=llDist(x,y,ll)
% Calculate the (euclidian) distance (in meters) between lat/lon points
%
% INPUTS:
% x - longitude
% y - latitude
% 
% Optional Input:
% ll [true] - convert lat/lon to easting/northing
%
% OUTPUT:
% dist - Euclidean distance between points
%
% NB this function applicable for small distances i.e. where Earth can be
% considered flat. For larger distances, use greatCircleDistance which
% assumes earth is a sphere.

if nargin<3
    ll=true;
end
if ll
    [x,y]=OS.catCoordinates(x,y);
end
dx=diff(x);
dy=diff(y);
dist=sqrt(dx.^2+dy.^2);
end

