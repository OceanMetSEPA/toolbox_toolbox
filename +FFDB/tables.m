function [ tableNames ] = tables()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   tables.m  $
% $Revision:   1.3  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a list of table names associated with the Fish Farm Database.
    %
    % Usage:
    %
    %    tables = FFDB.tables;
    %
    % OUTPUT:
    %    
    %    tableNames: a cell array of table names.
    %
    % EXAMPLES:
    %
    %    FFDB.tables
    %    ans = 
    %           'ADDRESS'
    %           'ANNUAL SPRI DATA'
    %           'ARCHIVE_MONITORING_110721'
    %           'AllChemicals'
    %           ...
    %           '{IMPORT} MONTHLY DATA'
    %           '{IMPORT} MONTHS'
    %           '{LOG} IMPORT FILES'
    %
    % DEPENDENCIES:
    %
    %  - +ADO/tables.m
    %  - +FFDB/Connection.m
    % 
    
    conn = FFDB.Connection.get;
    tableNames = ADO.tables(conn);

end

