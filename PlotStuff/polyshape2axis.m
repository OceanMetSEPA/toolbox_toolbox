function ax=polyshape2axis(ps,buff)
% For polyshape (or array thereof), find axis for tight plotting
% Note that there is a boundary method in polyshape, but that still needs
% to be tinkered with to get what we want. Here we just work with vertices.
% INPUT:
%   ps - matlab polyshape
% Optional input:
%   buff - apply this buffer to polyshape before determining axis
% OUTPUT:
% [1x4] array

if nargin==2
    ps=polybuffer(ps,buff);
end

vertices=vertcat(ps.Vertices);
x=vertices(:,1);
y=vertices(:,2);
ax=[min(x),max(x),min(y),max(y)];

