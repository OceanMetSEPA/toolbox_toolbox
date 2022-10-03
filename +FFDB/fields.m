function [ tableColumns ] = fields( tableName )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   fields.m  $
% $Revision:   1.4  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:58  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a list of column names associated with a specific table in the
    % Fish Farm Database.
    %
    % Usage:
    %
    %    tableColumns = FFDB.fields(tableName);
    %
    %    where:
    %      tableName is the name of the Fish Farm Database table
    % 
    %
    % OUTPUT:
    %    
    %    tableColumns: a cell array of table column names.
    %
    % EXAMPLES:
    %
    %    FFDB.fields('MONTHLY DATA')
    %    ans = 
    %           'Azamethiphos'
    %           'Biomass'
    %           'Company'
    %           ...
    %           'Status'
    %           'Teflubenzuron'
    %
    % DEPENDENCIES:
    %
    %  - +ADO/fields.m
    %  - +FFDB/Connection.m
    % 
    
    conn = FFDB.Connection.get;    
    tableColumns = ADO.fields(conn, tableName);    
end

