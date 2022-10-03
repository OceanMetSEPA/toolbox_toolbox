function op=struct2array(tableStruct)
%% Try to make struct as returned by tableData the same as a query
% Can't use struct2array on sdata if it has a mixture of numeric/cell fields
% So convert numerics to cells:

% Can't have if statement within structfun, so write separate function
% below
tmpStruct=structfun(@ifNumThenCell,tableStruct,'unif',0);
op=struct2array(tmpStruct);

% Function to convert numeric array to cells, and leave cells alone
    function op=ifNumThenCell(ip)
        op=ip;
        if isnumeric(op)
            op=num2cell(op);
        end
    end
end
