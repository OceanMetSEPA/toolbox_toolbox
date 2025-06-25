function varargout=polyshapeIntersection(ps,x,y,varargin)
% Generate polyline of input points including where they cross a polyshape
%
% INPUTS:
% ps - polyshape
% x,y - coordinates of polyline
%
% Optional Inputs:
% minDist [1e-6] - remove duplicate points (within this distace of each
% other)
% inside [false] - only retain points inside polyshape or on boundary
%
% OUTPUT - either:
% *) struct with fields x,y (single output requested)
% *) x,y - coordinates of points (two outputs requested)
%
% (If zero outputs requested, plot polyshape and line)
%
% EXAMPLE:
% % Define polyshape:
% x=[0,0.5,1]
% y=[0,1,0];
% ps=polyshape(x,y)
% % Define polyline:
% x=[-0.1,1];
% y=[0.6,0.3];
% % Find intersection points and plot
% polyshapeIntersection(ps,x,y)

if nargin==0
    help("polyshapeIntersection")
    return
end

options=struct;
options.minDist=1e-6;
options.inside=false;
options=checkArguments(options,varargin);

NSegments=length(x)-1;
% Generate line segments between each input point
k=1:NSegments;
xs=num2cell([x(k),x(k+1)],2);
ys=num2cell([y(k),y(k+1)],2);

%segs=arrayfun(@(i)[xs{i}',ys{i}'],1:N-1,'unif',0);
%[in,out]=cellfun(@(x)intersect(ps,x),segs,'unif',0);
% Not obvious (to me) how to combine in/out!

% For each line segement, find intersection points. Replace single line
% segment with all points found
ca=cell(NSegments);
for segmentIndex=1:NSegments
    %    fprintf('Checking segment %d of %d\n',segmentIndex,NSegments)
    xi=xs{segmentIndex}';
    yi=ys{segmentIndex}';
    seg=[xi,yi];
    [in,out]=intersect(ps,seg);
    insize=size(in,1);
    outsize=size(out,1);
    %     fprintf('in:\n')
    %     disp(in)
    %     fprintf('out:\n')
    %     disp(out)
    %    fprintf('IN SIZE = %d\n',size(in,1))
    if insize>outsize
        v2Check=in;
    else
        v2Check=out;
    end
    v2Check=unique(v2Check,'rows','stable');
    v2Check(isnan(v2Check(:,1)),:)=[];
    kin=ismember(v2Check,seg,'rows');
    xpoint=v2Check(~kin,:);
    xpoint(isnan(xpoint(:,1)),:)=[];
    % NB make sure points are in the right order! (Of increasing distance
    % from first point)
    dist=distanceBetweenPoints(xpoint,[xi(1),yi(1)]);
    [~,k]=sort(dist);
    xpoint=xpoint(k,:);
    if segmentIndex<NSegments
        addthis=[seg(1,:);xpoint];
    else
        %        fprintf('ADD LAST POINT\n')
        addthis=[seg(1,:);xpoint;seg(2,:)];
    end
    ca{segmentIndex}=addthis;
end
ca=vertcat(ca{:});
xi=ca(:,1);
yi=ca(:,2);

% Remove duplicate points
dx=diff(xi);
dy=diff(yi);
dist=sqrt(dx.^2+dy.^2);
k=[true;dist>options.minDist];
xi=xi(k);
yi=yi(k);

% Crop polyline?
if options.inside
    k=ps.isinterior(xi,yi);
    xi=xi(k);
    yi=yi(k);
end

switch nargout
    case 0
        disp(out)
        prepareFigure('close',1)
        plot(ps,'facecolor','b')
        plot(x,y,'-xr','linewidth',3)
        scatter(x,y,500,'r','filled')
        axis equal
        scatter(xi,yi,100,'c','filled')
    case 1
        varargout{1}=struct('x',xi,'y',yi);
    case 2
        varargout{1}=xi;
        varargout{2}=yi;
    otherwise
        error('too many outputs')
end
end
