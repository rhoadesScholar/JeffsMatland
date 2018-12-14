function cc = bwconncomp_sorted(pix, ascend_flag)
% wrapper for bwconncomp that returns cc sorted by object size in
% default ascending order

cc = bwconncomp(pix);

cc.object_sizes=zeros(1,length(cc.PixelIdxList));
for(i=1:length(cc.PixelIdxList))
   cc.object_sizes(i) = length(cc.PixelIdxList{i});
end

if(nargin>1)
    [~, idx] = sort(cc.object_sizes,ascend_flag);
else
    [~, idx] = sort(cc.object_sizes,'ascend');
end

cc.PixelIdxList = cc.PixelIdxList(idx);
cc.object_sizes = cc.object_sizes(idx);

return;
end
