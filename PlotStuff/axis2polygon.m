function [x,y]=axis2polygon(ax,closeLoop)
% Convert axis (1x4 vector) to polygon
% (Useful for testing if a location is within figure axis)
switch nargin
    case 0
        help(axis2polygon)
    case 1
        closeLoop=true;
end

x0=ax(1);
x1=ax(2);
y0=ax(3);
y1=ax(4);

if closeLoop
    xend=x0;
    yend=y0;
else
    xend=[];
    yend=[];
end

x=[x0,x0,x1,x1,xend];
y=[y0,y1,y1,y0,yend];
