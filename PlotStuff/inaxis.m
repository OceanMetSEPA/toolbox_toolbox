function k=inaxis(x,y,ax)
% Determine if point(s) are within axis of plot
% INPUT:
% x,y : coordinates to test
% ax : [1 4] axis vector
%
% OUTPUT:
% k : boolean values indicating whether points are within current axis
%
if nargin<3
    ax=axis;
end
[xb,yb]=axis2polygon(ax);
k=inpolygon(x,y,xb,yb);