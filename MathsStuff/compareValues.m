function varargout = compareValues(x,y,details)
% Compare two sets of values
% (Essentially call setdiff(x,y) and setdiff(y,x))

if nargin<3
    details=false;
end

if isequal(x,y)
    fprintf('EQUAL!\n')
    return
end


xName=inputname(1);
yName=inputname(2);
if isempty(xName)
    xName='1st argument';
end
if isempty(yName)
    yName='2nd argument';
end
if isnumeric(x)
    x(isnan(x))=[];
end
if isnumeric(y)
    y(isnan(y))=[];
end
dxy=setdiff(x,y);
if ~isempty(dxy)
    fprintf('%d values are in %s but not in %s:\n',length(dxy),xName,yName)
    if details
        disp(dxy);
    end
else
    fprintf('all values in %s are also in %s\n',xName,yName)
end
dyx=setdiff(y,x);
if ~isempty(dyx)
    fprintf('%d values are in %s but not in %s:\n',length(dyx),yName,xName);
    if details
        disp(dyx)
    end
else
    fprintf('all values in %s are also in %s\n',yName,xName)
end

if nargout==1
    varargout{1}=[dxy,dyx];
elseif nargout==2
    varargout{1}=dxy;
    varargout{2}=dyx;
else
    return
end

end

