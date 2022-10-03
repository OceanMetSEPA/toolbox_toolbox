function [ list ] = currentConsent( siteID )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   currentConsent.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:58  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a summary of the current license associated with the passed in site
    % ID. The current license is represented by the following columns:
    %
    %   1.  License number
    %   2.  Issue date
    %   3.  Status
    %   4.  Consented peak biomass 
    %   5.  Consented stocking density
    %   6.  Consented EmBZ MTQ
    %   7.  Consented EmBZ TAQ
    %   8.  Consented TFBZ TAQ
    %   9.  Consented Azimethiphos 3 hr
    %   10. Consented Azimethiphos 24 hr
    %   11. Consented Cypermethrin 3 hr
    %   12. Consented Deltamethrin 3 hr
    %   
    % If no results are found and empty array is returned.
    %
    %
    % Usage:
    %
    %    [ list ] = FFDB.currentConsent(siteID);
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
    %  FFDB.licenseHistoryBySite('KAN2')
    %     ans = 
    %         'CAR/L/1003889'    '30/04/2007'    'Active'        [1050]    [NaN]    [367.5]    [1837.5]    [28350]    [NaN]    [240]    [44.8]    [16.8]
    %    
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 
    
    cmd = ['select [CAR Reference], [Latest Variation], [CONSENT STATUS], BIOMASS, [EMA (MTQ)], [EMA(TAQ)], TFBZ, [AZI (3hr)], [AZI (24hr)], CYP, [Deltamethrin (g) (3hr)] from consent where SITE_ID = "', siteID, '" and [CONSENT STATUS] = "Active" order by [CONSENT STATUS]'];
    list = FFDB.query(cmd);
end

