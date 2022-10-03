function [ op ] = tally(x,varargin)
% Return a count of the unique members of the input argument
%
% Matlab has a 'tabulate' function in statistics toolbox, which presumably
% does much the same, but we don't currently have the toolbox
%
% INPUT -
% x, the values to tally. This is either:
%    1) vector of numeric / logical values
%    2) cell array - chars or mixture of classes
%
% Optional Inputs:
% dim (1) - dimension of output. If dim==1, unique values stored in separate columns.
%           If dim ~=1, unique  values are stored in rows
% count (-1) - order output by number of counts (-1 = descending i.e. most
%              common occurence first)
% element (0) - if element>0, order unique values of x in increasing order
%               if element<0, order unique values of x in decreasing order
%               (sorts numeric values numerically and strings
%               alphabetically. Issues warning if mixture of classes)
% duplicate (false) - Only return duplicate values (i.e. where count >1)
% matrix (true) - if logical/numeric input, convert from cell array to matrix
%
% OUTPUT -
% array containing 2 vectors:
% 1 - unique values in input dataset
% 2 - number of occurences of those values
%
% EXAMPLE USAGE:
%
% x=ceil(10*rand(100,1));
% tally(x) % rank output by decreasing number of counts
% tally(x,'count',1) % rank output by increasing number of counts
% tally(x,'element',1)% rank output by increasing value of unique values of x
%
%t=tally([pi,exp(1),i,Inf,Inf,NaN])
%t=tally({'fish','doggies','doggies','','',NaN,pi},'duplicate',1) % only return duplicates
%t=tally({'fish','fish','aaaaardvark','zebra','frogs','doggies','doggies'},'el',-1) % reverse alphabetical order
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   tally.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Aug 02 2017 12:46:58  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% No args ? then help user!
if nargin==0
    help tally
    return
end

% Optional arguments:
options=struct;
options.count=-1;
options.element=0;
options.dim=1;
options.duplicate=false;
options.matrix=true;
options=checkArguments(options,varargin);

x=x(:); % Make sure it's a column vector

% Call 'unique' function on two types of input:
% 1) char : stored as a cell array of strings
% 1) non-char : numeric (double, uint8 etc) and logical
%
if islogical(x) % convert to numeric so we can convert to matrix if required
    x=double(x);
end

if ~iscell(x) % We can use unique function, so proceed there
    op=numberCount(x);
else    % check class of cell contents
    xClasses=unique(cellfun(@class,x,'UniformOutput',false));
    Nclasses=length(xClasses);
    % If we've more than one type of class, we call tally for each class.
    % (unique doesn't like mixture!)
    if Nclasses>1 % Infinte recursion if we don't have this condition!
        op=cell(Nclasses,1);
        for classi=1:Nclasses
            class2check=xClasses(classi);
            ithValue=x(cellfun(@(cf)strcmp(class(cf),class2check),x)); % extract values with class 'i'
            op{classi}=tally(ithValue,'matrix',0); %Note function calling itself.
        end
        op=horzcat(op{:}); % Bundle our tallies for different classes
        op=applyOptions(op,options); % Apply ordering options
        return
    else
        xClass=xClasses;
    end
    % If we get here, we've got a unique class for x - either strings or
    % number types
    if strcmp(xClass,'char') % presumably chars - so we don't have to worry about NaNs
        op=stringCount(x);
    else % assume it's a number / logical type
        x=cell2mat(x); % we can't run unique function below on cell array of numbers
        op=numberCount(x);
    end
end
% function to count number of unique strings
    function op=stringCount(x)
        uniqueStrings=unique(x);
        NuniqueStrings=length(uniqueStrings);
        op=cell(2,NuniqueStrings);
        for scIndex=1:NuniqueStrings
            ithString=uniqueStrings{scIndex};
            Nm=sum(strcmp(ithString,x));
            op{1,scIndex}=ithString;
            op{2,scIndex}=Nm;
        end
    end

% function to count number of unique numeric values
    function op=numberCount(x)
        % NB NaN==NaN = false!
        % So if we've got multiple nans, each one will be considered to be
        % a separate value by unique function. We want just a count of the
        % number of NaNs...
%         ffs=class(x)
%         if islogical(x) % convert to numeric (so we can convert to matrix if necessary)
%             x=uint8(x); % don't need doubles as it's either 0 or 1
%         end
%         noo=class(x)
        nanx=isnan(x); % check for nans
        numberOfNaNs=sum(nanx); % count them
        x=x(~nanx); % Remove nans
        ux=unique(x); % Find unique values of non-NaN values
        Nux=length(ux);
        opSize=Nux+(numberOfNaNs>0); % include extra column if we've got NaNs
        op=cell(2,opSize);
        for ncIndex=1:Nux
            ncithValue=ux(ncIndex);
            op{1,ncIndex}=ncithValue;
            Nm=length(x(x==ncithValue));
            op{2,ncIndex}=Nm;
        end
        if numberOfNaNs>0
            op{1,opSize}='NaN';
            op{2,opSize}=numberOfNaNs;
        end
    end

% Apply optional arguments (ordering, dimension of output)
    function op=applyOptions(op,options)
        nanIndices=cellfun(@(x)isequal(x,'NaN'),op(1,:));
        if any(nanIndices)
            op{1,nanIndices}=NaN;
        end
        if options.duplicate % Only return duplicate values
            op=op(:,cell2mat(op(2,:))>1);
        end
        if options.element~=0
            elClasses=cellfun(@class,op(1,:),'Unif',0);
            if length(unique(elClasses))>1
                warning('Multiple classes! Can''t rank elements...')
            else
                if all(cellfun(@ischar,op(1,:)))
                    [~,opOrder]=sort(op(1,:));
                else
                    [~,opOrder]=sort(cell2mat(op(1,:)));
                end
                if options.element<1
                    opOrder=fliplr(opOrder);
                end
                op=op(:,opOrder);
            end
        elseif ~options.count==0
            [~,opOrder]=sort(cell2mat(op(2,:)));
            if options.count<1
                opOrder=fliplr(opOrder);
            end
            op=op(:,opOrder);
        end
        if ~isequal(options.dim,1)
            op=op';
        end
    end

op=applyOptions(op,options);
if options.matrix && isnumeric(x)
    try
        op=cell2mat(op);
    catch err
        disp(err)
        warning('Failed to convert to matrix')
    end
    
end
end

