function [total,s]=addStructFields(s)
% Add data contained in separate fields of struct
% Each field should be array of equal size
% 
% INPUT: 
% s - struct where each field contains array of size [Nx,Ny]
% 
% OUTPUT:
% total - sum of fields
%
% EXAMPLE
% m=magic(5)
% s=struct('a',m,'b',2*m);
% tot=addStructFields(s)
% isequal(tot,3*m) % 1
%
% This function originally written for structs where each field contains
% the concentration predictions for an individual farm. These are stored as
% sparse matrices which need to be processed differently from full
% matrices, as matlab doesn't allow 3d sparse arrays (and very slow /
% resource intensive to convert large sparse matrices to full).
%

% Some initial tests...
if ~isstruct(s)
    error('struct input required')
end
% Field size
fn=fieldnames(s);
sizeMatch=cellfun(@(x)isequal(size(s.(x)),size(s.(fn{1}))),fn(2:end));
if ~all(sizeMatch)
    error('Mismatch in field sizes')
end
Nf=length(fn);
[NRows,NCols]=size(s.(fn{1}));

try
    % This way works for full matrices
    c=struct2cell(s); % cell array with one cell for each struct field
    m=cat(3,c{:}); % append along 3rd dimension (get error if s sparse though)
    total=sum(m,3);
catch % For sparse matrices, add data one field at a time
    %    m=cell2mat(c) % [NRows * Nf , NCols] - tricky to unbundle so don't bother trying
    total=sparse(NRows,NCols); % output needs to be this size
    % loop through fields:
    for fieldIndex=1:Nf
        fni=fn{fieldIndex};
        if isfield(s,fni)
            % Note 20240430 - scaleStruct doesn't retain fields with all
            % zero values. It probably should. But for now use this fix
            % (Ferramus with zero biomass broke it)
            vals=s.(fni);
            % update total:
            total=total+vals;
        end
    end
end
