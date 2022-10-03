function [d,ind]=distanceBetweenPoints(varargin)
% calculate Euclidean distance between sets of points
%
% If optional argument (max,min) supplied, results filtered and index
% returned
%
% INPUT: (various options)
% * x1,y1,x2,y2
% * [x1,y1],[x2,y2]
% * x1,y1,z1,x2,y2,z2
% * [x1,y1,z1],[x2,y2,z2]
%
%  (N1 = length of x1; N2 = length of x2)
%
% Optional input
% 'min','max'
%
% OUTPUT:
% [N1,N2] array containing distance between input points
% index [] - empty unless min/max specified, in which case this contains
% indices of x1,y1,z1
%
% OPTIONAL INPUTS
% 'min' - return minimum distance, and indices of points where distance == min(distance)
% 'max' - return maximum distance, and indices of points where distance == max(distance)
% 'nmin' - return minimum distance >0, and indices of points where distance == min(distance)
%
% Specifying one of the above reduces the output matrix size to [Np,1]
%
% If input points swapped about, output = reshape(output',fliplr(size(output)))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   distanceBetweenPoints.m  $
% $Revision:   1.2  $
% $Author:   Ted.Schlicke  $
% $Date:   Jul 04 2018 11:48:18  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help distanceBetweenPoints
    return
end

% Process input arguments
k=find(cellfun(@ischar,varargin));
if isempty(k) % any characters? (Looking for min/max)
    vals=varargin; % no characters, so assume all inputs correspond to point data
    varargin=[];
else % some characters
    vals=varargin(1:(k-1)); % assume these correspond to point data
    varargin(1:(k-1))=[]; % remove these from varargin
end
% Ok, now process input arguments. Point data may be bundled up, or split
% into separate inputs
NVals=length(vals);
if NVals==2 % matrix
    xyz1=vals{1};
    xyz2=vals{2};
    if isvector(xyz1)
        xyz1=reshape(xyz1,1,[]);
    end
    if isvector(xyz2)
        xyz2=reshape(xyz2,1,[]);
    end
    x1=xyz1(:,1);
    y1=xyz1(:,2);
    x2=xyz2(:,1);
    y2=xyz2(:,2);
    if size(xyz1,2)==3
        z1=xyz1(:,3);
        z2=xyz2(:,3);
    else
        z1=zeros(size(x1));
        z2=zeros(size(x2));
    end
elseif NVals==4 % x1,y1,x2,y2
    x1=vals{1};
    y1=vals{2};
    z1=zeros(size(x1));
    x2=vals{3};
    y2=vals{4};
    z2=zeros(size(x2));
elseif NVals==6 % x1,y1,z1,x2,y2,z2
    x1=vals{1};
    y1=vals{2};
    z1=vals{3};
    x2=vals{4};
    y2=vals{5};
    z2=vals{6};
else
    error('Invalid number of inputs')
end
% Convert all to columns:
x1=x1(:);
y1=y1(:);
z1=z1(:);
x2=x2(:);
y2=y2(:);
z2=z2(:);

% Now check for min/max:
if ~isempty(varargin)
    %    disp(varargin)
    stringOptions={'min','max','nmin'};
    arg1=varargin{1};
    if ~ischar(arg1)
        disp(arg1)
        error('Optional argument should be char')
    end
    %    minOrMaxOption=char(stringFinder(stringOptions,varargin{1}));
    minOrMaxOption=closestStringMatch(stringOptions,varargin{1});
    switch length(minOrMaxOption)
        case 0
            disp(stringOptions)
            error('Optional argument should be one of the above')
        case 1
            minOrMaxOption=char(minOrMaxOption);
        otherwise
            %            disp(minOrMaxOption)
            %            error('Ambiguous!')
            minOrMaxOption='';
    end
else
    minOrMaxOption='';
end

Np=length(x1);
if Np>1 % Recursive call of this function. Need to output cells since more than one output possible
    [d,ind]=arrayfun(@(i)distanceBetweenPoints(x1(i),y1(i),z1(i),x2,y2,z2,minOrMaxOption),1:Np,'unif',0);
    try % to convert cells to numbers
        d=horzcat(d{:})';
    catch
    end
    indSize=cellfun(@length,ind);
    if all(indSize==1) % one index per point?
        ind=vertcat(ind{:}); % convert to matrix from cell
    end
    %     prepareFigure('close',1)
    %     scatterRainbow(x1,y1,20);
    %     plot(x1,y1)
    %     scatter(x2,y2,30,'k','filled')
    return
end

% Calculate euclidean distance:
d=sqrt((x1-x2).^2+(y1-y2).^2+(z1-z2).^2);
ind=[];
switch minOrMaxOption
    case 'min'
        minDist=min(d);
        ind=find(d==minDist);
        d=minDist;
    case 'max'
        maxDist=max(d);
        ind=find(d==maxDist);
        d=maxDist;
    case 'nmin'
        nmin=min(d(d>0));
        ind=find(d==nmin);
        d=nmin;
    otherwise
        %        error('Invalid distance option')
end

end