function [ list ] = sliceConsentByCarRef(carRef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   sliceConsentByCarRef.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a summary of the EmBZ consent history associated with the passed in license 
    % reference. Each monthly entry is represented by a row with the following
    % columns:
    %
    %   1.  License issue date
    %   2.  Site ID
    %   3.  License reference
    %   4.  License status
    %   5.  EmBZ TAQ
    %   6.  EmBZ MTQ
    %   7.  TAQ/MTQ ratio
    %   
    % If no results are found and empty array is returned.
    %
    %
    % Usage:
    %
    %    [ list ] = FFDB.sliceConsentByCarRef(carRef);
    %
    % where:
    %    carRef is a license reference in the Fish Farm Database.
    %
    %
    % OUTPUT:
    %    
    %   list: a cell array of query results.
    %
    %
    % EXAMPLES:
    %
    %   FFDB.sliceConsentByCarRef('CAR/L/1003889')
    %   ans = 
    %     '30/04/2007'    'KAN2'    'CAR/L/1003889'    'Active'        [1837.5]    [367.5]    [  5]
    %     '30/05/2001'    'KAN2'    'CAR/L/1003889'    'Superceded'    [  1838]    [  NaN]    [NaN]
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 

    cmd = ['select [ISSUE DATE], SITE_ID, [CAR Reference], [CONSENT STATUS],[EMA(TAQ)],[EMA (MTQ)],[EMA(TAQ)]/[EMA (MTQ)] from CONSENT where [CAR Reference] = "', carRef, '"'];
    list = FFDB.query(cmd);
end

