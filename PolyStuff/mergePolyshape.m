function ps=mergePolyshape(ps)
% Combine multiple polyshapes into single polyshape
%
% INPUT:
% ps - polyshapes to combine
% 
% OUTPUT:
% ps - merged polyshapes (vertices of individual polyshapes joined with
% nans)
% 
% Not sure why we need this- I'd have thought we could just use the union
% function to join all the polyshapes. But it's hugely slow for some
% reason...
%
% ps=[geostuff.WSPZ_Consolidated.Polyshape];
% mergePolyshape(ps) % 15s
% union(ps) % > 2 hours?!
%

Npz=length(ps);
if Npz>1
    vert={ps.Vertices};
    x=joinby(cellfun(@(x)x(:,1),vert,'unif',0),nan);
    y=joinby(cellfun(@(x)x(:,2),vert,'unif',0),nan);
else
    x=ps.Vertices(:,1);
    y=ps.Vertices(:,2);
end
ps=polyshape(x,y,'simplify',0);
