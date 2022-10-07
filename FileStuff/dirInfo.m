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
sortOptions={'size','date','name'};
directionOptions={'ascending','descending'};
k=contains(sortOptions,varargin);
switch sum(k)
    case 0
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
        directionOption=[];
    case 1
        directionOption=directionOptions{k};
    otherwise
        disp(directionOptions(k))
        error('Ambiguous direction option!')
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
    % generate string with more meaningful size (see function below)
    fsize=sizeLabel([dii.bytes]); % .
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

% Generate meaninful label for number, based on exponent names
    function op=sizeLabel(x)
        labels={'bytes','KB','MB','GB','TB'};
        assignin('base','wtf',x)
        if length(x)>1
            x=x(:);
            op=arrayfun(@sizeLabel,x,'unif',0);
            op=vertcat(op{:});
            return
        end
        if x<1
            op='zero size';
        elseif x==1
            op='1 byte';
        else
            % Get order of magnitude band
            mag=floor(log10(x)/3);
            mag=min([mag,4]); % we've only labelled up to 10^(mag*3) for mag=4
            op=sprintf('%s %s',num2str(x/10^(mag*3)),labels{mag+1});
        end
        %fprintf('%e and label = ''%s''\n',x,op)
        op=cellstr(op); % so we don't need to worry about single x val having string label and multiple having cell labels
    end

end

