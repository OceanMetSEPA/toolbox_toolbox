function op=fullOrSparse(s,varargin)
% Convert fields of struct to full / sparse
%
% INPUT:
% s - struct / cell array of structs / filename of matfile containing struct
%
% Optional inputs:
% full [false] - convert to full
% sparse [false] - convert to sparse
% nullValue [] - set this value to zero
% nan2Zero [true] - set nans to zero
% filename [] - if not empty, save struct to this file
%
% OUTPUT:
% op - converted struct
%
% Note - sparse structs can use MUCH less memory if there are lots of
% zeros. However, they can be larger if >>10% of numbers are non-zero. 
%
% Could adapt this function so it changes sparse to full and vice versa -
% then you wouldn't need to specify full/sparse options. On the other
% hand, setting full/sparse explictly (as currently done) may be more
% transparent. Could also add checks of variable size (varSize()) to see if
% transformation is worth it in terms of memory used...

options=struct;
options.filename=[];
options.save=0;
options.sparse=false;
options.full=false;
options.nullValue=[];
options.nan2Zero=true;
options=checkArguments(options,varargin);

switch class(s)
    case 'struct'
        % default
    case 'char'
        if ~isfile(s)
            error('Char input should be filename')
        end
        options.filename=s;
        s=importdata(s);
        op=fullOrSparse(s,options);
        return
    case 'cell'
        op=cellfun(@(x)fullOrSparse(x,varargin),s,'unif',0);
        try
            op=vertcat(op{:});
        catch % oh well
        end
        return
    otherwise
        if isnumeric(s)
            if options.full
                op=full(s);
            elseif options.sparse
                op=sparse(s);
            else
                op=s;
            end
            return
        else
        error('Invalid input')
        end
end

% If we get here we should have a struct!
fn=fieldnames(s);
Nf=length(fn);
for fieldIndex=1:Nf
    fni=fn{fieldIndex};
    vals=s.(fni);
    if isnumeric(vals) && options.nan2Zero
        vals(isnan(vals))=0;
    end
    if ~isempty(options.nullValue)
        try
            k=vals==options.nullValue;
            fprintf('%s: Setting %d values to zero...\n',fni,sum(k(:)))
            vals(k)=0;
        catch %err
            %            disp(err)
        end
    end
    
    
    if options.sparse
        try
            vals=sparse(vals);
        catch % fails for e.g. char fields
            %            fprintf('Failed to convert field ''%s'' to sparse\n',fni)
        end
    end
    if options.full
        vals=full(vals);
    end
    op.(fni)=vals;
end

if ~isempty(options.filename)
    fprintf('Saving to %s\n',options.filename)
    var2matfile(op,options.filename)
end







