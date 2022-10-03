function map = rainbow (number)
% Function to generate rainbow colourmap
%
% INPUT: Number of values in colourmap
% 
% OUTPUT: Matrix of colours, where columns correspond to Red, Green, Blue
%
% EXAMPLE:
% N=7; % Number of colours
% colourMap=rainbow(N)
% figure
% hold on
% for i=1:N
%    scatter(i,i,250,colourMap(i,:),'filled')
%end
%
% Nicked from http://www.koders.com/matlab/fidCC0C6FC00B0F7DF0EAD523A13CEDB44E5806C6A8.aspx?s=colormap#L21
% 
% Pass the number of distinct colours you want
% It'll return a colourmap ranging from red to violet
%
% ## this colormap is not part of matlab, it is like the prism
% ## colormap map but with a continuous map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   rainbow.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 08 2014 14:02:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin == 0)
    help rainbow
    return
%    number = rows (colormap);
elseif (nargin == 1)
    if (~isscalar (number))
        error ('rainbow: argument must be a scalar');
    else
%        print_usage ();
    end
    
    if (number == 1)
        map = [1, 0, 0];
    elseif number==3
%        fprintf('Writing RGB!\n')
        map=[1,0,0;0,1,0;0,0,1];
    elseif (number > 1)
        x = linspace (0, 1, number)';
        r = (x < 2/5) + (x >= 2/5 & x < 3/5) .* (-5 * x + 3)+ (x >= 4/5) .* (10/3 * x - 8/3);
        g = (x < 2/5) .* (5/2 * x) + (x >= 2/5 & x < 3/5)+ (x >= 3/5 & x < 4/5) .* (-5 * x + 4);
        b = (x >= 3/5 & x < 4/5) .* (5 * x - 3) + (x >= 4/5);
        map = [r, g, b];
    else
        map = [];
    end
    
end
