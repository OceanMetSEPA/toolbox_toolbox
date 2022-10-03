function op=onOrOff(val)
% Return 'on' for true input; 'off' for false
%
% Matlab plot handles don't use logical values for the 'Visible' option for
% some reason; instead they require strings 'on' or 'off'. This trivial function
% designed to save a bit of typing if we require to switch visibility
% 
% INPUT: scalar value
% 
% OUTPUT: 'on'/'off' string
% 
% EXAMPLE: 
% onOrOff(1);
%
% EXAMPLE USAGE:
% f=figure
% shouldWePlot=false;
% set(f,'Visible',onOrOff(shouldWePlot))
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   onOrOff.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Oct 01 2015 13:28:32  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    help onOrOff
    return
end

if ~isscalar(val)
    error('Scalar input required')
end

if val
    op='on';
else
    op='off';
end
end