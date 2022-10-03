
%% Taken from Andy's startup.m script here:
% \\DSK004585\c$\Users\andrew.berkeley\Documents\MATLAB\startup.m

% Check if FFDB exists and set path if so...
ffDatabaseFile='FishFarmDatabase.accdb';
if size(what('FFDB'),1) > 0
    ffPath='\\asb-fp-mod01\AMMU\AquacultureModelling\Database';
%    ffPath='C:\CodeLibraryDev\Aquaculture';
    % 20201217- file in OPS folder no longer exists. Obsolete?
    %  dbpath     = 'C:\Data\FishFarmDatabase.mdb';
    %  dbsyncpath = '\\sepa-fp-01\ops\NATIONAL\AQUA\FishFarmDatabase\FishFarmDatabase.mdb';
    % Is it ok to use the same version for both setPath & setSyncPath? Hope so!
    dbpath=fullfile(ffPath,ffDatabaseFile);
    dbsyncpath=fullfile(ffPath,ffDatabaseFile);
    FFDB.Connection.setPath(dbpath);
    FFDB.Connection.setSyncPath(dbsyncpath);
end