function tableData = tableData(tableName)
% Download data in table from Fish Farm database
%
% This is cluckier than perhaps it should be, because while the data can be
% downloaded 'as-is' from the database, the column names are sorted
% alphabetically.
%
% So our method is to:
% 1) download all data into 2d cell array
% 2) find column names
% 3) download data for column names in turn. Match this data to column in
% step 1
% 4) reorder column names accordingly and generate struct
%
% INPUT:
% tableName - name of table whose data you want (list of valid tables can
%             be found calling FFDB.tables
%
% OUTPUT:
% tableData - struct containing table data
%
% EXAMPLE:
% FFDB.tableData('cages') % get table containing cage coordinates and dimensions
%
% Dependencies:
%   closestStringMatch.m
%   struct2struct.m

if nargin==0
    help FFDB.tableData
    return
end


% NB : query to download is case-insensitive, but query to get fieldnames is
% case sensitive. So we do a preliminary check...
%

%
%

% Find valid table names:
ffdbTableNames=FFDB.tables;
nameCheck=closestStringMatch(ffdbTableNames,tableName);
if isempty(nameCheck)
    error('Table ''%s'' not found',tableName)
elseif length(nameCheck)>1
    disp(nameCheck)
    error('Table ''%s'' ambiguous',tableName)
end
tableName=char(nameCheck);
%fprintf('Getting data for table ''%s''\n',tableName)
% This gets data but not column names:
try
    cmd=sprintf('select * from [%s]',tableName);
    tableData=FFDB.query(cmd);
%    fprintf('Found %d rows and %d columns of data\n',size(tableData))
catch err
    disp(err)
    fprintf('Error with query ''%s''\n',cmd)
    error('Problem downloading table ''%s''',tableName)
end
% Find fieldnames- unfortunately these are ordered alphabetically rather
% than as ordered in table:
fieldNames=FFDB.fields(tableName);
if isempty(tableData)
%    warning('No table data!')
    tableData=struct;
    for fieldIndex=1:length(fieldNames)
        tableData.(genvarname(fieldNames{fieldIndex}))=[];
    end
    return
end

% Match individual columns to raw data
NColumns=length(fieldNames);
colMap=NaN(1,NColumns);
for columnIndex=1:NColumns
    fieldName=fieldNames{columnIndex};
    cmd=sprintf('select [%s] from [%s]',fieldName,tableName);
    fieldData=FFDB.query(cmd);
    k=find(arrayfun(@(i)isequaln(fieldData,tableData(:,i)),1:NColumns));
    if isempty(k)
        error('Match not found for column ''%s'' :-(',fieldName)
    elseif length(k)>1
%        warning('Ambiguous data for column ''%s''!',fieldName)
        k=k(1); % Hopefully this is just because they're all nan 
    end
    %    fprintf('''%s'' corresponds to column %d of raw data\n',fieldName,k)
    colMap(columnIndex)=k;
end

% Generate struct with column names ordered as per database
[~,columnOrder]=sort(colMap);
tableData=cell2struct(tableData',genvarname(fieldNames(columnOrder)));
tableData=struct2struct(tableData);

end

