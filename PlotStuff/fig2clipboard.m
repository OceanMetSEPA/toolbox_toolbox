function fig2clipboard(figHandle,varargin)
% Copy figure to clipboard for (e.g.) pasting into word
%
% (saves having to go Edit -> Copy Figure;
%  copygraphics does this in matlab post 2020...)
%
% INPUTS:
%  figHandle - if not passed, use gcf
% 
% Optional Inputs:
% background [true] - include grey border around figure
% xsize [] - if not empty, resize figure to this width
% ysize [] - if not empty, resize figure to this height
%
% (If only one xsize,ysize passed, keep original aspect ratio)
%
%
% EXAMPLES:
% fig2clipboard(gcf)
% fig2clipboard()
% fig2clipboard('background',0) %

if nargin==0
    figHandle=gcf;
elseif ischar(figHandle)
    varargin={figHandle,varargin{:}};
    figHandle=gcf;
end
options=struct;
options.background=true;
options.xsize=[];
options.ysize=[];
options=checkArguments(options,varargin);

% Pos stuff
pos=get(figHandle,'position');
x=options.xsize;
y=options.ysize;
resize=~isempty(x) || ~isempty(y);
if resize
    % If we haven't specified both x,y sizes, keep original aspect ratio:
    ar=pos(3)/pos(4);    
    if isempty(y)
        y=x/ar;
    elseif isempty(x)
        x=y*ar;
    end       
    pos(3)=x;
    pos(4)=y;
    set(figHandle,'position',pos)
end
set(figHandle,'inverthardcopy',onOrOff(~options.background))
% -r0 means screen resolution (default not sufficient)
print(figHandle,'-dmeta','-r0');


