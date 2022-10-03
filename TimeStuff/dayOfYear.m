function [ doy ] = dayOfYear( dates )
% Find number of days of specified dates since January 1st of that year
%
% INPUT: 
% dates (datenums)
% 
% OUTPUT:
% integers corresponding to day of year
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   dayOfYear.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Feb 27 2018 14:29:32  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    dates=now;
end

dates=dates(:); % column vector
[y,~]=datevec(dates);
jan1=datenum(y,1,1);
doy=floor(dates)-jan1+1;

end
