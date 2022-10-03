function [options,argIndex,fieldIndex] = checkArguments(options,varargin)
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
% 22/01/2013 Add additional output arguments
%
% [options,ai,fi] = checkArguments(options,'hpos',100,'value',pi)
% ai = [2, NaN, 1] % options fields set by these arguments (NaN means not
%                    set, i.e. hsize not specified)
% fi = [3, 1]   % argument 1 sets field 3 of struct; argument 2 sets field 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   checkArguments.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   Oct 10 2016 10:00:06  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

argIndex=[];
fieldIndex=[];

% Check args to this function - we might not have to do much
if nargin==0
    help checkArguments
    return
end

% Ensure function copes with using varargin or varargin{:} as input:
while length(varargin)==1 && iscell(varargin)
    varargin=varargin{:};
end
% check that we've got some varargins to test
if isempty(varargin) || isequal(varargin,{{}})% Don't need to do anything
    return
end
% 20161007 - new feature! Allow varargin to be a struct - this can be
% useful if we want to pass lots of arguments to a function
if isstruct(varargin)
    structInput=varargin; % this is our struct with various options
    fn=fieldnames(structInput); % extract its fieldnames
    str=arrayfun(@(i){fn{i},structInput.(fn{i})},1:length(fn),'Unif',0); % convert to cell array
    varargin=horzcat(str{:}); % unbundle 
end

%%%%%%%%%%%%%%%%%%%%%%
% Processes Involved:
%%%%%%%%%%%%%%%%%%%%%%
% 1) We reshape our 1d varargin to 2d - 1st row  = fieldname, second row =
% values
% 2) Check whether these arguments are to set options for this function
% (stored in 'localOptions' struct)
% 3) If not, we assume they're intended to set fields in 'options' struct
% STAGE 1: reshape the args:
if numel(varargin)==1 % Our arguments might be all bundled up
    varargin=varargin{:}; % Expand our cell array
    if ischar(varargin) % 
        varargin=cellstr(varargin);
    end
end

v1=varargin(1);
if iscell(v1)
    varargin=[v1{:},varargin(2:end)];
end

if mod(length(varargin),2)~=0
    fprintf('varargin = \n')
    disp(varargin)
    error('Please ensure there is an even number or arguments')
end
argsArray=reshape(varargin,2,[]);

% STAGE 2 : prepare struct for setting options for this function (What to do with ambiguous
% arguments etc):
localOptions=struct('noMatch','warning','multipleMatch','warning');
localOptionsFieldNames=fieldnames(localOptions);
% Check if args are intended for setting optios for this function
Nf=size(argsArray,2);
rm=false(Nf,1);
for i=1:Nf % Check each varargin string
    fni=argsArray{1,i}; % 
    cmp=strncmp(fni,localOptionsFieldNames,length(fni)); % Any match with local option fields?
    if any(cmp) % Yes?
        localOptions.(localOptionsFieldNames{cmp})=argsArray{2,i};    % Transfer varargin value to struct
        rm(i)=true;
    end
end
argsArray(:,rm)=[]; % and remove NB MIGHT WANT TO CHANGE THIS IF OUR OPTIONS STRUCT HAS SAME FIELDS AS LOCAL OPTIONS
% SOME ERROR CHECKING FOR SETTING OF LOCAL OPTIONS:
% These are the valid options:
acceptableOptions={'ignore','warning','error'};
% Check the local options are valid:
s=strncmp(acceptableOptions,localOptions.noMatch,length(localOptions.noMatch));
if(sum(s)~=1)
    error('''noMatch'' option must be one of the above')
else
    localOptions.noMatch=acceptableOptions{s};
end
s=strncmp(acceptableOptions,localOptions.multipleMatch,length(localOptions.multipleMatch));
if(sum(s)~=1)
    disp('multipleMatch OPTIONS:')
    disp(acceptableOptions)
    error('''multipleMatch'' option must be one of the above')
else
    localOptions.multipleMatch=acceptableOptions{s};
end
% prepare function depending on option:
switch localOptions.noMatch
    case 'ignore'
        noMatchFunction='sprintf';
    case 'warning'
        noMatchFunction='warning';
    case 'error'
        noMatchFunction='error';
end
switch localOptions.multipleMatch
    case 'ignore'
        multipleMatchFunction='sprintf';
    case 'warning'
        multipleMatchFunction='warning';
    case 'error'
        multipleMatchFunction='error';
end

% OK, finished sorting local options. Now some abbreviations:
Noptions=length(fieldnames(options)); % Number of options in options struct
optionsFieldNames=fieldnames(options);
Nargs2Check=size(argsArray,2);
% Prepare space for additional outputs - gives more info about matches etc
argIndex=NaN(1,Noptions);
fieldIndex=NaN(1,Nargs2Check);

% OK, now we start looping
for i=1:Nargs2Check
    %    i=args2check(argsIndex);
    argi=argsArray{1,i}; % Input argument character
    % Try to match command line arguments with options.
    % We'll start by looking for an exact match:
    m=strcmp(argi,optionsFieldNames); % Compare user argument with option fieldnames
    lm=sum(m);
    % If we didn't find an exact match, we'll be more lenient:
    if(lm~=1)
        m=strncmp(argi,optionsFieldNames,length(argi)); % Compare user argument with option fieldnames
        lm=sum(m);
    end
    if(lm==1) % if we have an unambiguous match
        options.(optionsFieldNames{m})=argsArray{2,i}; % Pop next argument into our options struct       {} ()
        argIndex(m)=i;
        fieldIndex(i)=find(m);
    elseif(lm==0)
        command=sprintf('%s(''%s is not a recognised argument'')',noMatchFunction,argi);
        if ~isequal(localOptions.noMatch,'ignore')
            eval(command);
        end
    elseif(lm>0)
        command=sprintf('%s(''%s is an ambiguous argument'')',multipleMatchFunction,argi);
        if ~isequal(localOptions.multipleMatch,'ignore')
            eval(command);
        end
    end
end

end
