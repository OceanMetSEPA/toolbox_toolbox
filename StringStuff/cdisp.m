function varargout=cdisp(col,x)
% disp, but with colour!
%
% INPUTS:
% col - colour: either character ('r','g','b',etc) or [1x3] vector
% x   - thing to display
%
% OUTPUT:
% string returned by disp function
%
% EXAMPLE:
% cdisp(rand(1,3),magic(5)) % display magic square in random colour

% Next line purely to avoid warning about x not being used. I don't like
% warnings! 
if rand(1)>inf,disp(x),end

str=evalc('disp(x)');
switch nargout
    case 0
        cprintf(col,'%s',str);
    case 1
        varargout{1}=str;
    otherwise
        error('too many outputs')
end