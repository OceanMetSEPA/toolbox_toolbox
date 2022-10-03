function [ colourMatrix ,colourIndices] = getColourMatrix(vals,cmap,clim,varargin )
% Generate colour matrix for passing to surf function
%
% This function produces a colour matrix for input 'vals', using colormap
% 'cmap', where the values are linearly scaled between 'clim'.
% (By passing rgb values rather than indices to the surf function, we can
% have multiple surfaces with different colour maps)
%
% INPUTS:
% vals - data to convert to colour matrix
% cmap - colormap
% clim [min(vals),max(vals)] - range for colours. Values outwith this range are assigned minimum / maximum value accordingly 
%
% OUTPUT:
% colourMatrix - matrix of colour values. 
% colourIndices - indices of colormap
%
% If input 1d with length N, output has dimensions [N,3].
% If input 2d with size (Nx,Ny), output has dimensions [Nx,Ny,3]
%

options=struct;
options.nanval=nan;
options.nancol=[1,1,1];
options=checkArguments(options,varargin);

valSize=size(vals);
%vals=vals(:);
if ~exist('clim','var')
    clim=[min(vals(:)),max(vals(:))];
end
if isempty(clim)
    clim=[min(vals(:)),max(vals(:))];
end
if rand(1)>Inf
    fprintf('GETTIGN COLOUR MATRICX FOR %d vals\n',length(vals));
    fprintf('CMAP SIZE:\n')
    disp(size(cmap))
    fprintf('CLIM:\n')
    disp(clim)
end

if diff(clim)==0
    'NO RANGE';
%    clim=clim+[0,1];
end

Nc=size(cmap,1);
clim=real(clim);
vals=real(vals);
colourIndices=round(Nc*(vals-min(clim))/(max(clim)-min(clim)));
colourIndices(colourIndices<=0)=1;
colourIndices(colourIndices>Nc)=Nc;

cmap=[cmap;options.nancol];
colourIndices(isnan(colourIndices))=Nc+1;
colourIndices(vals==options.nanval)=Nc+1;
%fprintf('GGeting colour matrix and range = :\n')
%disp(min(valIndices))
%disp(max(valIndices))
%class(valIndices)
colourMatrix=cmap(colourIndices,:);
colourMatrix=reshape(colourMatrix,valSize(1),valSize(2),3);
colourMatrix=squeeze(colourMatrix); % 20160526 change for twinConnectivityPlot
end

