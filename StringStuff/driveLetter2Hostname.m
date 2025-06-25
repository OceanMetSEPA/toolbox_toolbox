function [ op ] = driveLetter2Hostname( txt,varargin )
% Change drive letter (e.g. 'C:') to hostname of computer (e.g. ltp004570)
%
% This function is designed to help identify paths and filenames, and making scripts more portable
%
% INPUT:
%  txt : text or filename
%
% OPTIONAL INPUTS:
%  driveLetter  :  (default = 'C')
%  hostname     :  (default = hostname as returned by 'dos' command)
%
% OUTPUT:
%  modified string (for text input)
%
% EXAMPLES:
%  driveLetter2Hostname(pwd)
%           % changes 'C:\Users\my.name\Matlab'
%           % to      '\\ltp004570\c$\Users\my.name\Matlab'
%

if nargin==0
    help driveLetter2Hostname
    return
end

op=txt;

% Find hostname:
[~,hostname]=dos('hostname'); % dos command returns user and hostname
hostname(end)=[]; % remove newline
hostname=lower(hostname);

% Find drive letter
colonPos=find(txt==':',1,'first');
if isempty(colonPos)
    return
end
driveLetter=txt(colonPos-1);

% Prepare replacement strings
origString=sprintf('%s:%s',driveLetter,filesep);
repString=sprintf('%s%s%s%s%c$%s',filesep,filesep,hostname,filesep,driveLetter,filesep);

op=strrep(txt,origString,repString);

end
