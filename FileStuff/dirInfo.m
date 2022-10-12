function diStructArray = dirInfo( f ,varargin)
% call matlab 'dir' function on multiple files / directories
% Options to sort resulting struct array by name, size or date modified
%
% INPUT:
% f [] - file/directory, or cellstr of them
%
% Optional Inputs:
% sortOption [] - unique identifier for 'size','date' or 'name'
% directionOption [] - unique identifier for 'ascending' or 'descending'
%
% OUTPUT:
% struct array with fields:
%     name % file/directory with path removed
%     folder % path
%     date % date string
%     bytes % size in bytes (NB directories have size zero)
%     isdir % is it a directory?
%     datenum % of modification
%     sizeLabel % string describing size (in bytes, KB, MB etc)
%     fullfile % =fullfile(folder,name)
%
% EXAMPLES:
% dirInfo(userMatlabPaths) % all files within path
% dirInfo(pwd,'size','des') % contents of pwd, from big to small

if nargin<1
    help dirInfo
    return
end
%
% Check input arguments. We can order by:
% 1) name (alphabetical order)
% 2) date (modified)
% 3) size
% And we can arrange in direction:
% 1) ascending (A-Z, old-new, small-big)
% 2) descending (Z-A, new-old, big-small)
% If neither is set, we leave order as how dir function returns them
if ~isempty(varargin)
    sortOptions={'size','date','name'};
    directionOptions={'ascending','descending'};
    k=contains(sortOptions,varargin);
    switch sum(k)
        case 0
            warning('No valid input for sorting')
            sortOption=[];
        case 1
            sortOption=sortOptions{k};
        otherwise
            disp(sortOptions(k))
            error('Ambiguous sort option!')
    end
    k=contains(directionOptions,varargin);
    switch sum(k)
        case 0
            warning('No valid input for order')
            directionOption=[];
        case 1
            directionOption=directionOptions{k};
        otherwise
            disp(directionOptions(k))
            error('Ambiguous direction option!')
    end
else
    sortOption=[];
    directionOption=[];
end
%fprintf('Sort option = ''%s''; direction = ''%s''\n',sortOption,directionOption)

f=cellstr(f);

% Code below doesn't work for mixed dirs/ files
%di=cellfun(@dir,f,'Unif',0);
%di=vertcat(di{:});
%[di.fullpath]=deal(f{:});
% We want to include fullpath, but code below creates folders with '\.' and
% '\..' at end - don't really want that
% diStructArray=cellfun(@dir,f,'Unif',0);
% diStructArray=vertcat(diStructArray{:});
% pathBit={diStructArray.folder};
% endBit={diStructArray.name};
% fullBit=fullfile(pathBit,endBit);
% [diStructArray.fullfile]=deal(fullBit{:});

% So instead we'll just loop through everything
Nf=length(f);
diCellArray=cell(Nf,1);
for index=1:Nf
    fi=f{index};
    if ~isfile(fi) && ~isfolder(fi)
        warning('%s not file/folder!!',fi)
        continue
    end
    dii=dir(fi); % struct array
    % generate string with more meaningful size
    fsize=cellstr(sizeString([dii.bytes]));
    [dii.sizeLabel]=fsize{:}; % then add like this!
    % Now prepare fullfile
    ff=fullfile({dii.folder},{dii.name});
    [dii.fullfile]=deal(ff{:});
    diCellArray{index}=dii;
end

diStructArray=vertcat(diCellArray{:});

if ~isempty(sortOption)
    switch char(sortOption)
        case 'size'
            vals2Sort=[diStructArray.bytes];
        case 'date'
            vals2Sort=[diStructArray.datenum];
        case 'name'
            vals2Sort={diStructArray.name};
        otherwise
            error('Invalid sort option %s',sortOption)
    end
    fprintf('Sorting by ''%s''...\n',sortOption);
    [~,indexOrder]=sort(vals2Sort);
    if isequal(directionOption,'descending')
        indexOrder=fliplr(indexOrder);
        fprintf('...in reverse order\n')
    end
    diStructArray=diStructArray(indexOrder);
end

end
