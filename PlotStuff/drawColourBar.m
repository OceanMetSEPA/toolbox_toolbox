function varargout=drawColourBar(cm,ticks,varargin)
% wrapper function for matlab's colorbar function
%
% This function draws a colorbar, generating equally-spaced ticks and labels, 
% and updates its colormap
%
% INPUTS:
% cm - colormap of size [NColours,3]
% ticks - either values or labels
%
% Optional inputs:
% fontSize [12] - size of tick labels
% prefix ['>'] - tick labels start with this
%
% OUTPUT:
% cb - handle of colorbar
%

if nargin<2
    ticks=size(cm,1);
end

options=struct;
options.fontSize=12;
options.prefix='>';
options=checkArguments(options,varargin);

if isnumeric(ticks)
    if ~isscalar(ticks) % Multiple values? Use these as tick labels
        NTicks=length(ticks);
        tickLabels=arrayfun(@(i)sprintf('%s %s',options.prefix,num2str(ticks(i))),1:NTicks,'unif',0);
    else % single value? Assume this is number of ticks required
        NTicks=ticks;
        tickLabels=arrayfun(@num2str,1:NTicks,'unif',0);
    end
elseif iscellstr(ticks) || isstring(ticks) % tick labels passed to function?
    NTicks=length(ticks);
    tickLabels=ticks;
else
    error('Expected number of ticks or tick labels as input')
end

% Space out ticks evenly along colorbar:
dtick=(NTicks-1)/NTicks;
yticks=1+dtick/2:dtick:NTicks;

% Now generate color bar
cb=colorbar;
set(cb,'ytick',yticks);
set(cb,'yticklabel',tickLabels);
set(cb,'ylim',[1,NTicks]);
set(cb,'fontsize',options.fontSize)

% Set colormap of bar to specified colours:
colormap(cm)
% Set colour range to match ticks (by default it's [0,1]:
clim([1,NTicks])

switch nargout
    case 0
    case 1
        varargout{1}=cb;
    otherwise
        error('too many outputs')
end

end
