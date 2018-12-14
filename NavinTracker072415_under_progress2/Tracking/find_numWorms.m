function [NumWorms, numObjects, meanWormSize] = find_numWorms(Movsubtract, Level)

% STATS = custom_regionprops(bwlabel(custom_im2bw(Movsubtract, Level)), {'Area'});
% WormIndices = find([STATS.Area] >= Prefs.MinWormArea & [STATS.Area] <= Prefs.MaxWormArea);
% NumWorms = length(WormIndices);
% numObjects = length(STATS);
% return;

% % bwconncomp is faster than bwlabel
% cc = bwconncomp(custom_im2bw(Movsubtract, Level));
% NumWorms=0;
% for(m=1:cc.NumObjects)
%     area = length(cc.PixelIdxList{m});
%     if(Prefs.MinWormArea <= area  && area <=  Prefs.MaxWormArea)
%         NumWorms = NumWorms+1;
%     end
% end
% numObjects = cc.NumObjects;
% return;


[cc, numSoloWorms, numClumps, numWormsClump, numWorms_perBox, numObjects, meanWormSize] = worm_bwconncomp(Movsubtract, Level);
NumWorms = numSoloWorms;

return;
end
