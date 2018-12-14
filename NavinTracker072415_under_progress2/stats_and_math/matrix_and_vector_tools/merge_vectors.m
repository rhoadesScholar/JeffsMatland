function x = merge_vectors(input_cell_array)
% x = merge_vectors(input_cell_array)
% merges merge_vectors in input_cell_array into a single matrix x
% x = merge_vectors({[1; 2; 3], [4; 5; 6; 7; 8], [9; 10]})
% x =
%      1     4     9
%      2     5    10
%      3     6   NaN
%    NaN     7   NaN
%    NaN     8   NaN
%    
% x = merge_vectors({[1 2 3], [4 5 6 7 8], [9 10]})
% x =
%      1     2     3   NaN   NaN
%      4     5     6     7     8
%      9    10   NaN   NaN   NaN
     

n = length(input_cell_array);

maxlen=0;
for(i=1:n)
    l = length(input_cell_array{i});
    if(l > maxlen)
        maxlen = l;
    end
end

if(size(input_cell_array{1},2)==1)
    x(maxlen, n)=0;
    x = x + NaN;
    for(i=1:n)
        x(1:length(input_cell_array{i}),i) =  input_cell_array{i};
    end
else
    x(n, maxlen)=0;
    x = x + NaN;
    for(i=1:n)
        x(i, 1:length(input_cell_array{i})) =  input_cell_array{i};
    end
end


return;
end
