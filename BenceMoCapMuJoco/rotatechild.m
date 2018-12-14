function limbposition_child_out = rotatechild(limbposition_child,rotmatrix_parent,transmatrix_parent)



limbposition_child_out = cat(2,transmatrix_parent+mtimesx(rotmatrix_parent,limbposition_child(:,1,:)) ,...
transmatrix_parent+mtimesx(rotmatrix_parent,limbposition_child(:,2,:)));

end