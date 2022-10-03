function [ conn ] = connection( path ) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   connection.m  $
% $Revision:   1.6  $
% $Author:   andrew.berkeley  $
% $Date:   Apr 25 2014 14:18:14  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Returns an Active-X ADO connection object for an MS Access database. 
    % 
    % Usage: 
    % 
    %    conn = ADO.connection(path); 
    %  
    % 
    % OUTPUT: 
    %     
    %    conn: an Active X ADO connection object. 
    % 
    % EXAMPLES: 
    % 
    %    conn = ADO.connection('c:\project\data\database.accdb'); 
    %    
     % Ted test change
	 
    conn = actxserver('ADODB.Connection'); 
    connString = ['Provider=Microsoft.Ace.OLEDB.12.0;Data Source=',path,';']; 
    conn.Open(connString); 
end 
 
       