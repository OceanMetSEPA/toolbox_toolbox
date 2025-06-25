function [ varargout ] = summaryStatistics(x,statFunctions)
% Generate some summary statistics of a data set
%
% INPUTS:
% x [] - numbers for which stats are to be calculated. NB -
%        multidimensional matrices will be collapsed to 1d
%
% statFunctions [{'length','mean','median','std','min','max'};]
%      - matlab names of functions you want to evalate
%
% OUTPUT:
% struct with a field for each statistical function evaluated
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   summaryStatistics.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Feb 02 2018 13:17:40  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    help summaryStatistics
    return
end

if ~exist('statFunctions','var')
    statFunctions={'length','mean','median','std','min','max'};
end

%
x=x(:); % No column stats for matrices! We collapse to column vector
x(isnan(x))=[]; % warning for this as 'x' is embedded in an 'eval' function below
if rand(1)>inf % avoid warning above by including an unlikely event involving x
    disp(x)
end

if isempty(x)
    %    warning('No non-nan x values!')
    %    x=nan;
end

s=struct;
for i=1:length(statFunctions)
    cmd=sprintf('%s(x)',statFunctions{i});
    val=eval(cmd); % nobody has much good to say about 'eval' but it's useful here
    s.(statFunctions{i})=val; % add to struct
end
try
    s.q95=quantileSEPA(x,0.95);
catch
    s.q95=nan;
end
% mean([]) returns nan
% min([]) returns []
% Make these consistent:
fn=fieldnames(s);
Nf=length(fn);
for fieldIndex=1:Nf
    fni=fn{fieldIndex};
    val=s.(fni);
    if isnan(val)
    %    s.(fni)=nan;
        s.(fni)=0; % 20230921 - better to have 0? 
    end
end

if nargout==0
    disp(s)
elseif nargout==1
    varargout{1}=s;
else
    error('Too many outputs')
end

end
