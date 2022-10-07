function op=sizeString(x)
% Generate meaninful label for number, based on exponent names
%
% INPUT:
% x - size in bytes
% 
% OUTPUT:
% op - string describing size more meaningfully
%
% EXAMPLES:
% sizeString(0) % 'zero size'
% sizeString(1) % '1 byte'
% sizeString(2e3) % 1 KB
% sizeString(pi*1e10) % '31.4159 GB'
% sizeString([0,1*10.^(0:15)]) % cell array of outputs

if nargin==0
    help sizeString
    return
end

labels={'bytes','KB','MB','GB','TB'};

if length(x)>1
    x=x(:);
    op=arrayfun(@sizeString,x,'unif',0);
    return
end
if x<1
    op='zero size';
elseif x==1
    op='1 byte';
else
    % Get order of magnitude band
    mag=floor(log10(x)/3);
    mag=min([mag,4]); % we've only labelled up to 10^(mag*3) for mag=4
    op=sprintf('%s %s',num2str(x/10^(mag*3)),labels{mag+1});
end
%fprintf('%e and label = ''%s''\n',x,op)
end
