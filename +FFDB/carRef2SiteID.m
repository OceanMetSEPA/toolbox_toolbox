function [ list ] = carRef2SiteID( carRef )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   carRef2SiteID.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:58  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a list of site ID's which are matched to the passed in
    % license refrence.
    %
    % If no results are found and empty array is returned.
    %
    %
    % Usage:
    %
    %    [ list ] = FFDB.carRef2SiteID(siteID);
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
    %   FFDB.carRef2SiteID('CAR/L/1003889')
    %   ans = 
    %     'KAN2'
    %     'KAN2'
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 

    cmd = ['select SITE_ID from CONSENT where [CAR Reference] = "', carRef, '"'];
    list = FFDB.query(cmd);
end

