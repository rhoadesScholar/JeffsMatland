function indicies = find_string_in_cell_array(x, targetstring)

indicies=[];

j=0;
for(i=1:length(x))
    if(~isempty(findstr(char(x{i}),targetstring)))
        j=j+1;
        indicies(j) = i;
    end
end
    

return;

