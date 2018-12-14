function [cc, NumWorms, numClumps, numWormsClump, numWorms_perBox, numRealObjects, meanWormSize] = worm_bwconncomp(Movsubtract, Level, input_row_lim, input_col_lim, image_size)
% [cc, NumWorms, numClumps, numWormsClump, numWorms_perBox, numRealObjects, meanWormSize] = worm_bwconncomp(Movsubtract, Level)
% cc = output from bwconncomp, with all non-worm objects removed
% NumWorms = number of worm-sized objects
% numClumps = number of potential worm clumps
% numWormsClump = number of worms in clumps
% numWorms_perBox = array of number of worms in each box defined by input_row_lim and input_col_lim
% numRealObjects = number of objects detected at Level threshold
% meanWormSize = mean worm size in pixels

global Prefs;

if(nargin<3)
    input_row_lim = [];
end

numWorms_perBox = [];

if(~isempty(input_row_lim))
    
    cc.Connectivity = 8;
    cc.ImageSize = image_size;
    cc.NumObjects = 0;
    cc.object_sizes = [];
    cc.level = [];
    
    pix_idx_list_idx = 1;
    for(t=1:size(input_row_lim,1))
        row_lim = input_row_lim(t,:);
        col_lim = input_col_lim(t,:);
        
        if(length(Level)==1)
            local_level = Level;
        else
            local_level = Level(t);
        end
        
        cc1 = bwconncomp_sorted(custom_im2bw(Movsubtract(row_lim(1):row_lim(2), col_lim(1):col_lim(2) ), local_level));
        
        local_image_size = [(row_lim(2) - row_lim(1) + 1) (col_lim(2) - col_lim(1) + 1)];
        for(n=1:cc1.NumObjects)
            [i, j] = ind2sub(local_image_size, cc1.PixelIdxList{n});
            cc1.PixelIdxList{n} = sub2ind(image_size, (i + row_lim(1) - 1), (j + col_lim(1) - 1));
        end
        
        cc.NumObjects = cc.NumObjects + cc1.NumObjects;
        
        numWorms_perBox(t) = 0;
        
        for(p=1:cc1.NumObjects)
            cc.PixelIdxList{pix_idx_list_idx} = cc1.PixelIdxList{p};
            cc.object_sizes(pix_idx_list_idx) = cc1.object_sizes(p);
            cc.level(pix_idx_list_idx) = local_level;
            pix_idx_list_idx = pix_idx_list_idx +1;
            
            if(cc1.object_sizes(p) < Prefs.MaxWormClumpArea && cc1.object_sizes(p) > Prefs.MinWormArea)
                numWorms_perBox(t) = numWorms_perBox(t) + cc1.object_sizes(p);
            end
            
        end
    end
    
    if(~isempty(cc.object_sizes))
        [~, idx] = sort(cc.object_sizes,'ascend');
        
        cc.PixelIdxList = cc.PixelIdxList(idx);
        cc.object_sizes = cc.object_sizes(idx);
    else
        cc.PixelIdxList = [];
    end
    
else
    cc = bwconncomp_sorted(custom_im2bw(Movsubtract, Level));
    cc.level = zeros(size(cc.object_sizes)) + Level;
end

numRealObjects = cc.NumObjects;

NumWorms=0; numClumps = 0; numWormsClump = 0; meanWormSize = (Prefs.MinWormArea + Prefs.MaxWormArea)/2;

if(isempty(cc.object_sizes))
    numWorms_perBox = [];
    return;
end

% remove objects too large or small to be worms or clumps

% too small
m = 1;
while(cc.object_sizes(m) < Prefs.MinWormArea)
    m = m+1;
    if(m>cc.NumObjects)
        break;
    end
end
del_idx = 1:(m-1);

% too large
m = cc.NumObjects;
while(cc.object_sizes(m) > Prefs.MaxWormClumpArea)
    m=m-1;
    if(m<1)
        break;
    end
end
del_idx = [del_idx (m+1):cc.NumObjects];

% delete
cc.object_sizes(del_idx) = [];
cc.PixelIdxList(del_idx) = [];
cc.level(del_idx) = [];
cc.NumObjects = length(cc.object_sizes);
if(cc.NumObjects<1)
    numWorms_perBox = [];
    return;
end

m=1;
worm_sizes = 0;
while(cc.object_sizes(m) <= Prefs.MaxWormArea)
    worm_sizes = worm_sizes + cc.object_sizes(m);
    NumWorms = NumWorms + 1;
    m=m+1;
    if(m>length(cc.object_sizes))
        meanWormSize = worm_sizes/(m-1);
        numWorms_perBox = round(numWorms_perBox./meanWormSize);
        return;
    end
end
meanWormSize = worm_sizes/(m-1);
if(isnan(meanWormSize))
   meanWormSize = (Prefs.MinWormArea + Prefs.MaxWormArea)/2;
end


while(cc.object_sizes(m) <= Prefs.MaxWormClumpArea)
    numClumps = numClumps + 1;
    numWormsClump = numWormsClump + (cc.object_sizes(m)/meanWormSize);
    m=m+1;
    if(m>length(cc.object_sizes))
        numWormsClump = round(numWormsClump);
        numWorms_perBox = round(numWorms_perBox./meanWormSize);
        return;
    end
end
numWormsClump = round(numWormsClump);
numWorms_perBox = round(numWorms_perBox./meanWormSize);

return;
end
