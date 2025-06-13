function result = decayRate(tOrK, unit, decayPercentage, outputUnit)
%DECAYRATE Calculates decay rate or decay time using exponential decay.
%
% This function uses the exponential decay model:
%     C = C0 * exp(-k * t)
% where:
%   C0 = initial concentration
%   C  = concentration after time t
%   k  = decay constant (per unit time)
%   t  = time
%
% Rearranging:
%     C / C0 = exp(-k * t)
% Taking logs:
%     -k * t = log(C / C0)
%     k = -log(C / C0) / t
%
% The value C/C0 corresponds to the fraction remaining after decayPercentage:
%     C / C0 = 1 - (decayPercentage / 100)
%
% This formula can also be rearranged to calculate time given decay rate:
%     t = -log(C / C0) / k
%
% INPUTS:
%   tOrK            - Positive time OR negative decay constant (per unit time)
%                     Positive input: calculates decay constant.
%                     Negative input: calculates decay time.
%   unit            - Time unit ('second', 'minute', 'hour', 'day', 'year')
%   decayPercentage - Percent decay over the time (e.g., 50 for half-life)
%   outputUnit      - (Optional) Desired output unit (default is same as input)
%
% OUTPUT:
%   result - Decay constant (if time input) or decay time (if decay constant input)
%
% EXAMPLES: 
% Half-life of 1 day:
%   k = decayRate(1, 'day', 50)       % Expected: ~0.6931 (per day)
%   exp(-k)                           % Should be ~0.5
%
% Get time from k:
%   t = decayRate(-k, 'day', 50)      % Expected: 1
%
% E. coli decaying 90% in 15 hours:
%   k = decayRate(15, 'hour', 90, 'second')  % ~4.264e-5 per second
%   t = decayRate(-k, 'second', 90, 'hour')  % Should return 15
%
% See also: EXP, LOG

if nargin == 0
    help decayRate
    return
end

validUnits = {'second', 'minute', 'hour', 'day', 'year'};

unit = validateUnit(unit, validUnits);

if nargin < 4
    outputUnit = unit;
else
    outputUnit = validateUnit(outputUnit, validUnits);
end

if tOrK == 0
    error('Input value cannot be zero.');
end

C_over_C0 = 1 - decayPercentage / 100;

if tOrK > 0
    % Input is time -> calculate decay constant
    time_in_seconds = convertToSeconds(tOrK, unit);
    k_per_second = -log(C_over_C0) / time_in_seconds;
    % Convert decay constant to per output unit
    result = k_per_second * secondsPerUnit(outputUnit);
else
    % Input is decay constant -> calculate decay time
    k_per_second = (-tOrK) / secondsPerUnit(unit); % convert to per second
    time_in_seconds = -log(C_over_C0) / k_per_second;
    % Convert time to output unit
    result = time_in_seconds / secondsPerUnit(outputUnit);
end

end

%% Helper Functions

function unit = validateUnit(unit, validUnits)
    unit = lower(strtrim(unit));
    unit = stringFinder(validUnits, unit, 'type', 'start');
    if length(unit) ~= 1
        error('Invalid unit: %s', unit);
    end
    unit = char(unit);
end

function seconds = convertToSeconds(value, unit)
    factor = secondsPerUnit(unit);
    seconds = value * factor;
end

function factor = secondsPerUnit(unit)
    switch unit
        case 'second'
            factor = 1;
        case 'minute'
            factor = 60;
        case 'hour'
            factor = 3600;
        case 'day'
            factor = 86400;
        case 'year'
            factor = 31536000;
        otherwise
            error('Unsupported unit: %s', unit);
    end
end
