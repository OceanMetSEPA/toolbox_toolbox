function hello(varargin)
% Friendly greeting to matlab user

% Dos command to get user name:
[~,username]=dos('echo %username%');
% Remove new line
username(end)=[];
% We're all friends here so use first name:
user=strsplit(username,'.');
firstName=user{1};
% Capitalise first letter:
firstName(1)=upper(firstName(1));

% Morning or afternoon?
[~,~,~,hh,~]=datevec(now);
if hh<12
    dayBit='morning';
else
    dayBit='afternoon';
end

fprintf('Good %s, %s!\n',dayBit,firstName)
