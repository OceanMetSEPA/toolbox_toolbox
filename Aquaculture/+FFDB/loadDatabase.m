function ffdb=loadDatabase(fromMatfile)
% Load entire FF database into struct
% First of all, try to load from matfile
% If that fails (no matfile?) then load from individual tables
%
% Note:
% function FFDB.accdb2mat will generate matfile, and will check if matfile
% needs to be updated (because matfile corresponds to old version of
% database file

if nargin==0
    fromMatfile=true;
end

FFDB.setup
accdbFile=FFDB.Connection.syncPath;
ffdbMatFile=strrep(accdbFile,'.accdb','.mat');
if fromMatfile
    try
        fprintf('Trying to read matfile...\n')
        %    ffdb=importdata(ffdbMatFile); % 30s
        % faster to use load than importdata
        tmp=load(ffdbMatFile); % 11s
        ffdb=tmp.ffdb;
        return
    catch
        fprintf('Failed to read matfile :-(\n')
    end
end

ffdb=struct;
ffdbTables=FFDB.tables;
Nt=length(ffdbTables);
for tableIndex=1:Nt
    %    fprintf('%d of %d...\n',tableIndex,Nt)
    itable=ffdbTables{tableIndex};
    tableData=FFDB.tableData(itable);
    ffdb.(genvarname(itable))=tableData;
end


