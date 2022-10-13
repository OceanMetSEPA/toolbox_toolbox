function fig2clipboard(figHandle,varargin)
% Copy figure to clipboard for (e.g.) pasting into word
%
% (saves having to go Edit -> Copy Figure;
%  copygraphics does this in matlab post 2020...)
%
% INPUTS:
%  figHandle - if not passed, use gcf
%
% Optional Inputs:
% background [true] - include grey border around figure
% xsize [] - if not empty, resize figure to this width
% ysize [] - if not empty, resize figure to this height
% (If only one xsize,ysize passed, resize keeping original aspect ratio)
% filename [] - if not empty, save figure to file
% format ['-dpng'] - if filename option has no extension, use this format
%
% NOTE: 
% If filename passed, function will try to use extension to determine
% format. If no extension included, function will use format option
%
% EXAMPLES:
% fig2clipboard(gcf)
% fig2clipboard()
% fig2clipboard('background',0) %
% fig2clipboard('file','fish','format','bmp') % save as bitmap
% fig2clipboard('file','fish.jpg','format','bmp') % save as jpg - format option is ignored

if nargin==0
    figHandle=gcf;
elseif ischar(figHandle)
    varargin=[figHandle,varargin];
    figHandle=gcf;
end
options=struct;
options.background=true;
options.xsize=[];
options.ysize=[];
options.filename=[];
options.format='-dpng';
options=checkArguments(options,varargin);

% Pos stuff
pos=get(figHandle,'position');
x=options.xsize;
y=options.ysize;
resize=~isempty(x) || ~isempty(y);
if resize
    % If we haven't specified both x,y sizes, keep original aspect ratio:
    ar=pos(3)/pos(4);
    if isempty(y)
        y=x/ar;
    elseif isempty(x)
        x=y*ar;
    end
    pos(3)=x;
    pos(4)=y;
    set(figHandle,'position',pos)
end
set(figHandle,'inverthardcopy',onOrOff(~options.background))
% -r0 means screen resolution (default not sufficient)
print(figHandle,'-dmeta','-r0');

if ~isempty(options.filename)
    % Check passed filename:
    [a,b,fileFormat]=fileparts(options.filename);
    fileFormat=strrep(fileFormat,'.','');
    printFormats={'-djpeg','-dpng','-dtiff','-dtiffn','-dmeta','-dbmpmono','-dbmp','-dbmp16m','-dbmp256','-dhdf','-dpbm','-dpbmraw','-dpcxmono','-dpcx24b','-dpcx256','-dpcx16','-dpgm','-dpgmraw','-dppm','-dppmraw'};
    if isempty(fileFormat) % passed filename didn't have an extension?
        fileFormat=options.format; % use value in option
    end
    fileFormat=strrep(fileFormat,'jpg','jpeg'); % so we can specify jpg
    fileFormat=strrep(fileFormat,'-d','');
    croppedFormats=strrep(printFormats,'-d',''); % remove -d bit 
    fileFormatToUse=closestStringMatch(croppedFormats,fileFormat);
    switch length(fileFormatToUse)
        case 0
            disp(printFormats)
            error('unrecognised format ''%s''; please specify one of the above options',fileFormat)
        case 1
            fileFormatToUse=strcat('-d',char(fileFormatToUse));
        otherwise
            disp(fileFormatToUse)
            error('Ambiguous format ''%s''; please specify one of the above options',fileFormat)
    end
    fprintf('Saving using format option ''%s''\n',fileFormatToUse)
    filename=fullfile(a,b);
    print(fileFormatToUse,filename)
end

