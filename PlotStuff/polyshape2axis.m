function ax=polyshape2axis(ps)
% For polyshape (or array thereof), find axis for tight plotting
% Note that there is a boundary method in polyshape, but that still needs
% to be tinkered with to get what we want. Here we just work with vertices.
% INPUT:
% polyshape(s)
% OUTPUT:
% [1x4] array
vertices=vertcat(ps.Vertices);
x=vertices(:,1);
y=vertices(:,2);
ax=[min(x),max(x),min(y),max(y)];

