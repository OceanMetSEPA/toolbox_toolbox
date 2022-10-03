% The code below should be pasted into the startup.m file and configured.
%
% It defines paths to the master copy of the Fish Farm Database and also a
% local copy in a location that needs to be specified. This configuration
% means that MATLAB can be used to quickly and easily update the local copy
% of the database with respect to the master copy:
%
% >> FFDB.sync
%
% The 'dbpath' variable, below, represents the path to the local copy of the Fish 
% Farm Database and needs to be explcitly set for you machine. 
%
% e.g. dbpath = 'C:\Users\andrew.berkeley\Documents\Aquaculture\FishFarmDatabase.mdb'
%
% This path can represent the existing location of the database (if it exists locally) 
% or the location where the database should go (if it does not already exist). The first 
% time the FFDB.sync function is invoked, the file will be added to the local machine 
% if it does not already exist.
%
% The 'dbsyncpath' variable represents the path to the master copy of the
% database, and does not need changing.

%% PASTE THIS CODE INTO startup.m

% Check if FFDB exists and set path if so...
if size(what('FFDB'),1) > 0
    dbpath     = '<SET_THIS_PATH>';
    dbsyncpath = '\\sepa-fp-01\DIR SCIENCE\EAU\GIS\Data\SEPA\Fish_Farms\Fish Farm Database\FishFarmDatabase.mdb';
  
    FFDB.Connection.setPath(dbpath);
    FFDB.Connection.setSyncPath(dbsyncpath);
end
