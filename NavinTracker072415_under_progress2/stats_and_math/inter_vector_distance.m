function d = inter_vector_distance(x,y)
% find the distance between two vectors 
% essentially rmsd

d = sqrt(sum((x-y).^2));

return;
end
