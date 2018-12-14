function checkBimodality(finalTracks,Date,Genotype,bin)
x = [bin];
index = 0;
for(binsize = x)
    
    index = index+1;
    binnedSpeed = binSpeed(finalTracks,binsize);
    binnedAngSpeed = binAngSpeed(finalTracks,binsize);
    
    allSpeedBins = [];
    allAngSpeedBins = [];
    for (i=1:(length(finalTracks)))
        allSpeedBins = [allSpeedBins binnedSpeed(i).Speed];
        allAngSpeedBins = [allAngSpeedBins binnedAngSpeed(i).AngSpeed];
    end
    
%     if(binsize == 3)
%         allSpeedBinsRev = allSpeedBins(1:20:length(allSpeedBins));
%         allAngSpeedBinsRev = allAngSpeedBins(1:20:length(allAngSpeedBins));
%     else if(binsize == 6)
%             allSpeedBinsRev = allSpeedBins(1:10:length(allSpeedBins));
%             allAngSpeedBinsRev = allAngSpeedBins(1:10:length(allAngSpeedBins));
%             else if(binsize == 9)
%             allSpeedBinsRev = allSpeedBins(1:6:length(allSpeedBins));
%             allAngSpeedBinsRev = allAngSpeedBins(1:6:length(allAngSpeedBins));
%                 else if(binsize == 15)
%                 allSpeedBinsRev = allSpeedBins(1:4:length(allSpeedBins));
%                 allAngSpeedBinsRev = allAngSpeedBins(1:4:length(allAngSpeedBins));
%                     else if(binsize == 30)
%                     allSpeedBinsRev = allSpeedBins(1:2:length(allSpeedBins));
%                     allAngSpeedBinsRev = allAngSpeedBins(1:2:length(allAngSpeedBins));
%                         else 
%                         allSpeedBinsRev = allSpeedBins;
%                         allAngSpeedBinsRev = allAngSpeedBins;
%                 end
%                 end
%                 end
%         end
%     end
    
%     subplot(2,3,index);
%     scatter(allSpeedBinsRev,allAngSpeedBinsRev,2);
%     xlabel('Speed (mm/sec)')
%     ylabel('Angular Speed (deg/sec)')
%     title(sprintf('binSize = %d sec',binsize/3));
%     axis([0 0.25 0 180]);
    %subplot(2,3,index);
    hist2(allSpeedBins,allAngSpeedBins,0.003,2);
    ylabel('Speed (mm/sec)')
    xlabel('Angular Speed (deg/sec)')
    title(sprintf('binSize = %d sec',binsize/3));
     axis([0 180 0 0.25]);
     cmap = [hot(255)]
     colormap(cmap);
    % set(gca,'CLim',[0 26]);
     %set(gca,'Color',[0 0 0])
end
set(findobj(gcf,'type','axes'),'Color',[0 0 0]);
VidName = sprintf('%s.%s',Date,Genotype);

set(1,'Name',VidName);
save_figure(1,'',VidName,'scatters');
display(length(allSpeedBins))
