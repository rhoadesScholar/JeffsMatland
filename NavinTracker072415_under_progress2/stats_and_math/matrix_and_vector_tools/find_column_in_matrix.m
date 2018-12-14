function col_idx = find_column_in_matrix(a, target_column)

num_row = size(a,1);
num_col = size(a,2);

col_idx = [];

for(j=1:num_col)

    found_flag=1;
    for(i=1:num_row)
       if(target_column(i) ~= a(i,j))
           found_flag=0;
           break;
       end
    end
    if(found_flag==1)
        col_idx = [col_idx j];
    end
end

return;
end
