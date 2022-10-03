function op=numberPadder(x,N)
% Convert number to string, padding with zeros at the start
%
% This function is useful for generating filenames which will be listed
% sequentially (e.g. to be added to an animation).
%
% Rather than have files ordered:
% file1.jpg
% file10.jpg
% file2.jpg etc,
%
% We can use this function to pad our index with zeros:
% file01.jpg
% file02.jpg ...
% file10.jpg
%
% INPUTS:
% x - index number
% N  - length of final string
%
% OUTPUT:
% char array with length(x) rows, each of N characters, starting with 0s if appropriate
%
% EXAMPLE:
% numberPadder(1:5,3)
%ans = 
%    '001'
%    '002'
%    '003'
%    '004'
%    '005'
%
% NB This is designed for positive integers- if you pass negative values,
% you probably won't get what you want! 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   numberPadder.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 08 2014 14:02:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help numberPadder
    return
end

Ns=length(x);
op=cell(Ns,1);

for i=1:Ns
    num=num2str(x(i));
    while(length(num)<N)
        num=sprintf('0%s',num);
    end
    op{i}=num;
end
op=char(op); 
end