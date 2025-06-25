function op=padStructWithEmptyFields(struct2Pad,fieldNames2Add)
% Add fields to input struct, padding their values with zeros
% Note: all fields in input struct must be numeric arrays of equal size
%
% INPUT:
% struct2Pad - struct with fields of equal size
% fieldNames2Add - char/cellstr of field(s) to add
%
% OUTPUT:
% struct - original fields unchanged, added fields populated with zeros
%
% EXAMPLE:
% N=5;
% s=struct('a',1:N,'b',rand(1,N))
% padStructWithEmptyFields(s,'c')
  % struct with fields:
  %   a: [1 2 3 4 5]
  %   b: [0.610958658746201 0.778802241824093 0.423452918962738 0.0908232857874395 0.266471490779072]
  %   c: [0 0 0 0 0]

fn=fieldnames(struct2Pad);
fieldNames2Add=cellstr(fieldNames2Add);
outputFieldnames=unique([fn(:);fieldNames2Add(:)]);

% Check sizes of struct fields:
ie=cellfun(@(i)isequal(size(struct2Pad.(fn{1})),size(struct2Pad.(fn{2}))),fn);
if ~all(ie)
    error('Fields have different sizes')
end

% Prepare
z=zeros(size(struct2Pad.(fn{1})));
op=struct;
Nf=length(outputFieldnames);
for i=1:Nf
    fieldName=outputFieldnames{i};
    if isfield(struct2Pad,fieldName)
        val=struct2Pad.(fieldName);
    else
        val=z;
    end
   op.(fieldName)=val;
end
end
