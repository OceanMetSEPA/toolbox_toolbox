function [ ] = dispStruct(s,varargin)
% Display struct (array)
%
% This function displays a struct whose fields have equal length to the
% screen for viewing
%
% INPUT:
% s - struct to display
%
% Optional Inputs:
% rows2Display - indices of rows to display
%
% OUTPUT:
% none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   dispStruct.m  $
% $Revision:   1.2  $
% $Author:   Ted.Schlicke  $
% $Date:   Nov 20 2020 09:16:10  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help dispStruct
    return
end

if isempty(s)
    return
end

if istable(s)
    try
%        fprintf('Converting table to struct...\n')
        s=table2struct(s);
    catch
        error('problem converting table to struct')
    end
end

if ~isstruct(s)
    error('Argument 1 should be struct')
end


options=struct;
options.rows=[];
options.transpose=false;
options.ungenvarname=true;
options.rmfields=[];

% Old version of this function only had one optional argument. This is for
% backwards compatability
if nargin>1
    if ~ischar(varargin{1})
        options.rows=varargin{1};
        varargin(1)=[];
    end
end
options=checkArguments(options,varargin);
rows2Display=options.rows;


 % Check field sizes
fn=fieldnames(s);
if ~isempty(options.rmfields)
    fn2Remove=options.rmfields;
    s=rmfield(s,fn2Remove);
    fn=fieldnames(s);
end

if length(s)==1 % struct, not struct array
    try
        s=struct2struct(s); % Convert to struct array
    catch err
        disp(err)
        error('Problem converting to struct array')
    end
else
    % it's a struct array, so should be fine
end

% Do we want to filter rows?
if ~isempty(rows2Display)
    if islogical(rows2Display)
        rows2Display=find(rows2Display);
    end
    if ~isnumeric(rows2Display)
        error('Argument 2 should be numeric')
    end
    if any(rows2Display~=floor(rows2Display))
        error('Argument 2 should be integer')
    end
    if any(rows2Display<0)
%        hmm=length(s)
        rows2Display=length(s)+rows2Display;
    end
    if any(rows2Display<1 | rows2Display>length(s))
        error('Rows should be between 1 and %d',length(s))
    end
    s=s(rows2Display);
end

c=struct2cell(s)';

% Prepare cell array for display
fn=fn';
if options.ungenvarname
    fn=ungenvarname(fn); %
end
op=[fn;c];
if options.transpose
    op=op';
end
disp(op);


end
