function nc = nc2struct(ncFile,transposeValues)

%NC2STRUCT Read a NetCDF file into a MATLAB struct with metadata handling
%
%   nc = NC2STRUCT(ncFile)
%   nc = NC2STRUCT(ncFile, transposeValues)
%
%   Reads all variables, dimensions and attributes from a NetCDF file into
%   a MATLAB struct. The function is designed for interoperability with
%   Python/xarray-generated NetCDF files and optionally reconstructs sparse
%   matrices stored in COO format.
%
%   INPUTS:
%       ncFile           - Path to NetCDF file
%       transposeValues  - Logical flag (default = true). If true, numeric
%                          arrays are transposed to match MATLAB's column-
%                          major conventions and legacy data layouts.
%
%   OUTPUT:
%       nc               - Struct containing:
%           nc.(var)                 Variable values
%           nc.dims.(var)           Dimension names for each variable
%           nc.varAttributes.(var)  Variable attributes (struct)
%           nc.attributes           Global file attributes
%
%   FEATURES:
%       - Reads all variables using ncread
%       - Stores dimension metadata alongside each variable
%       - Converts NetCDF attributes into MATLAB structs
%       - Automatically decodes CF-compliant time variables
%         (e.g. "hours since 2000-01-01") into datetime arrays
%       - Reconstructs sparse matrices stored in xarray/COO format using:
%             var_coords, var_data, var_shape
%       - Converts 0-based Python indices to MATLAB 1-based indexing
%
%   SPARSE VARIABLES:
%       If the global attribute "sparse" is present and true, variables
%       stored in coordinate (COO) format are automatically reconstructed
%       into MATLAB sparse matrices.
%
%   NOTES:
%       - Scalar NetCDF variables may not be fully supported by all
%         downstream processing (e.g. transposeStruct)
%       - Object or unsupported NetCDF datatypes may trigger warnings
%       - Variable names are converted using matlab.lang.makeValidName
%
%   EXAMPLE:
%       nc = nc2struct('output.nc');
%
%   See also: ncinfo, ncread, sparse, datetime

info = ncinfo(ncFile);

if nargin<2
    transposeValues=1;
end

nc = struct();
nc.dims = struct();
nc.varAttributes = struct();

% --- Global attributes first ---
nc.attributes = attributes_to_struct(info.Attributes);

isSparse = isfield(nc.attributes,'sparse') && nc.attributes.sparse == 1;

% Track variables to skip (internal sparse storage)
%skipVars = {};

for iVar = 1:numel(info.Variables)
    var = info.Variables(iVar);
    fname = matlab.lang.makeValidName(var.Name);

    % Skip internal sparse components (handled later)
    if endsWith(var.Name, {'_coords','_data','_shape','_dims'})
%        skipVars{end+1} = var.Name;
        continue
    end

    try
        % --- Read normally first ---
        vals = ncread(ncFile, var.Name);
        dimNames = {var.Dimensions.Name};

        nc.(fname) = vals;
        nc.dims.(fname) = dimNames;
        nc.varAttributes.(fname) = attributes_to_struct(var.Attributes);

        % --- CF time decoding ---
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

% ============================================================
% --- RECONSTRUCT SPARSE VARIABLES ---
% ============================================================
if isSparse

    varNames = {info.Variables.Name};

    % Find base variable names (before _coords, etc.)
    baseVars = unique(regexprep(varNames, '_(coords|data|shape|dims)$',''));

    for i = 1:numel(baseVars)
        v = baseVars{i};

        % Check required components exist
        if all(ismember({[v '_coords'], [v '_data'], [v '_shape']}, varNames))

            try
                coords = ncread(ncFile, [v '_coords']);
                data   = ncread(ncFile, [v '_data']);
                shape  = ncread(ncFile, [v '_shape']);

                % Ensure coords is 2 x nnz
                if size(coords,1) ~= 2 && size(coords,2) == 2
                    coords = coords';  % transpose if needed
                end

                if size(coords,1) ~= 2
                    error('Invalid coords shape for %s', v)
                end

                % Convert from 0-based (Python) → 1-based (MATLAB)
                rows = coords(1,:) + 1;
                cols = coords(2,:) + 1;

                % Ensure vectors are column vectors
                rows = rows(:);
                cols = cols(:);
                data = data(:);

                % Final safety check
                if ~(numel(rows) == numel(cols) && numel(rows) == numel(data))
                    error('coords/data size mismatch for %s', v)
                end

                % Rebuild sparse matrix
                S = sparse(rows, cols, data, shape(1), shape(2));
                fname = matlab.lang.makeValidName(v);
                nc.(fname) = S;

                % Optional: restore dims if available
                if ismember([v '_dims'], varNames)
                    dims_raw = ncread(ncFile, [v '_dims']);
                    nc.dims.(fname) = cellstr(dims_raw');
                end

            catch ME
                warning('Failed to reconstruct sparse variable %s: %s', v, ME.message);
            end
        end
    end
end

% ============================================================
% --- Final transpose for MATLAB legacy behaviour ---
% ============================================================
if transposeValues
    nc = transposeStruct(nc);
end

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
if isempty(tokens)
    error('Failed to parse CF time units: %s', attrs.units)
end
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

function s=transposeStruct(s,varargin)

options=struct;
options.field2flip='dateTime';
options.dim=2;
options=checkArguments(options,varargin);

if ~isstruct(s)
    error('expected struct input');
end

fn=fieldnames(s);
Nf=length(fn);

if isfield(s,options.field2flip)
    Nt=length(s.(options.field2flip));
else
    Nt=1;
end

for fieldIndex=1:Nf
    fni=fn{fieldIndex};
    vals=s.(fni);
    if ~isnumeric(vals)
        continue
    end
    valSize = size(vals);

    isMatrix = numel(valSize)==2 && all(valSize>1);
    if isMatrix
        if valSize(options.dim) ~= Nt
            s.(fni) = vals.';
        end
    end
end
end

