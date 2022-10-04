function s=tstruct(varargin)
% Generate struct with 'invalid' but more informative fieldnames
% Struct can then be viewed using 'dispStruct' function
%
% INPUTS- either:
%   1) fieldname/value pairs OR
%   2) struct, fieldname/value pairs
%
% OUTPUT: 
% struct
%
% EXAMPLE:
% s=tstruct('EQS µg/l',1234); % allocate struct with 'invalid' name
% s=tstruct(s,'& another field','fishface'); % add field to struct
% dispStruct(s)

if nargin==0
    help tstruct
    return
end

if isstruct(varargin{1})
    s=varargin{1};
    varargin(1)=[];
else
    s=struct;
end

if mod(length(varargin),2)~=0
    error('Even number of input arguments required')
end
N=nargin-1;
for i=1:2:N
    fn=varargin{i};
    if ~ischar(fn)
        error('Odd arguments must be chars')
    end
    fn=strrep(fn,' ','0x20');
    fn=genvarname(fn);
    val=varargin{i+1};
    s.(fn)=val;
end