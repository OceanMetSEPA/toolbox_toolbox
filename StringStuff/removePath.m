function [strWithoutPath,removedPath]=removePath(str)
% Remove path from file/directory
%
% INPUT:
% str: file/directory name
%
% OUTPUTS:
% strWithoutPath
% removedPath 
%
% This function splits each input string by the final filesep ('\')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   removePath.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Nov 04 2016 11:00:34  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help removePath
    return
end

charInput=ischar(str);
if charInput
    str=cellstr(str);
end
if ~iscellstr(str)
    error('Input argument should be char / cellstr')
end

strWithoutPath=str;
removedPath=str;
Ns=length(str);
for i=1:Ns
    si=str{i};
    ri=regexp(si,filesep);
    if ~isempty(ri)
        removedPath{i}=si(1:max(ri));
        si=si((max(ri)+1):end);
        strWithoutPath{i}=si;
    end
end
if Ns==1
    strWithoutPath=char(strWithoutPath);
    removedPath=char(removedPath);
end