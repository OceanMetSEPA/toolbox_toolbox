function [ datenums ] = datenumVariableFormat(dateStrings,dateFormats )
% Convert strings to datenums. The strings can be of different format. 
% This function was written because Excel would sometimes import dates as
% strings, dropping the time if it corresponded to midnight.
% e.g. '31/12/1999 23:59', '01/01/2000'
%
% INPUT:
% dateStrings : char or cell array of strings representing dates
% dateFormats : formats of these strings. If no dateFormats are passed,
%               some default values are attempted (see below)
%
% OUTPUT:
% datenums  : doubles containing datenums of converted strings 
% 
% Default dateFormats:
%         dateFormats={'dd/mm/yyyy','dd/mm/yyyy HH:MM','dd/mm/yyyy HH:MM:SS','dd-mmm-yyyy','dd-mmm-yyyy HH:MM'};
% 
% EXAMPLES:
% datenumVariableFormat('29/02/2012') % works fine - recognised format
% % datenumVariableFormat('29/02/12') % error - non-default format
% datenumVariableFormat('29/02/12','dd/mm/yy') % ok now we've specified the format 
% datenumVariableFormat({datestr(now),'31-Dec-1999'}) % Works - both formats are recognised strings
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   datenumVariableFormat.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Apr 18 2016 11:39:38  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    help datenumVariableFormat
end
if nargin<2 % Have some pre-defined possibilities
    dateFormats={'dd/mm/yyyy','dd/mm/yyyy HH:MM','dd/mm/yyyy HH:MM:SS','dd-mmm-yyyy','dd-mmm-yyyy HH:MM','dd-mmm-yyyy HH:MM:SS'};
end
% If input is numeric, assume they're datenums and return without further ado
if isnumeric(dateStrings)
    datenums=dateStrings;
    return
end
% Make sure inputs are cells:
if ischar(dateStrings)
    dateStrings={dateStrings};
end
if ischar(dateFormats)
    dateFormats={dateFormats};
end
% Some checks on date formats. We need to make sure each format has a
% different length, so we can determine which one to apply to our
% dateStrings
numberOfDateFormats=length(dateFormats); % number of date format
lengthOfDateFormats=cellfun(@length,dateFormats); % length of each format
numberOfUniqueDateFormatLengths=length(lengthOfDateFormats); % number of distinct lengths
if numberOfUniqueDateFormatLengths~=numberOfDateFormats
    error('Date Formats should all have a distinct length')
end
% Now check dateStrings we've been passed
numberOfDateStrings=length(dateStrings); % Number of strings to try to convert
lengthOfDateStrings=cellfun(@length,dateStrings); % length of each string
dl=setdiff(lengthOfDateStrings,lengthOfDateFormats); % Any string length not matching a date format length?
if ~isempty(dl) % ... then we've got a problem! 
    error('length mismatch; please provide formats for date strings of length ''%s''',num2str(dl))
end
% Store our number here:
datenums=NaN(numberOfDateStrings,1);
for i=1:numberOfDateFormats
    iDateFormat=dateFormats{i}; % for this format:
    try % attempt to convert all strings with matching length
        k=lengthOfDateStrings==length(iDateFormat); % indices corresponding to this date format length
        if(any(k))
            datenums(k)=datenum(dateStrings(k),iDateFormat);
        end
    catch % Oh dear - conversion failed
        error('Error converting to datenum using format ''%s''\n',iDateFormat)
    end
end