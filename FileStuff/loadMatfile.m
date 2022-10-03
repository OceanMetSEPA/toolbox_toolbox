function op=loadMatfile(matfileName)
% Load matfile
% Function 'load' loads matfile as struct, where the field is what we're actually we're interested in
% Function 'importdata' does what we want, but is several times slower
%
% This function uses faster load function, then returns the struct field
% rather than the struct
%%
% matfileName='C:\MIKEZeroProjectsSEPA\FishTrajectory\sparseConcStructRaw.mat';
% fprintf('Importdata:\n')
% tic
% imp=importdata(matfileName);
% toc % 30s
% 
% fprintf('load:\n')
% tic
% checkOrig=load(matfileName);
% toc % 10s
% %
% %isequal(imp,checkOrig.sparseConcStruct)
%%  
data=load(matfileName);
try
    fn=char(fieldnames(data));
    op=data.(fn);
catch err
    disp(err)
    warning('Problem extracting field :-(')
    op=data;
end
