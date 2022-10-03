function op=findDuplicateMFiles(varargin)
% Find duplicate .m files (scripts/functions) in path
% i.e. files with the same name in different directories.
%
% These can be problematic, as the script version that is actually called may be different from the intented one,
% e.g. an older version. (The version which is called is determined by the directory order in the path).
%
% OPTIONAL INPUTS:
% 'ignore' [{'examples.m','Contents.m','help.m'}]. Ignore any duplicates containing
%                        this string. Lots of 'Contents.m' files which
%                        probably isn't a problem
%
% 'package' [true] - include files in matlab packages (directories which start with '+'
%
% OUTPUT:
%   [] if no duplicates found. Otherwise,
%   struct whose fieldnames are the duplicate script names, minus the
%   extension. Each field contains a cell array containing the full path of
%   the script.
%
% EXAMPLE:
% findDuplicateMFiles('ignore','tmp') % find duplicates not containing 'tmp' string
%
% Aside: you can determine which version of a file is being used by calling the
% 'which' function, e.g.:
%
% which mean
% which('mean')
% 


options=struct;
options.ignore={'examples.m','Contents.m','help.m'};
options.package=true;
options=checkArguments(options,varargin);
scripts2Ignore=options.ignore;

% Find .m files
p=strsplit(path,';');
fprintf('Finding .m files...\n')
% NB if options.package, we look through subdirectories to ensure we get
% files in packages (e.g. +Depomod);
scriptsFullPath=fileFinder(p,'.m','type','end','sub',options.package,'not','tmp');
fprintf('%d .m files found\n',length(scriptsFullPath))

f=unique(scriptsFullPath);
% f(contains(f,'Program Files'))=[];

f(contains(f,scripts2Ignore))=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Crop files for comparison. For 'normal' files, we just need to remove the
% path. For files within packages we want to keep package name since the
% same .m file within different packages isn't a duplicate
Nf=length(f);
scriptsCropped=cell(Nf,1);
for fileIndex=1:Nf
    fi=f{fileIndex};
    plusIndex=regexp(fi,'+');
    if ~isempty(plusIndex)
        scriptsCropped{fileIndex}=fi(plusIndex:end);
    else
        scriptsCropped{fileIndex}=strcat(filesep,removePath(fi));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use tally function to find duplicate scripts:
duplicateTable=tally(scriptsCropped,'duplicate',1);
duplicateScripts=duplicateTable(1,:)'; % First row has script
NDuplicateScripts=length(duplicateScripts); % Number of duplicate scripts

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through duplicates and generate struct with path/time information of
% duplicates:
if NDuplicateScripts>0
    fprintf('Duplicate script name(s) found!\n')
    % OK, now we prepare a struct containing info about any duplicates.
    % fieldnames: name of duplicate script (minus .m - matlab doesn't like dots in fieldnames)
    % fields:     full path to each duplicate script name
    op=struct;
    for scriptIndex=1:NDuplicateScripts
        dsi=duplicateScripts{scriptIndex}; % script name, complete with .m
        % Find full paths with this script name
        duplicateStringsWithPath=f(contains(f,dsi));
        % If duplicates are built-in matlab functions, don't worry about
        % it. Presumably mathworks knows what it's doing
        if all(contains(duplicateStringsWithPath,matlabroot))
            continue
        end
        
        NDuplicates=length(duplicateStringsWithPath);
        dsModTimes=NaN(NDuplicates,1);
        for duplicateIndex=1:NDuplicates
            jinfo=dir(duplicateStringsWithPath{duplicateIndex});
            dsModTimes(duplicateIndex)=jinfo.datenum;
        end
        [~,o]=sort(dsModTimes); % Sort by modification time
        ds=cellstr(datestr(dsModTimes(o))); % Date string more informative to user than datenum
        ops=[duplicateStringsWithPath(o),ds];
        fn=strrep(dsi,'.m','');
        ind=regexp(fn,filesep);
        ind=ind(end);
        fn=fn(ind+1:end);
        fn=genvarname(fn);
        op.(fn)=ops;
        [numD, ~] = size(ops);
        fprintf('Script ''%s'' (duplicate %d of %d) found %d times:\n',dsi,scriptIndex,NDuplicateScripts,numD)
        fprintf('    Modification Date    - Location\n')
        for dI = 1:numD
            fprintf('    %20s - %s\n', ops{dI, 2}, ops{dI, 1})
        end
        %disp(ops)
    end
else
    fprintf('*** No duplicates detected ***\n')
    op=[];
end
