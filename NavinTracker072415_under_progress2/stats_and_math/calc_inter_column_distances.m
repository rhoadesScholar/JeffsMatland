function DM = calc_inter_column_distances(X)

% DM = calc_inter_column_distances(X) returns a p-by-p matrix containing the pairwise distances between each pair of columns in the n-by-p matrix X.
% each column is a variable of interest

num_columns = size(X,2);

DM = zeros(num_columns,num_columns);

for(i=1:num_columns)
    for(j=i:num_columns)
        DM(i,j) = inter_vector_distance(X(:,i), X(:,j)); 
        DM(j,i) = DM(i,j);
    end
end

return;
end
