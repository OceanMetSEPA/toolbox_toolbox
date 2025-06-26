function s = numstruct(s)
% Convert struct to numeric
%
% Recursively converts strings to numeric values where possible
% inside structs and cells, while preserving non-convertible data.

if ~isscalar(s)
    for idx = 1:numel(s)
        s(idx) = numstruct(s(idx));
    end
    return;
end

fn = fieldnames(s);
for i = 1:numel(fn)
    fni = fn{i};
    ivalue = s.(fni);

    if isstruct(ivalue)
        s.(fni) = numstruct(ivalue);  % Recursive call

    elseif iscell(ivalue)
        val = ivalue;  % Preserve shape and contents
        for cellIndex = 1:numel(ivalue)
            ival = ivalue{cellIndex};
            if ischar(ival) || (isstring(ival) && isscalar(ival))
                tmp = str2double(ival);
                if ~isnan(tmp)
                    val{cellIndex} = tmp;
                end
            end
        end
        s.(fni) = val;

    elseif ischar(ivalue) || (isstring(ivalue) && isscalar(ivalue))
        tmp = str2double(ivalue);
        if ~isnan(tmp)
            s.(fni) = tmp;
        end
    end
end
end
