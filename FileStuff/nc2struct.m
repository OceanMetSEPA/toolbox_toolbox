function nc = nc2struct(ncFile)
% nc2struct Load a NetCDF file into a MATLAB struct.
%
%   nc = nc2struct(ncFile)
%
%   This function reads all variables and attributes from a NetCDF file
%   into a MATLAB struct. The resulting struct has:
%
%       nc.varName             % numeric array for each variable
%       nc.dims.varName        % cell array of dimension names for each variable
%       nc.varAttributes.varName % struct of variable attributes
%       nc.attributes          % struct of global attributes
%
%   Special handling for legacy MATLAB usage:
%   ---------------------------------------
%   MATLAB reads NetCDF arrays using column-major ordering, which effectively
%   reverses the order of dimensions compared to the NetCDF file. For 2D arrays
%   (e.g., particle × time), this loader automatically transposes the array so
%   that legacy MATLAB code continues to work as before:
%
%       x(:,1)  -> all particles at timestep 1
%
%   This avoids having to refactor downstream MATLAB code when moving from .mat
%   files to NetCDF.

info = ncinfo(ncFile);

nc = struct();
nc.dims = struct();        % dimension names for each variable
nc.varAttributes = struct(); % variable-specific attributes

for iVar = 1:numel(info.Variables)
    var = info.Variables(iVar);
    fname = matlab.lang.makeValidName(var.Name);

    try
        % --- Read the variable from the NetCDF file ---
        vals = ncread(ncFile, var.Name);
        dimNames = {var.Dimensions.Name};

        % --- Legacy-compatible 2D transpose ---
        % MATLAB automatically reverses NetCDF dimension order due to column-major storage.
        % For 2D arrays (common for particle × time data), we transpose the array
        % so that existing MATLAB code (e.g., x(:,1)) works as expected.
        if ismatrix(vals) && numel(dimNames) == 2
            vals = vals.';           % transpose the array
            dimNames = fliplr(dimNames); % reverse dimension names to match MATLAB array
        end

        % --- Store the variable and metadata ---
        nc.(fname) = vals;
        nc.dims.(fname) = dimNames;
        nc.varAttributes.(fname) = attributes_to_struct(var.Attributes);

        % --- Optional CF-compliant time decoding ---
        if isfield(nc.varAttributes.(fname), 'units') && ...
           contains(lower(nc.varAttributes.(fname).units), 'since')
            try
                nc.(fname) = decode_cf_time(vals, nc.varAttributes.(fname));
            catch ME
                warning('CF time decode failed for %s: %s', fname, ME.message);
            end
        end

    catch ME
        warning('Could not read variable %s: %s', var.Name, ME.message);
    end
end

% --- Global attributes ---
nc.attributes = attributes_to_struct(info.Attributes);

end


function S = attributes_to_struct(attrs)
S = struct();
for i = 1:numel(attrs)
    name = matlab.lang.makeValidName(attrs(i).Name);
    S.(name) = attrs(i).Value;
end
end

function t = decode_cf_time(vals, attrs)
tokens = regexp(attrs.units, '(?<unit>\w+)\s+since\s+(?<epoch>.+)', 'names');
epoch = datetime(tokens.epoch,'TimeZone','UTC');

switch lower(tokens.unit)
    case 'seconds'
        t = epoch + seconds(double(vals));
    case 'minutes'
        t = epoch + minutes(double(vals));
    case 'hours'
        t = epoch + hours(double(vals));
    case 'days'
        t = epoch + days(double(vals));
    otherwise
        error('Unsupported CF time unit: %s', tokens.unit);
end
end