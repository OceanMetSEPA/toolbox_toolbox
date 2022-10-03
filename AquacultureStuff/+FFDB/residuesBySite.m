function [ data ] = residuesBySite(site_ID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   residuesBySite.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:04:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns a summary of the chemical monitoring history associated with the passed in 
    % site ID. Each monitoring campaignentry is represented by a row with the following
    % columns:
    %
    %   1.  Site ID
    %   2.  Treatment type
    %   3.  Year
    %   4.  100 m replicate 1
    %   5.  100 m replicate 2
    %   6.  100 m replicate 3
    %   7.  Days between treatment and sampling
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
    %    FFDB.residuesBySite('KAN2')
    %     ans = 
    %         'KAN2'    'Emamectin Benzoate'    '2001/S1'     [NaN]    [NaN]    [NaN]    [NaN]
    %         'KAN2'    'Emamectin Benzoate'    '2007'        [NaN]    [NaN]    [NaN]    [116]
    %         'KAN2'    'Teflubenzuron'         '2011/S'      [NaN]    [NaN]    [NaN]    [ 29]
    %         ...
    %         'KAN2'    'Emamectin Benzoate'    '2013/W-s'    'ND'     'ND'     'ND'     [146]
    %
    % DEPENDENCIES:
    %
    %  - +FFDB/Connection.m
    %  - +FFDB/query.m
    % 
    
    fields    = {};
    fields{1} = 'Site_ID';
    fields{2} = 'Treatment';
    fields{3} = 'Year';
    fields{4} = 'EMA 100m replicate 1';
    fields{5} = 'EMA 100m replicate 2';
    fields{6} = 'EMA 100m replicate 3';
    fields{7} = 'Days between treatment and sample';

    fields = ['[',strjoin(fields,'],['),']'];
    
    cmd = ['SELECT ', fields, ' FROM residues'];
    
    if exist('site_ID','var')
        cmd = [cmd, ' WHERE Site_ID = "', site_ID, '"'];
    end

    data = FFDB.query(cmd);
end

