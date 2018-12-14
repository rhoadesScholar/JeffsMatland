function find_out = find_value_in_struct_array(str, inputfield, relationship1, linker, relationship2)
% find_out = find_value_in_struct_array(str,field,relationship1, linker, relationship2)
% find_out(n, 1) = str index, find_out(n, 2) = str(find_out(n, 1)).(field) index

if(nargin<1)
    disp([sprintf('find_out = find_value_in_struct_array(str,field,relationship1, linker, relationship2)')])
    disp([sprintf('find_out(n, 1) = str index, find_out(n, 2) = str(find_out(n, 1)).(field) index)')])
    return
end

find_out = [];

if(~isfield(str(1), inputfield))
    period_idx = strfind(inputfield,'.');
    if(isempty(period_idx)) % no period, so this is an unknown field
        error('cannot find %s for find_value_in_struct_array', inputfield);
    else % contains period so look for field within a structure within str
        field = inputfield(1:(period_idx-1));
        subfield = inputfield((period_idx+1):end);
        for(i=1:length(str))
            if(~isempty(str(i).(field)))
                sub_out = [];
                if(nargin == 3)
                    sub_out = find_value_in_struct_array(str(i).(field), subfield, relationship1);
                else
                    sub_out = find_value_in_struct_array(str(i).(field), subfield, relationship1, linker, relationship2);
                end
                for(ww=1:size(sub_out,1))
                    find_out = [find_out; i sub_out(ww,:)];
                end
            end
        end
        return;
    end
else
    field = inputfield;
end


for(i=1:length(str))
    if(nargin == 3)
        st = sprintf('find(str(i).%s %s)',field, relationship1);
    else
        st = sprintf('find(str(i).%s %s %s str(i).%s %s)',field, relationship1, linker, field, relationship2);
    end
    
    f = eval(st);
    for(ww=1:length(f))
        find_out = [find_out; i f(ww)];
    end
end

return;
end
