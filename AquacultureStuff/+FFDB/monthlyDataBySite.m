function [ list ] = monthlyDataBySite( siteID )
    % Returns a summary of the monthly returns associated with the passed in site
    % ID. Each monthly entry is represented by a row with the following
    % columns:
    %
    %   1.  Month
    %   2.  Biomass
    %   3.  EmBZ used
    %   4.  TFBZ used
    %   5.  Azimethiphos used
    %   6.  Cypermethrin used
    %   7.  Deltamethrin used
    %   8.  Feed used
    %   
    % If no results are found and empty array is returned.
    %
    %
    % Usage:
    %
    %    [ list ] = FFDB.monthlyDataBySite(siteID);
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
    %  FFDB.monthlyDataBySite('KAN2')
    %  ans = 
    %     '01/11/2002'    [381]    [      0]    [    0]    [   0]    [    0]    [    0]
    %     '01/12/2002'    [322]    [      0]    [    0]    [   0]    [    0]    [    0]
    %     ...
    %     '01/10/2013'    [ 30]    [   9.45]    [    0]    [   0]    [    0]    [    0]
    %     '01/11/2013'    [ 53]    [      0]    [    0]    [   0]    [    0]    [    0]
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 

    cmd = ['select Month, Biomass,[Emamectin Benzoate], Teflubenzuron, Azamethiphos, Cypermethrin, Deltamethrin, Feed from [MONTHLY DATA] where Site_ID = "', siteID, '"'];
    list = FFDB.query(cmd);
end