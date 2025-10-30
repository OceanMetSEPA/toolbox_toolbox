function opt = resolveOption(args, validOptions)
% resolveOption - General-purpose argument resolver for string/numeric/logical options
%
% This function identifies which valid option a user-supplied argument refers to.
% It supports both string-style (prefix-matching) and numeric/logical comparisons.
%
% INPUTS:
%   args          - Cell array of mixed arguments (e.g. {'fi', -1} or {true, 0})
%   validOptions  - List of valid options:
%                     * cell array of strings → string/prefix match
%                     * numeric/logical vector → numeric match or logical conversion
%
% OUTPUT:
%   opt           - The resolved option (one of validOptions)
%
% BEHAVIOUR:
%   1️⃣ If validOptions are strings:
%       - Keeps only string/char inputs
%       - Matches by prefix (case-insensitive)
%       - Errors if ambiguous or no match
%
%   2️⃣ If validOptions are numeric/logical:
%       - Keeps only numeric/logical inputs
%       - If one numeric option provided:
%           → returns that numeric value
%       - If multiple validOptions:
%           → chooses the nearest numeric value, or matches exact logical
%
% EXAMPLES:
%   resolveOption({'fi', -1}, {'fish','frog'})
%       → 'fish'
%
%   resolveOption({'f', 3}, {'fish','frog'})
%       → error: ambiguous match
%
%   resolveOption({pi, 'dog'}, [true false])
%       → true (since pi>1)
%
%   resolveOption({0.2, 'fish'}, [true false])
%       → false
%
% NOTES:
%   - String matching is case-insensitive
%   - Logical matching interprets >1 as true, <=0 as false
%

    if isempty(args)
        error('resolveOption:EmptyInput', 'No arguments provided.');
    end

    % --- Case 1: validOptions are strings
    if iscell(validOptions) && all(cellfun(@(x)ischar(x)||isstring(x),validOptions))
        % keep only string inputs
        strArgs = args(cellfun(@(x)ischar(x)||isstring(x),args));
        if isempty(strArgs)
            error('Expected at least one string input for string options.');
        elseif numel(strArgs)>1
            error('Expected a single string/char input, found %d.',numel(strArgs));
        end

        strArg = lower(string(strArgs{1}));
        optsLower = lower(string(validOptions));
        k = startsWith(optsLower,strArg);

        switch sum(k)
            case 0
                error("'%s' doesn't match any valid string options.",strArg)
            case 1
                opt = validOptions{k};
%                fprintf('Matched string option: %s\n',opt);
            otherwise
                error("'%s' is an ambiguous string match among %d options.",strArg,sum(k));
        end

    % --- Case 2: validOptions are numeric/logical
    elseif isnumeric(validOptions) || islogical(validOptions)
        numArgs = args(cellfun(@(x)isnumeric(x)||islogical(x),args));
        if isempty(numArgs)
            error('Expected numeric/logical input for numeric options.');
        elseif numel(numArgs)>1
            error('Expected single numeric/logical input, found %d.',numel(numArgs));
        end
        val = numArgs{1};

        % Logical interpretation if applicable
        if islogical(validOptions)
            % Interpret numeric input as true/false
            if isnumeric(val)
                opt = val>0; % threshold at 0
            else
                opt = logical(val);
            end
 %           fprintf('Resolved logical option: %d\n', opt);

        else
            % Numeric match: choose nearest
            [~,idx] = min(abs(validOptions - val));
            opt = validOptions(idx);
  %          fprintf('Resolved numeric option: %.3g (nearest match)\n', opt);
        end

    else
        error('Unsupported validOptions type: must be all strings or numeric/logical.');
    end
end
