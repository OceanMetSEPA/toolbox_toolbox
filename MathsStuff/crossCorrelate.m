function [varargout ] = crossCorrelate( x1,x2,varargin)
% cross-correlate 2 signals, x1 and x2
%
% Matlab 'xcorr' function for cross-correlating is in the signal-processing
% toolbox, which not all of us have. This is a simplied version - currently
% only implemented in 1 dimension and doesn't consider whether input is real or complex.
% It, like xcorr, uses the Fourier Transform which (thankfully) is included in the base matlab package.
%
% Correlation in time-domain equivalent to multiplication in frequency domain.
% So to cross-correlate, we undertake the following steps:
% 1) get the Fourier transform (FT) of each signal
% 2) multiply the FT of one by the complex conjugate of the other
% 3) take the inverse FT to get back to the time-domain
% 4) shift the result so zero frequency component is in middle of signal
%
% INPUT:
% x1 - first data set
% x2 - second data set
%
% OPTIONAL INPUTS:
% flag ['none']
%   'none'     - leave calculated cross-correlation alone
%   'biased'   - scale cross-corretion by 1/N
%   'unbiased' - scale cross-correlation by 1/(N-maxLags)
%   'coeff'    - normalise so autocorrelation at zero lag = 0
% standardise [true] - remove mean & divide by standard deviation prior to calculation
% resample ([]) - if number provided, resample timeseries to this number of minutes
% plot [false] - plot cross-correlation function
% title []     - include this string in title to first subplot
%
% OUTPUT
% cc - cross-correlation values
% lags - cross-correlation lags
% ccPeakLag - lag corresponding to maximum value of cc
%
% Note:
% ccPeakLag represents the shift which, when applied to x2, results in the
% best overlap between x1 & x2.
% If ccPeakLag<0:
%   x1 LEADS x2 
%   x2 LAGS  x1 (x2 needs to be shifted to left i.e. to earlier times)
%
% If ccPeakLag>0: 
%   x1 LAGS  x2  
%   x2 LEADS x1 (x2 needs to be shifted to right i.e. to later times for best fit with x1)
% r^2 value = coefficient of determination
%
% EXAMPLE:
% x=sin(0:pi/180:5*pi); % 5 cycles of sinusoid
% noiseFactor=1;
% x1=x+noiseFactor*(rand(size(x))-0.5); % sinusoid with noise added
% x2=circshift(x,-30)+noiseFactor*(rand(size(x1))-0.5); % shifted version of above, with noise added
% cc=crossCorrelate(x1,x2,'standard',0,'plot',1);
% cc2=xcorr(x1,x2);
% max(abs(cc-cc2)) % ~ order 1e-13

if nargin<2
    help crossCorrelate
    return
end

options=struct;
options.plotit=false;
options.flag='none';
options.resample=[];
options.standardise=true; % xcorr doesn't have this option
options.verbose=false;
options.centre=true;
options.ndp=8;
options.maxLag=[];
options.shift=true;
options.title=[];
options=checkArguments(options,varargin{:});

% Check inputs
if ~isequal(class(x1),class(x2))
    error('Inputs have different class')
end
if isa(x1,'timeseries')
% 1st input is a time-series. From test above, they both are. Here we crop them so they cover the time period. 
% Note that we don't check precise timings match. This could be made more robust!
    if ~isempty(options.resample)
        dt=options.resample/(24*60);
        if options.verbose
            fprintf('Resampling timeseries to %.1f minutes\n',options.resample);
        end
        x1=resample(x1,min(x1.Time):dt:max(x1.Time));
        x2=resample(x2,min(x2.Time):dt:max(x2.Time));
    end
    % Potential issue with timeseries- data size depends on whether input
    % data is a row or column vector?!
    % N=1000;
    % x=rand(N,1);
    % timeseries(x)  % data size = N x 1
    % timeseries(x') % data size = 1 x 1 x N
    % Fix this potential issue:
    x1.Data=squeeze(x1.Data);
    x2.Data=squeeze(x2.Data);
    % ensure timeseries overlap:
    ts1Times=roundn(x1.Time,-options.ndp);
    ts2Times=roundn(x2.Time,-options.ndp);
    t0=max(min(ts1Times),min(ts2Times));
    t1=min(max(ts1Times),max(ts2Times));
    k=ts1Times>=t0&ts1Times<=t1;
    set(x1,'Time',x1.Time(k),'Data',x1.Data(k,:));
    k=ts2Times>=t0&ts2Times<=t1;
    set(x2,'Time',x2.Time(k),'Data',x2.Data(k,:));
    t=x1.Time;
    % Extract 1st data sets of timeseries
    x1=squeeze(x1.Data);
    x2=squeeze(x2.Data);
end

N=max([length(x1),length(x2)]);
Ncc=2*N-1;

% Check for nans. If any found, replace by average of non-nan values
if any(isnan(x1)) || any(isnan(x2))   
    k=isnan(x1);
    Nk=sum(k);
    if Nk>0
        warning('%d NANS FOUND! in dataset 1',Nk)
        x1(k)=nanmean(x1);
    end
    k=isnan(x2);
    Nk=sum(k);
    if Nk>0
        warning('%d nans found in dataset 2',Nk)
        x2(k)=nanmean(x2);
    end
end

% Should we standardise data sets? Can improve matching
if options.standardise
    x1=(x1-mean(x1))/std(x1);
    x2=(x2-mean(x2))/std(x2);
end
% Check flag
flagOptions={'biased','unbiased','coeff','none'};
ccOption=char(stringFinder(flagOptions,options.flag,'type','start'));
if ~length(ccOption)==1
    warning('Unrecognised flag; setting to ''none''');
    ccOption='none';
end

% Check max lag
if isempty(options.maxLag)
    if strcmp(ccOption,'unbiased')
        options.maxLag=round(length(x1)/2);
    else
        options.maxLag=length(x1);
    end
end

if(all(isnan(x1))||all(isnan(x2)))
    warning('All data are NaNs; returning...\n')
    return
end

lags=(-N+1:N-1); % these are the lag indices
cc=ifft(fft(x1,Ncc).*conj(fft(x2,Ncc)));
if options.shift
    cc=fftshift(cc);
end
% Various options adapted from xcorr function:
switch ccOption
    case 'none'
        % do nothing
    case 'coeff'
        scaleFactor=sqrt(sum(x1.^2)*sum(x2.^2));
        cc=cc/scaleFactor;
    case 'unbiased'
        scaleFactor = (N-abs(lags))';
        cc=cc./scaleFactor;
    case 'biased'
        cc=cc/N;
    otherwise
        error('unrecognised option ''%s''',ccOption)
end

%fprintf('LAGS RANGE FROM %d to %d\n',min(lags),max(lags))
% Restrict max lag:
k=abs(lags)>options.maxLag;
cc(k)=0;
% Find peak in cross-correlation:
ccPeakLag=lags(cc==max(cc));

if(options.plotit)
    prepareFigure('title','Input values')
    sp1=subplot(2,1,1);
    hold on
    if ~exist('t','var')
        t=1:length(x1);
        relabel=false;
    else
        relabel=true;
    end
    if options.centre
%        x1=x1-mean(x1);
%        x2=x2-mean(x2);
    end
    h1=plot(t,x1,'.-r','DisplayName',inputname(1));
    h2=plot(t,x2,'.-g','DisplayName',inputname(2));
    if relabel
        adjustAxes
    end
    str=sprintf('%s Time-series ',options.title);
    set(get(sp1,'Title'),'String',str)
    leg=legend([h1,h2]);
    set(leg,'Interpreter','none','location','best')
    sp2=subplot(2,1,2);
    plot(lags,cc,'.-b')
    str=sprintf('Cross-correlation: max lag at %d',ccPeakLag);
    set(get(sp2,'Title'),'String',str)
end

if ccPeakLag<0
    str='LEADS';
elseif ccPeakLag>0
    str='LAGS';
else
    str='MATCHES';
end

if options.verbose || nargout==0
    fprintf('CC peak at index = %d; %s %s %s\n',ccPeakLag,inputname(1),str,inputname(2))
end
% Prepare outputs depending on how many user requested
if nargout>0
    varargout{1}=cc;
    if nargout>1
        varargout{2}=lags;
        if nargout>2
            varargout{3}=ccPeakLag;
        end
    end
end
end
