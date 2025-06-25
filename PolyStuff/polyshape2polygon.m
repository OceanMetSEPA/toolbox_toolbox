function [x,y] = polyshape2polygon(ps)
% Get x,y vertices of polyshape(s), separated by nans
%
% INPUT:
% ps - polyshape(s)
% 
% OUTPUTS:
% x,y - coordinates of polyshape vertices, separated by nans
%
v={ps.Vertices};
x=cellfun(@(x)x(:,1),v,'unif',0);
if length(x)==1
    x=x{:};
else
    x=joinby(x,nan);
end
y=cellfun(@(x)x(:,2),v,'unif',0);
if length(y)==1
    y=y{:};
else    
    y=joinby(y,nan);
end


