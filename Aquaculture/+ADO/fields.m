function [ tableColumns ] = fields(conn, tableName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   fields.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:22  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Returns a list of column names associated with a specific database table.
    %
    % Usage:
    %
    %    columns = ADO.fields(conn, tableName);
    %
    %    where:
    %      conn is an ActiveX ADODBconnection object (see ADO.connection)
    %      tableName is the name of the database table
    % 
    %
    % OUTPUT:
    %    
    %    tableColumns: a cell array of table column names.
    %
    % EXAMPLES:
    %
    %    conn = ADO.connection('c:\project\data\database.accdb');
    %    ADO.fields(conn, 'MONTHLY DATA')
    %      ans = 
    %           'Azamethiphos'
    %           'Biomass'
    %           'Company'
    %           ...
    %           'Status'
    %           'Teflubenzuron'
    %
    % DEPENDENCIES:
    %
    %  - +ADO/connection.m
    % 
        
    cols = conn.OpenSchema('adSchemaColumns').GetRows;
    tableColumns = cols(4,ismember(cols(3,:),tableName))';
end

