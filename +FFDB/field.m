function op = field( tableName,fieldname,filterBy )
% Extract field from struct. Optionally filter by 'filterBy'.
% 
% INPUT:
% tableName [] - struct to filter (e.g. ffdb=FFDB.loadDatabase())
% fieldName [] - field to extract (e.g. 'Cages')
%
% OPTIONAL INPUT:
% filterBy [] - filter output struct by this field
% 
fn=fieldnames(tableName);

fnMatch=closestStringMatch(fn,fieldname);
N=length(fnMatch);
switch N
    case 1
        op=tableName.(char(fnMatch));
        if nargin>2
            op=mixmatch(op,filterBy);
        end
        return
    otherwise
        ufn=ungenvarname(fn);
        fnMatch=closestStringMatch(ufn,fieldname);
        N=length(fnMatch);
        switch N
            case 0
                error('No matches for ''%s''',fieldname)
            case 1
                op=tableName.(fnMatch);
                if nargin>2
                    op=mixmatch(op,filterBy);
                end
                return
            otherwise
                disp(fnMatch)
                error('Ambiguous field ''%s''',fieldname)
        end
        
        
end
end

