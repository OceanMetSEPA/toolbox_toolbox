function options=checkArguments(options,varargin)
% Function to set fields of a struct
%
% This function is designed to be a general way of setting options for
% various other functions.
%
% INPUTS:
% options - struct containing parameters to adjust
% varargin - either:
%           1) arguments (parameter, value) for either:
%               a) set fields in options struct or
%               b) set options to checkArguments function
%        or 2) struct where fieldnames = parameters and contents of fields
%               are the corresponding values
%
% checkArguments options are:
%   noMatch (default = 'warning') - what to do if field not found in options struct
%   multipleMatch (default = 'warning') - what to do if field is ambiguous
%
% Options for above parameters must be one of 'warning', 'ignore', 'error'
% (or abbreviation thereof)
%
% OUTPUT:
% options - struct with updated fields (if appropriate)
% argIndex - vector with length equal to number of fields in options struct.
%            This gives the index of the argument within varargin which sets the relevant field
% fieldIndex - vector with length equal to number of odd arguments in
%            varargin. This gives the index of the field within options
%            which is set by the particular argument.
%
% EXAMPLES:
% options=struct('value',10,'hsize',100,'hpos',50) % struct we might want to alter
%
% options=checkArguments(options,'value',50); % change options.value to 50
% options=checkArguments(options,{'value',50}); % as above
% options=checkArguments(options,{'x',123},'noMatch','ignore') % don't worry that 'x' is not a field of options
% options=checkArguments(options,{'x',123},'noMatch','w') % warn that 'x' is not a field of options
% options=checkArguments(options,{'h',100},'mul','e') % error that 'h' doesn't specify unique field
% options=checkArguments(options,struct('hpos',pi)) % update options using struct
%
% 20241107 - this function modified to more clearly identify whether input
% arguments are for specifiying options for for setting options for this
% function
% (previous function broke if options had field 'n'. Specifiying 'n' as
% input was interpreted as 'noMatch' flag for this function). 
% 
% Should really use matlab's 'inputparser' instead...

if nargin==0
    help checkArguments
    return
end


% Ensure function copes with using varargin or varargin{:} as input:
while ~isempty(varargin) && iscell(varargin{1})
    varargin=[varargin{:}];
end
if isempty(varargin) || isempty(varargin{1})
    %    fprintf('Returning because varargin empty\n')
    return
end

% Allow arguments to be passed as struct (useful if we have a bunch of
% options to set)
if isstruct(varargin)
    varargin=struct2varargin(varargin);
elseif isstruct(varargin{1})
    % Allow struct as varargin{1} plus additional argument pairs
    tmp=struct2varargin(varargin{1});
    varargin=[tmp,varargin(2:end)];
end

if ~isstruct(options)
    error('Please pass the struct!')
end
optionsFieldNames=fieldnames(options);
%cprintf('blue','VARARGIN:\n')
%disp(varargin)
%underline

validOptions={'ignore','warning','error'};
localOptions=struct('noMatch','warning','multipleMatch','warning');
localOptionsFieldNames=fieldnames(localOptions);

tmp=intersect(optionsFieldNames,localOptionsFieldNames);
if ~isempty(tmp)
    warning('Ambigous options ''%s''',tdisp(tmp))
end
Nargs=length(varargin);
if Nargs==0
    return
end
if mod(Nargs,2)~=0
    %   fprintf('% args:\n',Nargs)
    %   disp(varargin)
    %   length(varargin)
    %   assignin('base','s',varargin)
    error('Function requires even number of arguments')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
optionsStructArray=cell(Nargs,1);
for paramIndex=1:2:Nargs
    iparam=varargin{paramIndex};
    if ~ischar(iparam)
        error('Odd arguments should be chars')
    end
    val=varargin(paramIndex+1);
    option=closestStringMatch(optionsFieldNames,iparam);
    localOption=closestStringMatch(localOptionsFieldNames,iparam);
    % Might have empty/single/multiple values of each of these.
    % Sort out what we want:
    struct4Field='';
    field='';
    switch length(option)
        case 1
            field=char(option);
            struct4Field='options';
        otherwise
            if length(localOption)==1
                field=char(localOption);
                struct4Field='localOptions';
            end
    end
    s=struct('Index',paramIndex,'input',iparam,'value',val,'option',{option},'localOption',{localOption},'field',field,'code',struct4Field);
    optionsStructArray{paramIndex}=s;

end
optionsStructArray=vertcat(optionsStructArray{:});

%dispStruct(optionsStructArray)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process local option (which determine what to do if options aren't part
% of struct / are ambiguous)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
k=find(strcmp({optionsStructArray.code},'localOptions'));
if ~isempty(k)
    for rowIndex=k
        option2Check=optionsStructArray(rowIndex);
        field=option2Check.field;
        val=option2Check.value;
        if ~ischar(val)
            error('option type must be char')
        end
        valmatch=closestStringMatch(validOptions,val);
        switch length(valmatch)
            case 0
                error('invalid option ''%s''',val)
            case 1
                val=char(valmatch);
            otherwise
                error('ambiguous option ''%s''',val)
        end
        localOptions.(field)=val;
    end
    optionsStructArray(k,:)=[];
end

%disp(localOptions)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final stage - update values in options struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(optionsStructArray);
for rowIndex=1:N
    option2Check=optionsStructArray(rowIndex);
    field=option2Check.field;
    val=option2Check.value;
    ip=option2Check.input;
    command='';
    switch length(option2Check.option)
        case 0
            command=sprintf('%s(''"%s" is not a recognised option'');',localOptions.noMatch,ip);
        case 1
            options.(field)=val;
        otherwise
            command=sprintf('%s(''"%s" is ambiguous option'');',localOptions.multipleMatch,ip);
    end
    if ~contains(command,'ignore')
        eval(command)
    end
end

% Function to convert struct to cell array
% Odd entries are struct fieldnames
% Even entries are values of those fields
    function op=struct2varargin(s)
        fn=fieldnames(s);
        N=length(fn);
        op=cell(1,2*N);
        for i=1:N
            fni=fn{i};
            ind1=2*(i-1)+1;
            ind2=ind1+1;
            op{ind1}=fni;
            var={s.(fni)};
            try
                var=vertcat(var{:});
            catch
            end
            op{ind2}=var;
        end
    end
end

