function common_name = get_common_name_from_strings(my_string_cell_array)
% common_name = get_common_name_from_strings(my_string_cell_array)
% my_string_cell_array = {'blah758','blah122','blah51'}
% common_name = get_common_name_from_strings(my_string_cell_array)
% returns 'blah'

if(~iscell(my_string_cell_array))
    common_name = my_string_cell_array;
    return;
end

if(length(my_string_cell_array)==1)
    common_name = my_string_cell_array{1};
    return;
end

minlen = 1e10;
for(i=1:length(my_string_cell_array))
    if(length(my_string_cell_array{i})<minlen)
        minlen = length(my_string_cell_array{i});
    end
end

common_name = '';
for(i=1:minlen)
    common_char_flag=1;
    currentchar = my_string_cell_array{1}(i);
    for(j=2:length(my_string_cell_array))
        if(my_string_cell_array{j}(i)~=currentchar)
            common_char_flag=0;
        end
    end
    if(common_char_flag==1)
        common_name = sprintf('%s%s',common_name,currentchar);
    end
end

i=length(common_name);
while(i>=1)
    if(common_name(i)=='.' || common_name(i)=='_' || common_name(i)=='-') 
        common_name(i)=[];
        i=length(common_name);
    else
        i=i-1;
    end
end

return;
end
