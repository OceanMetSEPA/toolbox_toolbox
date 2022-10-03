function   underline( varargin )
% Draw line in command window (helps separate output sometimes)
%
% Optional Inputs:
%   'colour' - default = 'k' for black. Can use numbers/letters describing
%              colour as suitable for cprintf function
%   'length' - default = width of command window
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   underline.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Sep 23 2020 16:12:14  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options=struct;
options.length=[];
options.colour='k';
options=checkArguments(options,varargin);

if isempty(options.length)
    windowSize=matlab.desktop.commandwindow.size;
    x=windowSize(1);
else
    x=options.length;
end
str=repmat('_',1,x);
try
    cprintf(options.colour,'%s\n',str)
catch
    fprintf('%s\n',str)
end


end
