function dm = nanfill_symmetric_matrix(dm)
% nan-fills a symmetric matrix; used for making heatmaps of symmetric
% matricies

for(i=1:size(dm,1))
    for(j=i+1:size(dm,2))
        dm(i,j)=NaN;
    end
end

return;
end
