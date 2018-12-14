function MI = mutual_information_matrix(X)
% MI = mutual_information_matrix(X) returns a p-by-p matrix containing the pairwise mutual info between each pair of columns in the n-by-p matrix X.
% each column is a variable of interest

num_columns = size(X,2);

MI = zeros(num_columns,num_columns);

for(i=1:num_columns)
    for(j=i:num_columns)
        MI(i,j) = mutualInformation(X(:,i), X(:,j)); 
        MI(j,i) = MI(i,j);
    end
end

return;
end
