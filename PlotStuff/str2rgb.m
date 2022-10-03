function [ C ] = str2rgb( str )
% Wrapper function for external 'rgb' function which converts colour names
% to RGB values. This also converts matlab's inbuilt abbrevations ('r' =
% red, 'k' = black etc)

if nargin==0
    help str2rgb
    rgb chart
    return
end

if length(str)==1
    % Convert inbuilt matlab codes to RGB:
    % https://stackoverflow.com/questions/4922383/how-can-i-convert-a-color-name-to-a-3-element-rgb-vector
    C = bitget(find('krgybmcw'==str)-1,1:3); % !
else
    C=rgb(str);
end

end

