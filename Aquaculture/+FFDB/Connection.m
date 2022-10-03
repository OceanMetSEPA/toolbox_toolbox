classdef (Sealed) Connection < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   Connection.m  $
% $Revision:   1.4  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 13:03:58  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Singleton class for representing a local connection to the "Fish
    % Farm" MS Access database. 
    %
    % This class provides an interface for specifying the location 
    % of the database file and for accessing the ADO connection object. The
    % latter functionality is used by the query functions in the FFDB
    % package and should not normally be needed directly.
    %
    % A useful pattern is to set the database location in the MATLAB
    % startup.m script, as follows:
    %
    %   % Check if FFDB exists and set path if so...
    %   if size(what('FFDB'),1) > 0
    %       dbpath= 'C:\Users\andrew.berkeley\Documents\Aquaculture\FishFarmDatabase.mdb';
    %       FFDB.Connection.setPath(dbpath);
    %   end
    % 
    % Once the connection path is set (as above), any other function within the 
    % FFDB package connect to the database automatically.
    %
    % Examples:
    %
    %   FFDB.setPath('C:\...\...\my_database.accdb')
    %
    %   conn = FFDB.Connection.get
    %   conn =
    %     COM.ADODB_Connection
    %
    % DEPENDENCIES:
    %
    %  - +ADO/connection.m
    % 
    
    methods (Access = private)
        function obj = Connection()
        end
    end
   
    methods (Static = true)
        function singleObj = get()
            % Static method for returning the singleton instance of
            % FFDB.Connection
            
            % Persist variable through subsequent calls
            persistent localObj; 
            
            % Establish connection is doesn't already exist, i.e. on first
            % method call
            if isempty(localObj)
                localObj = ADO.connection(FFDB.Connection.path);
            end
            
            % Return connection object
            singleObj = localObj;
        end
        
        function setPath(pathToDB)
            % Define the path which represents the local copy of the Fish
            % Farm Database
            
            setenv('FISH_FARM_DB', pathToDB);
        end
        
        function p = path
            % Returns the path which represents the local copy of the Fish
            % Farm Database
            
            p = getenv('FISH_FARM_DB');
        end
        
        function setSyncPath(pathToDB)
            % Define the path which represents the remote, master copy of the Fish
            % Farm Database
            
            setenv('FISH_FARM_DB_SYNC', pathToDB);
        end
        
        function p = syncPath
            % Returns the path which represents the remote, master copy of the Fish
            % Farm Database
            
            p = getenv('FISH_FARM_DB_SYNC');
        end
   end
end

