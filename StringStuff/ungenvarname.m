function [ op ] = ungenvarname(varnames,removex)
% Attempt to undo string conversion undertaken by 'genvarname' function
%
% Matlab's 'genvarname' function converts arbitrary strings to strings
% suitable for variable / struct field names. It does this by converting
% invalid characters to their hexadecimal ascii equivalent,
% with 0x preceding the ascii code.
%
%This function looks for 0x strings and converts them back to characters.
%
% Note: Matlab variables can't start with a digit; genvarfun prepends such
% strings with 'x'. This function can't (by itself) decide whether a
% starting 'x' should be interpreted as a character or if it denotes a
% subsequent number. An optional argument can be used to specify which
% action should be taken
%
% INPUTS:
% varnames ([]): strings to process (chars or cells)
% removex  (true): remove starting 'x' if it's followed by a number
%
% OUTPUT:
% convertedStrings: char, if input was char; cell if input was cell
%
% EXAMPLES:
% testStrings={'fish','fr()g','2fishies',sprintf('moo=%c',181),'3.14','not hex 0xZZ'}
% varnames=genvarname(testStrings)
% ungenvarname(varnames)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   ungenvarname.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Sep 02 2015 13:53:04  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help ungenvarname
    return
end

if ~exist('removex','var')
    removex=true;
end

charInput=ischar(varnames);
if charInput
    varnames=cellstr(varnames);
end
if ~iscellstr(varnames)
    error('Please pass char/cell array of strings to this function')
end


Ns=length(varnames);
op=cell(Ns,1);

for varIndex=1:Ns
    str=varnames{varIndex};
%    strOrig=str; % keep original string for reference
    strLength=length(str); % Number of characters in string
    % First of all, check whether string length > 1 and first char = 'x'
    if strLength>1 && str(1)=='x'
        char2=uint8(str(2)); % convert 2nd character to ascii
        if removex && char2>=48 && char2<=57 % 2nd char is numeric (ascii)
            str(1)=[];
        end
    end
    strLength=length(str);
    % Now check for hexadecimal markers ('0x'):
    hexIndices=regexp(str,'0x');
    % Ignore any without 2 following characters:
    hexIndices(hexIndices>strLength-2)=[];
    % Number of hex markers:
    NHexIndices=length(hexIndices);
    % Cell array of hex strings:
    hexStrings=cell(NHexIndices,1);
    % Cell array of replacement strings:
    repStrings=cell(NHexIndices,1);

    % Loop through hex markers trying to convert to ascii:
    for hexIndex=1:NHexIndices
        hexPos=hexIndices(hexIndex);
        hexBit=str(hexPos+(0:3));
        hexStrings{hexIndex}=hexBit;
        hexValue=hexBit(3:4);
        % try to convert this to decimal
        try
            decValue=char(hex2dec(hexValue));
            repStrings{hexIndex}=decValue;
        catch % conversion from hex2dec failed (invalid characters?)
            % Don't worry about it, just leave as is
            repStrings{hexIndex}=hexBit;
        end
    end
    % Use these replacement strings to update input string:
    for hexIndex=1:NHexIndices
%        fprintf('REPLACING ''%s'' with ''%s''\n',hexStrings{hexIndex},repStrings{hexIndex})
        str=strrep(str,hexStrings{hexIndex},repStrings{hexIndex});
    end
    op{varIndex}=str;
end

% If input was row vector:
if size(varnames,1)==1
    op=op'; % transpose output so it matches input
end

if charInput % convert back to chars:
    op=char(op);
end


return