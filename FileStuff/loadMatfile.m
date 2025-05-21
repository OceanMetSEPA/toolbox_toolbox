function op=loadMatfile(matfileName)
% Load matfile(s)
% Function 'load' loads matfile as struct, where the field is what we're actually we're interested in
% Function 'importdata' does what we want, but is several times slower
%
% This function uses faster load function, then returns the struct field
% rather than the struct
%
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
% 20250521 - minor change to comment for testing git clone/push

% 20231025 - modify so we can add multiple inputs with one call
matfileName=cellstr(matfileName); % convert from char to cellstr
if length(matfileName)>1 % more than 1 input?
    op=cellfun(@loadMatfile,matfileName,'unif',0);
    try % this works if inputs are of same format (e.g. structs with matching fields):
        op=vertcat(op{:});
    catch % oh well, never mind - just return cell array
    end
    return
end
matfileName=char(matfileName);
data=load(matfileName);
try
    fn=char(fieldnames(data));
    op=data.(fn);
catch % err
%    disp(err)
%    warning('Problem extracting field :-(')
    op=data;
end
