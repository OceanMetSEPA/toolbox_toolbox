function op = closestStringMatch(strings2CompareAgainst,string2Test)
% Find which string (in a list of strings) which is most similar to another
% string (or list of strings)
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
%
% 20241106 - rewritten to remove any SEPA dependencies (e.g. stringFinder)

if nargin<2
    help closestStringMatch
    return
end

string2Test=cellstr(string2Test);
N=length(string2Test);
if N>1
    op=cellfun(@(x)closestStringMatch(strings2CompareAgainst,x),string2Test,'unif',0);
    try
        op=vertcat(op{:});
    catch
        % oh well
    end
    return
end
string2Test=char(string2Test);

% 1) exact match
k=strcmp(strings2CompareAgainst,string2Test);

% 2) exact match, except case
if ~any(k)
    k=strcmpi(string2Test,strings2CompareAgainst);
end

% 3) starting the same, case sensitive
if ~any(k)
    k=strncmp(string2Test,strings2CompareAgainst,length(string2Test));
end

% 4) starting the same, case insensitive
if ~any(k)
    k=strncmpi(string2Test,strings2CompareAgainst,length(string2Test));
end

% 5) string2Test present, case sensitive
if ~any(k)
    k=cellfun(@(x)contains(x,string2Test),strings2CompareAgainst);
end

% 6) string2Test present, case insensitive
if ~any(k)
    k=cellfun(@(x)contains(x,string2Test,'ig',1),strings2CompareAgainst);
end

if any(k) 
    op=strings2CompareAgainst(k);
else
    op=[];
end
