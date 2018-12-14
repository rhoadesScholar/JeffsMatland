function Y = staring_hierarchal_clustering(dirlistfilename, method)

if(nargin==1)  
    method = sprintf('euclidean'); % euclidean
end    

[summary_matrix, strainnames] = generate_staring_summary_matrix(dirlistfilename);

Y = pdist(summary_matrix,method);
Z = linkage(Y,'average');
[H,T] = dendrogram(Z,0,'labels',strainnames,'orientation','left');

return;
end

