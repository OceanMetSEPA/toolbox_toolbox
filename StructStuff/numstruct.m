function s=numstruct(s)
% Convert struct to numeric
% 
% INPUT:
% s - struct 
%
% OUTPUT:
% s - struct with fields converted to numeric where appropriate
%
% EXAMPLE
% s=struct('a','fish','b','3.14','c',{{1,'2','fish'}})
% s.s=s; % add nested struct
%
% sn=numstruct(s)
    % a: 'fish'
    % b: 3.14
    % c: {[1]  [2]  'fish'}
    % s: [1×1 struct]
% sn.s
    % a: 'fish'
    % b: 3.14
    % c: {[1]  [2]  'fish'}

fn=fieldnames(s);
Nf=length(fn);
for i=1:Nf
    fni=fn{i};
    ivalue=s.(fni);
    if isstruct(ivalue)
        s.(fni)=numstruct(ivalue);
    elseif iscell(ivalue)
        val=cell(size(ivalue));
        for cellIndex=1:numel(ivalue)
            ival=ivalue{cellIndex};
            try
                tmp=str2num(ival);
                if ~isnan(tmp) && ~isempty(tmp)
                    val{cellIndex}=tmp;
                end
            catch % oh well
                val{cellIndex}=ival;
            end
            s.(fni)=val;
        end
    else
        try
            numericValue=str2num(ivalue); % warning: str2num is slower than str2num
            if ~any(isnan(numericValue)) && ~all(isempty(numericValue))
                s.(fni)=numericValue;
            end
        catch
            % isname(template) fails when splitting NewDepomod template files
        end
    end
end
