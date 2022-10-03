function varargout = prepareFigure( varargin )
% Generate figure for plots
%
% This allows size, title, labels etc to be specified in a single function call
%
% INPUTS (optional arguments):
%
% width (default = 1000) - figure width in pixels
% height (no default - use width and 'golden ratio' to pick nicely proportioned size)
% xOffset (50) - position to right of bottom left of screen
% yOffset (50) - height above bottom of screen 
% closeAll (false) - close other figures prior to generation of current figure
% holdOn   (true) - call matlab 'hold on' command
% LABELS:
% title ('') 
% xlabel ('')
% ylabel ('')
% fontSize (14) - size of above labels
%
% OUTPUT:
% h = handle to figure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   prepareFigure.m  $
% $Revision:   1.4  $
% $Author:   ted.schlicke  $
% $Date:   Feb 11 2016 08:39:44  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phi=(1+sqrt(5))/2; % golden ratio

options=struct;
options.width=1000;
options.height=[];
options.xOffset=50;
options.yOffset=50;
options.closeAll=false;
options.holdOn=true;
options.title='';
options.fontSize=14;
options.xlabel='';
options.ylabel='';
options.zlabel='';
options.visible=true;
options.interpreter='none';
options.h=[];
options.map=[];
options=checkArguments(options,varargin{:});
if isempty(options.height)
    options.height=options.width/phi; % nicely proportioned 
end

if options.visible
    options.visible='on';
else
    options.visible='off';
end

%sort size
set(0,'Units','pixels');
posOnScreen=[options.xOffset,options.yOffset,options.width,options.height];

if options.closeAll
    close all
end

% GENERATE PLOT!
if ~isempty(options.h)
   f=figure(options.h);
   set(f,'Visible',options.visible);    
else
    f=figure('Visible',options.visible);
end
set(f,'Position',posOnScreen);
%set(f,'Visible',options.visible)
if options.holdOn
    hold on
else
    hold off
end

title(options.title,'FontSize',options.fontSize,'Interpreter',options.interpreter)
xlabel(options.xlabel,'FontSize',options.fontSize)
ylabel(options.ylabel,'FontSize',options.fontSize)
if ~isempty(options.zlabel)
    zlabel(options.zlabel,'FontSize',options.fontSize)
end

if ~isempty(options.map)
    map=options.map;
    if numel(map.x)==2
        z=zeros(2);
    else
        z=zeros(size(map.x));
    end
    surf(map.x,map.y,z,map.rgb,'EdgeColor','none','FaceColor','texturemap','CDataMapping','direct')
end

if nargout==1
    varargout{1}=f;
end

end

