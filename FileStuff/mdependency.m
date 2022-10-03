function mdependency(script2Check,checkOps)
% Find functions required by input script/function
%
% INPUT:
% script2Check - .m file to check
%
% Optional Input:
% checkOps [false] - check whether dependencies are in OPS folder

if nargin<2
    checkOps=true;
end

filesNeeded=matlab.codetools.requiredFilesAndProducts(script2Check)';
Nf=length(filesNeeded);
if Nf==0
    fprintf('No dependencies\n')
    return
end

fprintf('%d files needed:\n',Nf)
disp(filesNeeded)
underline

if ~checkOps
    return
end

try
    % What files do we already have in our Ops folder?
    opsFiles=fileFinder('C:\CodeLibraryOps','dir',0,'sub',1);
    % These aren't there!
    files2Add=setdiff(filesNeeded,opsFiles)';
    % filesToAdd contains script2Check- remove that one
    files2Add=setdiff(files2Add,script2Check)';
    if isempty(files2Add)
        fprintf('All dependencies in OPS folder :-)\n')
    else
        fprintf('%d files missing from OPS folder:\n',length(files2Add))
        cdisp(rand(1,3),files2Add)
    end
catch
    warning('Folder ''C:\CodeLibraryOps'' not found')
end
