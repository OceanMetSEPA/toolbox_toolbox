function [ sop ] = appendstruct(varargin )
% Append structs with matching fieldnames
%
% Append subsequent structs to first struct; fields can be either
% specifically included or excluded
%
% INPUT:
% s() or s1,s2,s3... - struct array, or sequence of structs
%
% Optional Input:
% 'include' [] - only include fields with names specified in this str/cellstr
% 'exclude' [] - exclude fields containing these strings
%
% OUTPUT:
% appended struct
%
% Notes:
% 1) this function was developed to join the output from sequential
% model runs (MIKE / D3D). It tries to combine fields vertically, then
% horizontally. If you want different behavoir, you'll need to preprocess
% your struct or add options to this function!
%
% 2) the name of this function doesn't conform to our standard camelCase
% but was thus named to be consistent with mergestruct
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   appendstruct.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Feb 02 2018 12:56:20  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help appendstruct
    return
end

% Check inputs for structs
k=cellfun(@isstruct,varargin);
if ~any(k)
    error('Please pass some structs!')
end

notStruct=find(k==0,1,'first');

options=struct;
options.include=[];
options.exclude=[];

% Check for optional (string) arguments
% (Sort into structs for appending and options)
if ~isempty(notStruct)
    k=notStruct-1;
    s=varargin(1:k); %These are the structs 
    varargin(1:k)=[]; % remove structs from varargin
else
    s=varargin; % All inputs are structs
    varargin=[]; % no optional aruments
end
if ~isempty(varargin)
    % Check we've got correct number (multiple of 2) and that each odd
    % varargin is a string
    if ~(mod(length(varargin),2)==0 && all(cellfun(@ischar,varargin(1:2:end))))
        error('Invalid optional inputs! Should be sequence of [''option'', value] etc')
    end
end
options=checkArguments(options,varargin);

% Righto, now bundle structs into struct array
try
    s=vertcat(s{:});
    s=s(:);
catch
    error('Problem combining structs; different fieldnames?')
end

% Check which fields we need to append
fn=fieldnames(s); % by default, all of them 
if ~isempty(options.include) % only include these ones in analysis
    fn=stringFinder(fn,options.include,'type','or');
end
if ~isempty(options.exclude) % exclude these ones from analysis
    fn=stringFinder(fn,'*','nand',options.exclude);
end

% Ok here we go
Nf=length(fn);
%sop=struct;
sop=s(1); % copy of first struct
for i=1:Nf % loop through fields to modify
    fni=fn{i};
    try
        vals=vertcat(s.(fni));
    catch
        try
            vals=horzcat(s.(fni));
        catch
            error('Dimension mismatch at field %s',fni)
        end
    end
    sop.(fni)=vals;
end

end
