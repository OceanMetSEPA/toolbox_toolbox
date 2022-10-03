function varargout = datenumDescription( t ,dateFormat)
% Provide description of sequence of datenums
%
% INPUT:
% t: array of datenums
%
% Optional Input:
% dateFormat (dd/mm/yyyy HH:MM) - argument for datestr function
%
% OUTPUT:
% str: description of datenum sequence (min, max, time separation, number of values)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   datenumDescription.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Jun 06 2016 14:32:54  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help datenumDescription
    return
end

if ~isnumeric(t)
    error('Function requires numeric argument')
end

if ~exist('dateFormat','var')
    dateFormat='dd/mm/yyyy HH:MM:SS';
end

t=sort(t);
Nt=length(t);
t0=datestr(t(1),dateFormat);
t1=datestr(t(end),dateFormat);
spd=24*60*60; % seconds per day

% Just one value? Display date string
if length(t)==1
    str=sprintf('Single datenum = %s',t0);
else
    % More than one value? Then find unique time separations (to nearest
    % second)
    dt=round(diff(t)*spd)/spd;
    dtUnique=unique(dt);   
    if length(dtUnique)==1 % Uniformly spaced
        str=sprintf('%% %d values; %s -> %s; time sep = %s',Nt,t0,t1,days2String(dtUnique));
    else % Unequal time separation
        str=sprintf('%% %d values; %s -> %s\n',Nt,t0,t1);
        str=sprintf('%sMean time separation = %s; ranges from %s to %s',str,days2String(mean(dt)),days2String(min(dt)),days2String(max(dt)));
    end
end
if nargout==0
    disp(str)
elseif nargout==1
    varargout{1}=str;
else
    error('Too many outputs requested')
end

end
