function [ varargout ] = splitStringByEqualsSign( str,varargin )
% Split string(s) containing '=', creating parameter and value pairs
%
% This function splits string(s) by the '=' character. String sections to
% the left of the '=' are interpreted as the parameter, and those to the
% right of the '=' are interpreted as the value. Strings without a single '=' are ignored.
%
% INPUT:
% char/cell array of strings
%
% Optional input:
% minAsciiValue [40] - ignore characters whose ascii value is less than
% this (to ignore spaces, special characters etc)
% numeric (true) - attempt to convert value from string to numeric
%
% OUTPUT:
% If single output requested, output is a struct with:
%    fieldnames : strings at left of '=' (passed through genvarname)
%    values : strings/numbers at right of '='
%
% If two outputs requested, they are:
%    parameters (LHS of =) and
%    values (RHS of =) respectively
%
% EXAMPLE:
% str={'fish=3.14159','phi=1.618','seq=1,2,3,4,5','me=frog','test==ignore','abcde','sum=3+4'};
% splitStringByEqualsSign(str)
% ans =
%     fish: 3.14159
%      phi: 1.618
%      seq: [1 2 3 4 5]
%       me: 'frog'
%      sum: 7
%
% This function was written to extract large number of parameters from model
% specification file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   splitStringByEqualsSign.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   Sep 09 2020 10:41:24  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help splitStringByEqualsSign
    return
end

options=struct;
options.minAsciiValue=33;
options.numeric=true;
options=checkArguments(options,varargin);

if ischar(str)
    str=cellstr(str);
end
% If it's a file...
if isfile(str)
    % Load it in
    str=readTxtFile(str);
end
if ~iscellstr(str)
    error('Input should be chars / cells containing chars')
end

% Convert to ascii integers
ascii=cellfun(@uint8,str,'unif',0);
% Count number of equal signs
numberOfEqualSigns=cellfun(@(x)sum(x==61),ascii); % 61 is ascii for '='
% Retain entries with single equal sign
ascii=ascii(numberOfEqualSigns==1);

% Remove unwanted ascii values (space, tabs etc):
ascii=cellfun(@(x)x(x>=options.minAsciiValue),ascii,'unif',0);
% Convert back to cellstr
str=cellfun(@char,ascii,'unif',0);

if isempty(str)
    %    warning('No strings containing single ''='' found')
    varargout{1}=[];
    return
end

% Split strings by '=':
str=regexp(str,'=','split');
str=vertcat(str{:});
% Extract parameters (LHS of =) and values (RHS of =)
parameters=str(:,1);
values=str(:,2);
N=length(parameters);

% Convert to numeric?
if options.numeric
    for i=1:N
        ivalue=values{i};
        if strcmpi(ivalue,'NaN')
            values{i}=NaN;
        else
            % use str2num rather than str2double, even though it's slower
            % (str2double interprets commas as thousands separator, rather
            % than an indicator of separate values. This messes up e.g. datevecs)
            try
                numericValue=str2num(ivalue); % warning: str2num is slower than str2num
                if ~any(isnan(numericValue)) && ~all(isempty(numericValue))
                    values{i}=numericValue;
                end
            catch
                % isname(template) fails when splitting NewDepomod template files
            end
        end
    end
end

if nargout<2
    s=struct;
    for i=1:N
        fn=genvarname(parameters{i});
        s.(fn)=values{i};
    end
    varargout{1}=s;
elseif nargout==2
    varargout{1}=parameters;
    varargout{2}=values;
end

end
