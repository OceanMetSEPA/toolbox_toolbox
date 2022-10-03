function varargout=nameID(ip,tab)
% Given FF Site Name / ID, find corresponding ID / Name
% Table GIS_Site contains both, so use that.
% 
% INPUT: char/cellstr of Site Name(s) / ID(s)
%
% Optional Input:
% tab [] - return table containing both site name & ID
%
% OUTPUT - Either:
% char/cellstr of names/IDs (tab == false)
% table containing fields SITE_ID, SiteName
%
% EXAMPLES:
% FFDB.nameID('Lip') % Return ID for Lippie Geo
% FFDB.nameID('GEO') % Return names of farms containing GEO
%
if nargin==0
    help FFDB.nameID
    return
end

if ~exist('tab','var')
    tab=false;
end

ip=cellstr(ip);

% Site ID
siteID=FFDB.query('select SITE_ID from GIS_Site');
% Site Name
siteName=FFDB.query('select SiteName from GIS_Site');

isID=contains(siteID,ip,'ig',1);
isName=contains(siteName,ip,'ig',1);
if any(isID) && any(isName)
    fprintf('Site ID:\n')
    disp(siteID(isID))
    fprintf('Site Name:\n')
    disp(siteName(isName))
    error('Ambiguous ID/Name!')
end

if any(isName)
    ip=siteName(isName);
    op=cellfun(@(x)FFDB.query(sprintf('select SITE_ID from GIS_Site where SiteName = (''%s'')',x)),ip,'unif',0);
else
    ip=siteID(isID);
    op=cellfun(@(x)FFDB.query(sprintf('select SiteName from GIS_Site where SITE_ID = (''%s'')',x)),ip,'unif',0);
end
k=cellfun(@isempty,op);
if any(k)
    op{k}='Not Found!';
end
op=vertcat(op{:});
if tab
    fn={'SITE_ID','SiteName'};
    if any(isName)
        fn=flip(fn);
    end
    tab=table(ip,op,'VariableNames',fn);
    op=tab;
elseif length(op)==1
    op=char(op);
end

if nargout==0
    disp(op)
elseif nargout==1
    varargout{1}=op;
else
    error('too many outputs')
end
