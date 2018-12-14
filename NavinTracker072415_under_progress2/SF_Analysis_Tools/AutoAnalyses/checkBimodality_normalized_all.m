function result = checkBimodality_normalized_all(finalTracks,Date,binsize)

strains = fields(finalTracks);

for s = 1:length(strains)
    
    binnedSpeed = binSpeed(finalTracks.(strains{s}),binsize);
    binnedAngSpeed = binAngSpeed(finalTracks.(strains{s}),binsize);
    
    allSpeedBins = [];
    allAngSpeedBins = [];
    for (i=1:(length(finalTracks.(strains{s}))))
        allSpeedBins = [allSpeedBins binnedSpeed(i).Speed];
        allAngSpeedBins = [allAngSpeedBins binnedAngSpeed(i).AngSpeed];
    end
    
    if ~isempty(findall(0,'Type','Figure'))
        figure
    end
    result.(strains{s}) = hist2_normalised_disp(allSpeedBins,allAngSpeedBins,0.003,2);
    ylabel('Speed (mm/sec)')
    xlabel('Angular Speed (deg/sec)')
    title(sprintf('%s; binSize = %d sec', strains{s}, binsize/3));
     axis([0 180 0 0.25]);
     cmap = [hot(255)];
     colormap(cmap);
    set(findobj(gcf,'type','axes'),'Color',[0 0 0]);
    VidName = sprintf('%s.%s',Date,strains{s});
    set(gcf,'Name',VidName);
    %save_figure(gcf,'',VidName,'scatters');
%     display(length(allSpeedBins))
end

return
end
