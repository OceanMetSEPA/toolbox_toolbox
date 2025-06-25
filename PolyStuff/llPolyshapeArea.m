function [op,ps]=llPolyshapeArea(varargin)
% Calculate area of polyshape with lat/lon vertices
%
% INPUT:
% polyshape OR x,y coordinates
%
% OUTPUTS:
% area, polyshape with Easting/Northing vertices

switch nargin
    case 0
        help llPolyshapeArea
        return
    case 1 % assume polyshape
        ps=varargin{1};
        vert=ps.Vertices;
        x=vert(:,1);
        y=vert(:,2);
    case 2
        x=varargin{1};
        y=varargin{2};
    otherwise
        error('invalid arguments')
end
[x,y]=OS.catCoordinates(x,y,'from','LL','to','EN');
ps=polyshape(x,y,'simplify',0);
op=ps.area;
end