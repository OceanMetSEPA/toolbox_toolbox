function m = closestStringMatch(strings2CompareAgainst,string2Test)
% Find which string (in a list of strings) which is most similar to another
% string
%
% function [ m ] = closestStringMatch(strings2CompareAgainst,string2Test)
%
% To select the match, it tests for a comparison of the strings in the following order:
% 1) exact match
% 2) exact match, except case
% 3) starting the same, case sensitive
% 4) starting the same, case insensitive
% 5) string2Test present, case sensitive
% 6) string2Test present, case insensitive
%
% The purpose of this is to save us a bit of typing when selecting options.
%
% *******************************************************************
% INPUTS: 
% strings2CompareAgainst - list of strings (cell array)
% string2Test            - string to compare with our list above
%
% *******************************************************************
% OUTPUT:
% closest matching string, if found; otherwise []
%
% ********************************************************************
% EXAMPLE:
%
% s2c={'Actual saturation percentage O2',...
%      'depth from water surface to bottom of segment''depth of segment',...
%      'dissolved oxygen concentration',...
%      'horizontal flow velocity',...
%      'horizontal surface area of a DELWAQ segment',...
%      'rate constant for reaeration',...
%      'saturation concentration',...
%      'total depth water column',...
%      'Ammonium (NH4)',...
%      'Water Temperature',...
%      'Dissolved Oxygen',...
%      'carbonaceous BOD (first pool) at 5 days'}
%
% closestStringMatch(s2c,'oxygen')  % returns 'dissolved oxygen concentration'
% closestStringMatch(s2c,'Oxygen') % returns 'Dissolved Oxygen'
% closestStringMatch(s2c,'hor') % returns two strings starting 'horizontal'
% closestStringMatch(s2c,'fish') % returns []
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   closestStringMatch.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 08 2014 14:02:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(nargin==0) 
    help closestStringMatch
    return
end

% first up, try exact match
m=stringFinder(strings2CompareAgainst,string2Test,'type','exact');
if(~isempty(m))
    return
end
% Now try exact match ignoring case...
m=stringFinder(strings2CompareAgainst,string2Test,'type','exact','ig',1);
if(~isempty(m))
    return
end
% try matching start of string, case sensitive
m=stringFinder(strings2CompareAgainst,string2Test,'type','start');
if(~isempty(m))
    return
end

% try matching start of string, case insensitive
m=stringFinder(strings2CompareAgainst,string2Test,'type','start','ignorecase',true);
if(~isempty(m))
    return
end

% try finding string within strings2CompareAgainst, case sensitive
m=stringFinder(strings2CompareAgainst,string2Test,'type','or');
if(~isempty(m))
    return
end

% try finding string within strings2CompareAgainst, case insensitive
m=stringFinder(strings2CompareAgainst,string2Test,'type','or','ignorecase',true);
if(~isempty(m))
    return
end

if(isempty(m))
%    warning('Didn''t find a matching string for ''%s''',string2Test)
    m=[];
end

end

