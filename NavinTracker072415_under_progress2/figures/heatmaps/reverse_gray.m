function cm = reverse_gray
% gray colormap in reverse

cm = gray; 
cm = cm(size(cm,1):-1:1,:);

return;
end
