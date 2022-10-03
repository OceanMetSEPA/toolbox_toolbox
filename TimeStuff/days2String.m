function [ str ] = days2String( x )
% Given a number of days, provide more meaningful description of duration
% (e.g. seconds, days, years etc)
%
% INPUT:
% numeric value(s) indicating number of days (e.g. difference between 2
% datenums)
%
% OUTPUT:
% strings giving more meaningful description, based on size of value
%
% EXAMPLE:
% then=datenum('01/01/2005')
% days2String(now-then)  % '8.0284 years'
% days2String(0.1) % '2.4 hours'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   days2String.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 08 2014 14:02:48  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('x','var')
    help days2String
    return
end

if ~isnumeric(x)
    error('Input must be numeric')
end


Nx=length(x);
daysPerYear=365;

str=cell(Nx,1);
for i=1:Nx
    xi=x(i);
    if isnan(xi)
        str{i}='NaN';
    elseif xi>daysPerYear
        str{i}=[num2str(xi/daysPerYear),' years'];
    else
        str{i}=[num2str(xi),' days'];
        if xi<1
            xi=xi*24;
            str{i}=[num2str(xi),' hours'];
        end
        if xi<1
            xi=xi*60;
            str{i}=[num2str(xi),' minutes'];
        end
        if xi<1
            xi=xi*60;
            str{i}=[num2str(xi),' seconds'];
        end
    end
    if length(str)==1 % Only one output?
        str=char(str);  % Return as char rather than cell
    end
    
end

