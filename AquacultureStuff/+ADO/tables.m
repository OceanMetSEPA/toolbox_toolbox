function [ tableNames ] = tables(conn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   tables.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:22  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Returns a list of table names associated with a relational database.
    %
    % Usage:
    %
    %    tables = ADO.tables(conn);
    %
    %    where:
    %      conn is an ActiveX ADODBconnection object (see ADO.connection)
    %
    % OUTPUT:
    %    
    %    tableNames: a cell array of table names.
    %
    % EXAMPLES:
    %
    %    conn = ADO.connection('c:\project\data\database.accdb');
    %    ADO.tables(conn)
    %      ans = 
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
    %  - +ADO/connection.m
    % 
        
    tableSchema = conn.OpenSchema('adSchemaTables').GetRows;
    tableNames  = tableSchema(3, ismember(tableSchema(4,:),'TABLE') );
    
    tableNames = sort(tableNames');
end

