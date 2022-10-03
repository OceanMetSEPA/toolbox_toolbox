function [ niceIntervals,dxNice, N ] = prettyIntervals( x,N )
% Get some 'pretty', nicely-spaced intervals covering range of x
%
% It looks for 'N' intervals, but will adjust this accordingly to get
% decent fit. This function can be used e.g. to get nice tick marks for your
% colour bar (axes are handled nicely by matlab already, most of the time).
%
% INPUT:
% x [] - array of numbers
% N [10] - number of intervals to return (roughly)
%
% OUTPUTS:
% niceIntervals: vector of evenly spaced intervals covering range of x
% dxNice: spacing
% N: number of values in niceIntervals vector% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   prettyIntervals.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Oct 07 2015 15:52:56  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help prettyIntervals
    return
end

if ~isnumeric(x)
    error('x should be numeric')
end

if isempty(x)
    error('No values in dataset')
end

x=x(~isnan(x)); % Remove NaNs
x=x(~isinf(abs(x))); % Remove infinite vals

if isempty(x)
    error('No finite values in data set!')
end

if ~exist('N','var')
    N=10;
end
minx=min(x);
maxx=max(x);
if minx==maxx
%    warning('OH:DEAR','Zero range in your data set!')
    niceIntervals=[minx,minx];
    dxNice=0;
    N=2;
    return
end

% Get range of valuse
r=maxx-minx;
dr=r/N; % Spacing of intervals based on 'N'
rExp=floor(log10(dr)); % Find exponent
dre=dr/10^rExp; % and scale interval to between 0 and 10

drChoices=[1,2,5,10]; % Nice intervals to choose from
diffdr=abs(dre-drChoices); % Find differences
dxNice=drChoices(diffdr==min(diffdr)); % And get closest.
if length(dxNice)>1 % more than one match?
    ddr=abs(dxNice-N); 
    dxNice=dxNice(ddr==min(ddr)); % get closest one to input preference
end
dxNice=dxNice*(10^rExp); % OK, scale our nice interval 
% Find multiple of nice interval just below min value
niceMin=dxNice*floor(minx/dxNice);
% And above max value
niceMax=dxNice*ceil(maxx/dxNice);

niceIntervals=niceMin:dxNice:niceMax;
N=length(niceIntervals);

end
