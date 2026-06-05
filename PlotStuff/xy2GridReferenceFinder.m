function url = xy2GridReferenceFinder(varargin)
% Generate a URL for gridreferencefinder from input coordinates
%
% INPUTS:
% x - longitude OR easting
% y - latitude  OR northing
%
% Can be entered as either:
% *) x,y
% *) [x,y]
% *) as fields of struct/table
% 
% Optional input for labelling points
% *) xy2GridReferenceFinder(x,y,label)
% *) label as field in struct/table input
%
% OUTPUT:
% url - generated web address
%
% Note- if function called with no inputs, a random point is generated and
% plotted

label=[];

switch nargin
    case 0 % for fun, genarate random point on globe
        fprintf('Generating random point!\n')
        x=360*(rand(1)-0.5);
        y=180*(rand(1)-0.5);
        label='Somewhere on earth';
    case 1 %
        arg=varargin{1};
        if isstruct(arg) || istable(arg)
            try
                x=arg.x;
                y=arg.y;
            catch
                error('struct input should have fields x,y')
            end
            try % to read label from struct / table
                label=arg.label;
            catch
            end
        elseif isnumeric(arg)
            try
                x=arg(:,1);
                y=arg(:,2);
            catch
                error('Numeric input should have 2 columns for x,y')
            end
        else
            error('Input should be struct or array')
        end
    otherwise
        x=varargin{1};
        y=varargin{2};
end
if ~isequal(size(x),size(y))
    error('x,y must be same size')
end
x=x(:);
y=y(:);
Np=length(x);

if isempty(label)
    if nargin>2
        label=varargin{3};
    else
        label = arrayfun(@(i) sprintf('Point_%d', i), 1:Np, 'uni', 0);
    end
end
label=string(label);

% -------------------------
% Coordinate handling
% -------------------------
% If looks like EN → convert to lat/lon
if all(x > 180) && all(y > 90)
    [x, y] = OS.catCoordinates(x, y);
end

% -------------------------
% Build URL fragment
% Format: lat|lon|name|1
% -------------------------
pointString = arrayfun(@(i) sprintf('%f|%f|%s|1,', y(i), x(i), label(i)),1:Np,'uni', 0);

pointString = strcat(pointString{:});
pointString(end) = [];   % remove trailing comma

url = ['https://gridreferencefinder.com/#ll=' pointString];

% Open in browser (below only works for Windows)
system(['start "" "' url '"']);

end
