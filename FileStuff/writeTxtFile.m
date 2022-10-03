function varargout = writeTxtFile(fileName,txt)
% Write txt (cell array of strings) to file
%
% INPUT: char / cell array of strings
%
% OUTPUT: Value returned by fclose (0 = success)
%
% EXAMPLE:
%
% txt=readTxtFile(inputName) % read file into cell array
% writeTxtFile(outputName,txt) % generate outputName
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   writeTxtFile.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   Oct 31 2016 15:38:22  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen(fileName,'w');
if fid<=0
    fprintf('fopen returned %d\n',fid)
    error('Oh dear, couldn''t write to ''%s''',fileName)
end
if iscell(txt)
    txt=sprintf('%s\n',txt{:}); % Convert cell array to chars, one cell per row
    txt(end)=[]; % remove last newline
end
if ~ischar(txt)
    error('Input should be char / cell array')
else
    fprintf(fid,'%s',txt); % This is much faster than looping
end
op=fclose(fid);

% NB above method is MUCH faster than looping through txt:
% Several hundred times faster if Nt > 1e6

% Nt=length(txt)
%for i=1:Nt
%    fprintf('%s\n',txt{i}) % DON'T WRITE FILE LIKE THIS!
%end

if nargout>0
    varargout{1}=op;
    if nargout>1
        error('Too many output arguments')
    end
end

end

