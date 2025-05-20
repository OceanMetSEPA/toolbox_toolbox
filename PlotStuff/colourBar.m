%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function  to display colour bar for sea lice plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cb=colourBar(cm,bands)
% Colorbar - my function drawColourBar doesn't produce nicely spaced tick labels :-(
% - but this does:
NBands=length(bands);
bandIndices=1:NBands;
labels=arrayfun(@(i)sprintf('>%.2f',bands(i)),bandIndices,'unif',0);
%labels=arrayfun(@(i)sprintf('>10^{%d}',bands(i)),bandIndices,'unif',0);
%labels{1}='=0';
% See https://uk.mathworks.com/matlabcentral/answers/102056-how-can-i-make-the-ticks-in-the-colorbar-appear-at-the-center-of-each-color-in-matlab-7-0-r14
%ticks=1+0.5*(NBands-1)/NBands:(NBands-1)/NBands:NBands;
dtick=(NBands-1)/NBands;
ticks=1+dtick/2:dtick:NBands;

colormap(cm)
clim([1,NBands]);
%cb=drawColourBar(cm,ticks,'labels',labels,'caxis',[1,NBands]); % FIX THIS!
cb=colorbar('ytick',ticks,'yticklabel',labels,'ylim',[1,NBands],'fontsize',14);
%set(cb,'ytick',[])
colormap(cm)
end
