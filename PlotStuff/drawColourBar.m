function cb=drawColourBar(cm,ticks,varargin)
% COLORBAR with custom ticks
% TO DO: Write more help!

options=struct;
%options.format='%d.3g%s';
options.format='%d';
options.labels=[];
options.fontSize=14;
options.location='EastOutside'; % TO DO- check this is valid location
options=checkArguments(options,varargin);

colormap(cm);
cb=colorbar('Location',options.location,'units','pixels','FontSize',options.fontSize);

if(~exist('ticks','var'))
    ticks=get(cb,'YTick');
end

if isempty(options.labels)
    tickLabels={length(ticks)};
    for ticki=1:length(ticks)
        tickLabels{ticki}=sprintf(options.format,ticks(ticki));
    end
end

% Some tinkering
tickPositions=ticks;
set(cb,'ytick',tickPositions)
set(cb,'yticklabel',tickLabels)
yrange=[min(ticks),max(ticks)];
set(cb,'ylim',yrange)
set(cb,'Limits',yrange)
caxis([min(ticks),max(ticks)])

return


end



