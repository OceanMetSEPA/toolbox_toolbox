function datetimeAxis(ax)
% Add date/time ticks to time-series plot
% 
% This has a call-back function so plot is updated when user zooms/pans. 
% It seems to work with subplots, unlike adjustAxes
%
if nargin==0 % didn't pass this function any axes handles?
    % then apply timeaxis function to all axes.
    h=get(0,'CurrentFigure');
    ax = findobj(h,'type','axes','-not','Tag','legend','-not','Tag','Colorbar'); % handles for axes
end

dateFormat='dd mmm yyyy';

arrayfun(@(x)mypostcallback([],[],x,dateFormat),ax)
set(zoom(gcf),'ActionPostCallback',{@mypostcallback,ax,dateFormat});
set(pan(gcf),'ActionPostCallback',{@mypostcallback,ax,dateFormat});

    function mypostcallback(~,~,ax,dateFormat)
        % Sort out format to use.
        % If we've got s short time range:
        if diff(xlim)<3
            % Add time to date
            dateTimeFormat=[dateFormat,' HH:MM'];
        else % just use date
            dateTimeFormat=dateFormat;
        end
        %         Check years of xlim:
        [y,~]=datevec(xlim);
        uy=unique(y);
        % if all the same year, don't need year in each tick
        if length(uy)==1
            lab=num2str(uy);
            
            dateTimeFormat=strrep(dateTimeFormat,' yyyy','');
        else
            lab='';
        end
        % Add label (= year if all data within single year; empty
        % otherwise):
        arrayfun(@(x)xlabel(x,lab,'fontsize',get(x,'fontsize')),ax);
        % Call datetick function - whole point of this function! 
        arrayfun(@(x)datetick(x,'x',dateTimeFormat,'keeplimits'),ax)
    end
end