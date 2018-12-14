function BW = custom_im2bw(A, level)

% BW = (A > 255*level);

BW = (A > level);

return
end
