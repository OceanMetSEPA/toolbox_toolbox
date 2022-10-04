function area=axisArea(ax)
% Given 1x4 vector (as used to set figure axis), calculate area
% INPUT:
% ax - [1 4] vector as returned by matlab's axis function
%
% OUPUT:
% area of axis
%
x0=ax(1);
x1=ax(2);
y0=ax(3);
y1=ax(4);
dx=x1-x0;
dy=y1-y0;
area=dx*dy;