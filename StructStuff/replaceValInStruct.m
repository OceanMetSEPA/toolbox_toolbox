function s = replaceValInStruct(s, oldVal, newVal)
%REPLACEVALINSTRUCT Recursively replaces oldVal with newVal in numeric fields of a struct
%
% Handles NaN comparisons correctly.
%
% INPUT:
%   s       - input struct (can be nested and contain arrays or cells)
%   oldVal  - numeric value to search for (can be NaN)
%   newVal  - numeric value to replace oldVal with
%
% OUTPUT:
%   s       - updated struct with replacements made
%
% Example:
%   s = struct('a', NaN, 'b', [1, NaN], 'c', {{NaN, 5}});
%   sOut = replaceValInStruct(s, NaN, 9999);

if ~isscalar(s)
    for idx = 1:numel(s)
        s(idx) = replaceValInStruct(s(idx), oldVal, newVal);
    end
    return;
end

useIsNaN = isnumeric(oldVal) && isnan(oldVal);  % Special case for NaN

fn = fieldnames(s);
for i = 1:numel(fn)
    fni = fn{i};
    ivalue = s.(fni);

    if isstruct(ivalue)
        s.(fni) = replaceValInStruct(ivalue, oldVal, newVal);

    elseif isnumeric(ivalue)
        if useIsNaN
            ivalue(isnan(ivalue)) = newVal;
        else
            ivalue(ivalue == oldVal) = newVal;
        end
        s.(fni) = ivalue;

    elseif iscell(ivalue)
        val = ivalue;
        for j = 1:numel(val)
            item = val{j};
            if isnumeric(item)
                if useIsNaN
                    item(isnan(item)) = newVal;
                else
                    item(item == oldVal) = newVal;
                end
                val{j} = item;
            elseif isstruct(item)
                val{j} = replaceValInStruct(item, oldVal, newVal);
            end
        end
        s.(fni) = val;
    end
end
end
