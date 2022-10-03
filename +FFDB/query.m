function [ result_set ] = query(str)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   query.m  $
% $Revision:   1.3  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns the result set of an arbitrary SQL query using the the
    % Fish Farm Database. If no results are found and empty array is
    % returned.
    %
    % Usage:
    %
    %    [ result_set ] = FFDB.query(str);
    %
    %    where:
    %      str is a string containing an SQL query
    % 
    %
    % OUTPUT:
    %    
    %    result_set: a cell array of query results.
    %
    % EXAMPLES:
    %
    %    FFDB.query('select [Site ID], [Biomass at time of survey (t)],[PASS / FAIL], [DATE RECEIVED] FROM MONITORING WHERE [Site ID] = "KAN2"')
    %    ans = 
    %      'KAN2'    [  0]    'Borderline'        '24/01/2014'
    %      'KAN2'    [  0]    'Satisfactory'      '24/01/2014'
    %      'KAN2'    [355]    'Unsatisfactory'    '21/03/2006'
    %       ...
    %      'KAN2'    [252]    'Borderline'        '08/03/2010'
    %      'KAN2'    [236]    'Borderline'        '28/07/2010'
    %      'KAN2'    [467]    'Unsatisfactory'    '28/07/2010'
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    % 
    
    conn     = FFDB.Connection.get;
    response = conn.Execute(str);
            
    if response.BOF && response.EOF
        result_set = [];
    else
        result_set = response.GetRows';
    end


end

