function result = checkBimodality_normalized(finalTracks,Date,Genotype,binsize)

binnedSpeed = binSpeed(finalTracks,binsize);
binnedAngSpeed = binAngSpeed(finalTracks,binsize);

allSpeedBins = [];
allAngSpeedBins = [];
for i=1:(length(finalTracks))
    allSpeedBins = [allSpeedBins binnedSpeed(i).Speed];
    allAngSpeedBins = [allAngSpeedBins binnedAngSpeed(i).AngSpeed];
end

if ~isempty(findall(0,'Type','Figure'))
    figure
end
result = hist2_normalised_disp(allSpeedBins,allAngSpeedBins,0.003,2);
ylabel('Speed (mm/sec)')
xlabel('Angular Speed (deg/sec)')
title(sprintf('binSize = %d sec',binsize/3));
 axis([0 180 0 0.25]);
 cmap = [hot(255)];
 colormap(cmap);
% set(gca,'CLim',[0 26]);
 %set(gca,'Color',[0 0 0])
set(findobj(gcf,'type','axes'),'Color',[0 0 0]);
VidName = sprintf('%s.%s',Date,Genotype);

set(gcf,'Name',VidName);
%save_figure(gcf,'',VidName,'scatters');
display(length(allSpeedBins))
return
end
