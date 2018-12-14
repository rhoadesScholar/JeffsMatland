function [cc, NumWorms, numClumps, numWormsClump, Level] = adjust_worm_detection_threshold_level(Movsubtract, NumFoundWorms)

global Prefs;

[Level, NumWorms] = find_optimal_threshold(Movsubtract, NumFoundWorms);

% Using the new level, identify all objects in the frame, and extract their info
[cc, NumWorms, numClumps, numWormsClump] = worm_bwconncomp(Movsubtract, Level);

% BW = custom_im2bw(Movsubtract, Level);
% 
% cc = bwconncomp(BW);
% L = zeros(size(BW));
% NumWorms=0;
% for(m=1:cc.NumObjects)
%     area = length(cc.PixelIdxList{m});
%     if(Prefs.MinWormArea <= area && area <=  Prefs.MaxWormArea)
%         NumWorms = NumWorms+1;
%         L(cc.PixelIdxList{m}) = NumWorms;
%     end
% end
% 
% clear('cc');
% clear('BW');

return;
end
