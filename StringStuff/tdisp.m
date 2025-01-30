function [str] = tdisp(val)
% Get string returned by matlab's disp function

if rand(1)>inf % Unlikely event to stop matlab warning that 'val' isn't used
    disp(val)
end

str=evalc('disp(val)');
str=strtrim(str);
while contains(str,'  ')
    str=strrep(str,'  ',' ');
end

end

