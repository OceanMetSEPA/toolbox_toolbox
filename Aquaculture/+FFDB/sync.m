function [ output_args ] = sync( input_args )
    % Synchronise a local copy of the Fish Farm database with the remote,
    % master copy represented by FFDB.Connection.syncPath()
    %
    % The local and remote paths can be set using:
    %
    %   FFDB.Connection.setPath('...')
    %   FFDB.Connection.setSyncPath('...')
    %
    % A useful place to defined these is in startup.m
    %
    
    copyfile(FFDB.Connection.syncPath, FFDB.Connection.path);
end

