function [op] = getContourStruct(c,combineContours)
% Convert matrix returned by 'contour' and 'tricontour' to struct for further manipulation
%
% Matrix has 2 rows with format:
% C x1 x2 x3...
% N y1 y2 y3...
% Where C is a contour band and N is the number of values in the polygon
% x,y are the contour coordinates
%
% There may be multiple values of the same 'C' for contours with separate
% sections. The second, optional argument 'combineContours' combines these
%
% INPUTS:
% c - matrix returned by contour / tricontour
% Optional Input:
% combineContours (true)- combine multiple contours at same level,
% separated by nan
%
% OUTPUT:
% struct array with fields:
%   contour: value to which contour corresponds
%   x: x coordinates of contour
%   y: y coordinates of contour
%
if nargin==0
    help getContourStruct
    return
end

if isempty(c)
    error('Contour matrix is empty!') 
end

if ~exist('combineContours','var')
    combineContours=1;
end

% Step 1: extract individual contour polygons
Np=size(c,2);
contourPolygons=cell(Np,1);
counter=1;
while ~isempty(c)
    contourValue=c(1,1);
    contourLength=c(2,1);
    k=2:contourLength+1;
    s=struct('contour',contourValue,'x',c(1,k),'y',c(2,k));
    contourPolygons{counter}=s;
    c(:,1:max(k))=[];
    counter=counter+1;
end
contourPolygons=vertcat(contourPolygons{:});
% Step 2:
% Combine structs with a common contour boundary
contourValues=[contourPolygons.contour];
contourBands=contourValues;
if combineContours
    contourBands=unique(contourValues);
end

Nuc=length(contourBands);

contourStruct=cell(Nuc,1);
for contourIndex=1:Nuc
    icontour=contourBands(contourIndex);
%    fprintf('Sorting contour %d of %d (%f)\n',contourIndex,Nuc,icontour)
    if combineContours
        k=icontour==contourValues;
        si=contourPolygons(k);
    else
        si=contourPolygons(contourIndex);
    end
    if length(si)>1
        x=joinby({si.x},nan)';
        y=joinby({si.y},nan)';
    else
        x=si.x;
        y=si.y;
    end
    
    contourStruct{contourIndex}=struct('contour',icontour,'x',x,'y',y);
end
op=vertcat(contourStruct{:});
end

