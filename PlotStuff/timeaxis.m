function timeaxis(xy,Timeoffset,YearTicks,FORM,varargin)
% timeaxis(xy,Timeoffset,YearTicks,FORM) draws time axis
% Input:
%  xy  : x refers to the x-axis, ('x',1) or y-axis ('y',0)
%      
%  Timeoffset: zero point of time axis (julian days), if not specified,  
%        1.1.-1 is used as default time axis, as in the datenum function (in description 
%        wrongly named 1.1.0) 
%  Yearticks: specifies, where Tickmarks (in years) should be placed, for example [2000:.5:2005]. If not specified,
%        automatic Tickmarks are used.
%        Can also be one of the following strings
%        month, month1: set tickmarks every first of each month
%        month15      : set tickmarks every 15th of each month
%        Variants thereof:
%        2months1, 3months1, 6months1: set each second,third or
%        sixth month
%        if FORM is 2 (given or by default) set it to 12=Mar00
%  FORM: format for Tickmarks' time strings, as in function datestr, if not specified, default: FORM=2
%  Variable arguments
%  'limits'  : set the time axis limits to the min/max of YearTicks 
% example: timeaxis_en => draws the time axis on the x-axis
%          timeaxis_en(0,julday(1,1-1)) => draws time axis on y-axis  		
if exist('xy')~=1 | isempty(xy) ; xy=1; end
if ischar(xy);
  if length(xy)>1; error('Axis must be 1 char, x or y'); end
  if upper(xy)=='X'; xy=1; elseif upper(xy)=='Y'; xy=2;
  else error('Axis must be 1 char, x or y'); end
end
if exist('Timeoffset')~=1 | isempty(Timeoffset) ; 
  Timeoffset=0;
else
  Timeoffset=Timeoffset-1721059;  % 1.1.-1 subtracted 
end
if nargin<4; FORM=20; end   %  form=20: 'dd/mm/yy' aus /usr/local/matlab7/toolbox/matlab/timefun/datestr.m
if isempty(FORM); FORM=2; end % form=28: 'mmm/yyyy' form=15: 'hh:MM', form 12=mmm/yy, form 19=dd/mm/

ii=1; setaxislimits=0;
while ii<=length(varargin)
  if strcmpi(varargin{ii},'LIMITS')
    setaxislimits=1;
    ii=ii+1;
  else
    error('unknown variable argument')
  end
end
   
if exist('YearTicks')~=1 
  
elseif ~isempty(YearTicks) & ischar(YearTicks) ;
  switch lower(YearTicks)
   case {'month','month1'}
    IDD=1; IMM=1
   case {'month15'}
    IDD=15; IMM=1;
   case {'2month','2month1','2months','2months1'}
    IDD=1; IMM=2;
   case {'2month15','2months15'}
    IDD=15; IMM=2;
   case {'3month','3month1','3months','3months1'}
    IDD=1; IMM=3;
   case {'3month15','3months15'}
    IDD=15; IMM=3;
   case {'6month','6month1','6months','6months1'}
    IDD=1; IMM=6;
   case {'6month15','6months15'}
    IDD=15; IMM=6;
   otherwise
    error('wrong character string for YearTicks')
  end
  if xy==1; a=get(gca,'XLim'); else  a=get(gca,'YLim'); end
  %keyboard
  a=a+Timeoffset+1721059;
  [idd,imm,iyyy]=dayjulian(a(1)); dumy=[];
  imm=imm+1-IMM; if imm<1; imm=imm+12; iyyy=iyyy-1; end
  while 1>0
    imm=imm+IMM; if imm>12; imm=imm-12; iyyy=iyyy+1; end
    if ~isempty(dumy) & julianday(IDD,imm,iyyy)>a(2); break; end
    dumy=[dumy julianday(IDD,imm,iyyy)];
  end
  dumy=dumy+Timeoffset+1721059;
  if xy==1;
    set(gca,'Xtick',dumy);
  else 
    set(gca,'Ytick',dumy);
  end
  if FORM==2; FORM=12; end
elseif ~isempty(YearTicks) ;
  if min(YearTicks)>1721059
    YearTicks=YearTicks-1721059;
    YearTicks=YearTicks-Timeoffset;
  else    
    if max(mod(YearTicks,1))==0 & nargin<4; FORM=11; end
    YearTicks=julianday(1,1,YearTicks)-1721059;
    YearTicks=YearTicks-Timeoffset;
  end
  if xy==1;
    set(gca,'Xtick',YearTicks);
    if setaxislimits; set(gca,'Xlim',[min(YearTicks),max(YearTicks)]); end
  else 
    set(gca,'Ytick',YearTicks);
    if setaxislimits; set(gca,'Ylim',[min(YearTicks),max(YearTicks)]); end
  end
end

a=gca;
if xy==1;
  xt=get(a,'XTick');
  xl=datestr(xt+Timeoffset,FORM);
  bereich=get(a,'Xlim');
  n=sum(xt>bereich(1) & xt<bereich(2));
  if n>12
    xl(2:2:end,:)=' ';
  end
  set(a,'XTickLabel',xl)
  set(a,'XTickLabelMode','manual')
  set(a,'XTickMode','manual')
else
  yt=get(a,'YTick');
  yl=datestr(yt+Timeoffset,FORM);
  bereich=get(a,'Ylim');
  n=sum(yt>bereich(1) & yt<bereich(2));
  if n>12
    yl(2:2:end,:)=' ';
  end
  set(a,'YTickLabel',yl)
  set(a,'YTickLabelMode','manual')
  set(a,'YTickMode','manual')
end

   
