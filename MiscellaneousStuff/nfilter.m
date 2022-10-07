function op=nfilter(x,k)
% filter input 'x' by indices 'k', where 'k' can be nan or outwith valid range
% If k is nan, return nan.
%
% INPUTS:
% x - values to filter
% k - indices to extract
%
% OUTPUT:
% op - x values filtered by k
%
% Example:
%x=10:20;
%k=[3,6,nan,2,100]; % x(k) will fail due to nan and index > length(x)
%
% Can't do this:
% x(k)% ERROR! Array indices must be positive integers or logical values.
% nfilter(x,k) % returns [12,15,NaN,11,NaN]
%
% Cell arrays can also be filtered:
% letters=arrayfun(@char,96+(1:26),'unif',0); % 'a' to 'z'
% nfilter(letters,1:3:26)

if nargin<2
    help nfilter
    return
end

Nk=length(k);
% Prepare cell to store output:
op=repmat({nan},Nk,1);
% (Note we don't use numeric output in case input is cell)

% These are the values of x we want to extract:
nnan=~isnan(k) & ismember(k,1:length(x));
% Extract them
vals=x(k(nnan));
% Now we want to put them into the appropriate position of our output array:
try
    op(nnan)=vals; % This fails if vals are numeric
catch % in which case convert to cells
    vals=num2cell(vals);
    op(nnan)=vals;
end
try % to convert back to numeric array 
    op=cell2mat(op);
catch % never mind
end