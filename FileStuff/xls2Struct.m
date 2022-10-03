function [s,header]=xls2Struct(fileName,varargin)
% Load up an excel file and convert to a struct
%
% xls2Struct was developed help import data from an excel file. Matlab's
% inbuilt function:
% [num,txt,raw]=xlsread(f)
% divides the input into numeric, character or raw input. In order to relate the imported
% data to the original dataset, it is easiest to work with the raw input. However, the 'raw'
% input stores dates as strings which can have different lengths:
% '01/01/2001' % midnight at the millenium
% '01/01/2001 00:00:01' % one second later
%
% xls2Struct loads the 'raw' data and processes it, converting the data to
% a struct
%
% INPUT:
% fileName : Excel filename
%
% Optional Inputs:
% autoDate (true) - attempt to convert strings to datenums
% header (1)      - row containing header information (used to generate fieldnames)
% columns (0)     - specify columns to include (positive values) or exclude
%                   (negative). Default (0) is to load all columns
% rows (0)        - specify rows to include (positive values) or exclude
%                   (negative). Default is to load all rows. Note: the row indices include
%                   the header size
% fieldnames ([]) - specify either a cellstr of names to use as struct
%                   fieldnames, or a char which will be used as a stem.
% sheet (1)       - specify sheet of Excel file to load
% dateFormat      - formats of potential date strings. The date conversion
%                   is attempted using the 'datenumVariableFormat' function. This has a
%                   number of inbuilt formats it can convert, so you only need to use this
%                   argument if 'datenumVariableFormat' returns an error.
% array (false)   - attempt to convert single struct with fields of length N
%                   to struct array of length N with fields of length 1
% startDate (0)  - if date column found, restrict output to dates >= startDate
% endDate (inf)  - if date column found, restrict output to dates <= endDate
%
% OUTPUT:
% s      : struct containing excel data
% header : cell array containing header cells
%
% EXAMPLES:
% f='\\sepa-fp-01\DIR SCIENCE\EQ\Oceanmet\tools\Matlab\VDriveLibrary\PVCS\+AutoDepomod\+Test\Fixtures\Gorsten\depomod\surfer\CHEM_TEMPLATE.XLS'
% xls2Struct(f) % loads struct with fields 'Easting','Northing','angle','scale','symbol' and 'note'. Each field has 11 values
% xls2Struct(f,'column',1:3) % include first 3 columns
% xls2Struct(f,'column',-6) % excluce 'note'
% [s,header]=xls2Struct(f,'fieldname','SEPA_Col') % fieldnames now 'SEPA_Col1', 'SEPA_Col2' etc
% xls2Struct(f,'header',0) % fieldnames no longer obtained from row 1, so are called 'Column1', 'Column2' etc. Now there are 12 values in each field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   xls2Struct.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   Jun 03 2016 14:14:54  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    help xls2Struct
    return
end
options=struct;
options.autoDate=true;
options.dateCol=[];
options.header=1; % row(s) containing header
options.verbose=false; % Spout out lots of messages...
options.columns=0; % 0 = all
options.rows=0;
options.fieldnames=[];
options.sheet=1;
options.dateFormat={'dd/mm/yyyy','dd/mm/yyyy HH:MM:SS'};
options.array=false;
options.startDate=0;
options.endDate=inf;
options=checkArguments(options,varargin);
% read excel file.
[~,~,xlsCellArray]=xlsread(fileName,options.sheet);
% Remove rows/columns where all values are NaNs (not sure where they
% come we don't need them)
xlsCellArray=rmNaNsFromCellArray(xlsCellArray);
% Remove unwanted columns. We do this before we process header
xlsCellArray(:,~vectorFilter(size(xlsCellArray,2),options.columns))=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract header
headerRows=options.header;
header=[];
if ~isnumeric(headerRows)
    error('Header row must be numeric value (default = 1)')
end
if all(headerRows>0)
    header=xlsCellArray(headerRows,:); % extract header rows
end
Nrow=size(xlsCellArray,1);
% Might want to filter rows...
rows2Keep=vectorFilter(Nrow,options.rows);%
if ~isempty(header) % And if we found a header, remove that from data set
    rows2Keep=rows2Keep & ~vectorFilter(Nrow,headerRows);
end
xlsCellArray=xlsCellArray(rows2Keep,:);
% Right, what's left of our raw data should be everything we want to keep
[Nrow,Ncol]=size(xlsCellArray);
if options.verbose
    fprintf('Data size = %d x %d\n',Nrow,Ncol);
end
% Prepare some fieldnames for our struct. Either:
% 1) specified in input arguments
% 2) based on header
% 3) generic name if neither of the above specified
sFieldNames=cell(Ncol,1);
if ~isempty(options.fieldnames) % generate fieldnames based on input options
    if ischar(options.fieldnames)
        sFieldNames=arrayfun(@(x)sprintf('%s%d',options.fieldnames,x),1:Ncol,'Unif',0);
    elseif iscellstr(options.fieldnames)
        sFieldNames=options.fieldnames;
    end
elseif ~isempty(header) % generate fieldnames based on header
    for i=1:Ncol
        si=header(:,i);
        si(cellfun(@(x)all(isnan(x)),si))=[];
        si=sprintf('%s_',si{:});
        if isempty(si)
            si=sprintf('Column%d',i);
        else
            si(end)=[];
        end
        sFieldNames{i}=genvarname(si);
    end
else % just a generic name
    sFieldNames=arrayfun(@(x)sprintf('Column%d',x),1:Ncol,'Unif',0);
end
if length(sFieldNames)~=Ncol
    error('Mismatch in number of struct fieldnames; should have %d',Ncol)
end
if options.verbose
    fprintf('%d Fieldnames:\n',length(sFieldNames))
    disp(sFieldNames)
end
% Create a struct to store our data
s=struct;
dateCol=options.dateCol;
for i=1:Ncol
    %%%%%%%%%%%%%%%%%%%%%
    iColumnData=xlsCellArray(:,i); % Data for i'th column
    % Determine classes of column data:
    dataIsChar=cellfun(@ischar,iColumnData);
    dataIsNumeric=cellfun(@isnumeric,iColumnData);
    % Tinker with data depending on class of its elements
    if ~any(dataIsChar)
        % If none of the column elements are chars, convert to matrix
        iColumnData=cell2mat(iColumnData);
    elseif all(dataIsChar) % all chars? Then convert to cell array
        iColumnData=cellstr(iColumnData);
    elseif all(dataIsChar|dataIsNumeric)
        % Columns with numeric values and NaNs read in as mixture of classes
        % (numeric and char (for NaNs))
        % if column data a mixture of chars and numerics, convert NaN strings
        % to numeric, then try to convert from cell to mat:
        iColumnData(cellfun(@(i)isequal(upper(i),'NAN'),iColumnData))={NaN};
        try
            iColumnData=cell2mat(iColumnData);
        catch
            % oh well, leave as cell array
        end
    end
    % Now consider dates...
    if isequal(sFieldNames{i},dateCol) % field is specified date column?
        try
            iColumnData=datenumVariableFormat(iColumnData,options.dateFormat);
        catch
            dateCol=[];
        end
    elseif options.autoDate && iscell(iColumnData)
        try
            iColumnData=datenumVariableFormat(iColumnData,options.dateFormat);
            dateCol=sFieldNames{i};
            if options.verbose
                fprintf('Column %d converted to date!\n',i)
            end
        catch
            % Leave as cell array if attempt to convert to datenum failed
        end
    end
    % Add data to struct:
    s.(sFieldNames{i})=iColumnData;
end

if ~isempty(dateCol)
    try
        k=s.(dateCol)>=datenumVariableFormat(options.startDate) & s.(dateCol)<=datenumVariableFormat(options.endDate);
        if ~all(k)
            s=structFilter(s,k);
        end
    catch err
        disp(err.message)
        error('Problem filtering dates; please check date options')
    end
end
if options.array
    try
        s=struct2struct(s);
    catch
        warning('Unable to convert to struct array')
    end
end

    function [ k ] = vectorFilter(N,f)
        % Specify values to include (positive) or exclude (negative)
        % Inputs
        %  N, number of values
        %  f: positive (include these) OR
        %     negative (exclude these) OR
        %     0 or [] - keep all
        k=true(N,1);
        if isempty(f)
            return
        elseif ~isequal(f,0)
            if all(f>0)
                k=~k;
                k(f)=true;
            elseif all(f<0)
                k(-f)=false;
            end
        end
    end

    function [ cellArray ] = rmNaNsFromCellArray(cellArray)
        % Delete all rows/columns from a cell array consisting entirely of NaNs
        %
        % Raw data obtained using 'xlsread' function:
        % [numData,txtData,rawData]=xlsread(xlsFile)
        %
        % rawData sometimes has rows/columns entireley of NaNs (?!) making it
        % larger than necessary. This function cleans it up
        %
        % INPUT: cellArray
        % OUTPUT: cellArray with NaN columns / rows removed
        %
        % EXAMPLE:
        % x=num2cell([NaN,NaN,NaN,pi;1,NaN,3,4;NaN,NaN,NaN,NaN;5,NaN,6,8])
        % rmNaNsFromCellArray(x) % removes 3rd row, 2rd column
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % $Workfile:   rmNaNsFromCellArray.m  $
        % $Revision:   1.0  $
        % $Author:   ted.schlicke  $
        % $Date:   Apr 08 2014 14:02:50  $
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if nargin==0
            help rmNaNsFromCellArray
            return
        end
        
        cellIsNan=cellfun(@(x)all(isnan(x)),cellArray,'Uniform',false);
        [Nrow,Ncol]=size(cellIsNan);
        cols2Keep=~arrayfun(@(x)all([cellIsNan{:,x}]),1:Ncol);
        rows2Keep=~arrayfun(@(x)all([cellIsNan{x,:}]),1:Nrow);
        cellArray=cellArray(rows2Keep,cols2Keep);
        
    end


end
