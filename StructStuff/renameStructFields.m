function [ op ] = renameStructFields( s,newNames )
% Rename fields of a struct
%
% INPUTS:
% s        - struct whose fields are to be renamed
% newNames - new field names (cell array of strings)
%
% OUTPUT:
% s        - struct with new field names
%
% EXAMPLE:
%s=struct('A',1:10,'B',[],'C','froggy')
%s =
%    A: [1 2 3 4 5 6 7 8 9 10]
%    B: []
%    C: 'froggy'
%renameStructFields(s,{'X','Y','Z'})
%ans =
%    X: [1 2 3 4 5 6 7 8 9 10]
%    Y: []
%    Z: 'froggy'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   renameStructFields.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Sep 02 2015 14:31:26  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help renameStructFields
    return
end

if ~iscell(newNames)
    error('2nd argument should be a cell array of names')
end
oldFieldNames=fieldnames(s);
numberOfFieldNames=length(oldFieldNames);

if length(newNames)~=numberOfFieldNames
    error('Please provide %d fieldnames',numberOfFieldNames)
end

for i=1:numberOfFieldNames
    ithFieldName=oldFieldNames{i};
    s.(newNames{i})=s.(ithFieldName); % Copy old field to new field
    if ~strcmp(newNames{i},ithFieldName) % if fieldnames don't match
        s=rmfield(s,ithFieldName); % Remove old field
    end
end

% Ensure order of fields matches input strings
[~,k]=ismember(newNames,fieldnames(s));
s=orderfields(s,k);

op=s;

end
