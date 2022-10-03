function [ list ] = benthicStatusBySite( siteID )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   benthicStatusBySite.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:56  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a summary of the benthic status history associated with the passed in site
    % ID. Each status entry is represented by a row with the following
    % columns:
    %
    %   1.  Site ID
    %   2.  Biomass at time of survey
    %   3.  Status
    %   4.  Date of survey 
    %   
    % If no results are found and empty array is returned.
    %
    %
    % Usage:
    %
    %    [ list ] = FFDB.benthicStatusBySite(siteID);
    %
    % where:
    %    siteID is the site ID for a site in the Fish Farm Database.
    %
    %
    % OUTPUT:
    %    
    %   list: a cell array of query results.
    %
    %
    % EXAMPLES:
    %
    %  FFDB.benthicStatusBySite('KAN2')
    %    ans = 
    %     'KAN2'    [  0]    'Borderline'        '24/01/2014'
    %     'KAN2'    [  0]    'Satisfactory'      '24/01/2014'
    %     ...
    %     'KAN2'    [236]    'Borderline'        '28/07/2010'
    %     'KAN2'    [467]    'Unsatisfactory'    '28/07/2010'
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 

    cmd = ['SELECT [Site ID], [Biomass at time of survey (t)],[PASS / FAIL], [DATE RECEIVED] FROM MONITORING WHERE [Site ID] = "', siteID, '"'];
    list = FFDB.query(cmd);
end

