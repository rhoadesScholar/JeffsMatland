% BUAT_M(50).modes(40)
% = session 50, trial 40 mode
% 
% 
% exptID = run ID
% defID = substage number increased iteratively
% 
% 
% IPI spread per mode?:
%     

for p = 1:length(PETH)
    imagesc(full(PETH(p).peth))
    pause
    close
end

allSpks = zeros(max(arrayfun(@(x) size(full(x.peth), 1), PETH)), size(full(PETH(1).peth), 2));
uniSpks = zeros(length(PETH), size(full(PETH(1).peth), 2));

for p = 1:length(PETH)
    allSpks = allSpks + padarray(sortrows(full(PETH(p).peth)), size(allSpks,1) - size(full(PETH(p).peth),1), 'post');
    uniSpks(p, :) = sum(full(PETH(p).peth))/max(sum(full(PETH(p).peth)));
    
end

imagesc(uniSpks);
figure
imagesc(allSpks);











%%%%%%%%%%%%
% modeSpks = NaN(length(PETH), length(unique(PETH(1).modes)), 1, 1, size(PETH(1).peth, 2)); 
cntThrsh = 

allMSesSpks = NaN(length(unique(PETH(1).modes)), 1, size(PETH(1).peth, 2)); 
a = ones(1, length(unique(PETH(1).modes)));
for p = 1:length(PETH)
    thisPETH = full(PETH(p).peth);   
        
    for m = unique(PETH(p).modes)'      %modes in incoming PETH currently start at 0 (invalid for indexing)
        spkCount = nansum(arrayfun(@(s) ...
                            nansum(thisPETH((PETH(p).modes == m) & (PETH(p).sessID == s))) / ...
                            nanmean(nansum(thisPETH((PETH(p).modes == m) & (PETH(p).sessID == s)))),...
                  unique(PETH(p).sessID(PETH(p).modes == m))'));
        
        if spkCount >= cntThresh
            for s = unique(PETH(p).sessID(PETH(p).modes == m))'
                inds = (PETH(p).modes == m) & (PETH(p).sessID == s);
                modeSpks(p, m, s, :, :) = shiftdim(thisPETH(inds, :), -3);
                if any(inds)
                    allMSesSpks(m + 1, a(m + 1), :) = nansum(thisPETH(inds, :))/nanmean(nansum(thisPETH(inds, :))); %nanmean doesn't show anything because spike times are rarely exactly the same (so mean is veeeeerrry small)
                    a(m + 1) = a(m + 1) + 1;
                end
            end
            allMSesSpks(m + 1, a(m + 1), :) = ones(1, size(allMSesSpks, 3));
            a(m + 1) = a(m + 1) + 1;
        end
    end
end

for m = unique(PETH(1).modes)'
    figure
    title(sprintf('Behavioral Mode %i', m));
    imagesc(squeeze(allMSesSpks(m + 1,:, :)));
    colormap(jet)
end

