function [ list ] = licenseHistoryBySite( siteID )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   licenseHistoryBySite.m  $
% $Revision:   1.5  $
% $Author:   andrew.berkeley  $
% $Date:   Jun 24 2014 12:05:04  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a summary of the license history associated with the passed in site
    % ID. Each license variation is represented by a row with the following
    % columns:
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
    %    [ list ] = FFDB.licenseHistoryBySite(siteID);
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
    %         'CAR/L/1003889'    '30/05/2001'    'Superceded'    [1050]    [NaN]    [  NaN]    [  1838]    [28350]    [NaN]    [240]    [  16]    [ NaN]
    %    
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 
    
%     cmd = ['select [CAR Reference], [Issue Date], [CONSENT STATUS], BIOMASS, [Stocking Density (kg/m3)], [EMA (MTQ)], [EMA(TAQ)], TFBZ, [AZI (3hr)], [AZI (24hr)], CYP, [Deltamethrin (g) (3hr)], [Expiry Date] from consent where SITE_ID = "', siteID, '" order by [CONSENT STATUS]'];
    cmd = ['select [CAR Reference], [Latest Variation], [CONSENT STATUS], BIOMASS, [Stocking Density (kg/m3)], [EMA (MTQ)], [EMA(TAQ)], TFBZ, [AZI (3hr)], [AZI (24hr)], CYP, [Deltamethrin (g) (3hr)], [Expiry Date] from consent where SITE_ID = "', siteID, '" order by [Latest Variation] DESC, [CONSENT STATUS]'];
    list = FFDB.query(cmd);
    
    if ~isempty(list)
    
        % There is an idiosyncracy with the CONSENT table. New variations
        % continue to use the same Issue Date as the original license, but the
        % variation date is stored, confusingly, in the Expiry Date column. We
        % prefer to have a simply timeline of changes so we only want to return
        % either one of the issue date or variation date (the CAR license reference 
        % is also returned so it should be clear when a change is a variation).
        %
        % Here we want to replace issue dates with variation dates where
        % appropriate.

        % identify entries with variation dates
        entriesWithVariationDates = cellfun(@(x) ~isequal(isnan(x),1), list(:,13));

        % replace issue dates with variation dates where appropriate
        list(entriesWithVariationDates,2) = list(entriesWithVariationDates,13);

        % remove variation date column
        list(:,13) = [];
    end
end

