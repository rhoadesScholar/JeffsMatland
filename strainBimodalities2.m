function [results, allSpeedBins, allAngSpeedBins] = strainBimodalities2(allFinalTracks, date, bin, strains)
    if ~exist('strains', 'var')
        strains = fields(allFinalTracks);
    end
    
    xmax = 0;
    ymax = 0;
    
    for s=1:length(strains)%all strains
       [allSpeedBins.(strains{s}), allAngSpeedBins.(strains{s})] = getBins(allFinalTracks.(strains{s}), bin);
       xmax = max([xmax allSpeedBins.(strains{s})]);
       ymax = max([ymax allAngSpeedBins.(strains{s})]);
    end
    
    cmax = 0;
    
    for s=1:length(strains)%all strains
       results.(strains{s}) = checkBimodality_normalized(allSpeedBins.(strains{s}), allAngSpeedBins.(strains{s}), date, strains{s}, bin, xmax, ymax);
       fig.(strains{s}) = gcf;
       cmax = max([cmax caxis]);
    end
    
    for s=1:length(strains)%all strains
       fig.(strains{s});
       caxis([0 cmax]);
    end
    return
end

function [allSpeedBins, allAngSpeedBins] = getBins(finalTracks,binsize)
    binnedSpeed = binSpeed(finalTracks,binsize);
    binnedAngSpeed = binAngSpeed(finalTracks,binsize);

    allSpeedBins = [];
    allAngSpeedBins = [];
    for i=1:(length(finalTracks))
        allSpeedBins = [allSpeedBins binnedSpeed(i).Speed];
        allAngSpeedBins = [allAngSpeedBins binnedAngSpeed(i).AngSpeed];
    end

    return
end

function result = checkBimodality_normalized(allSpeedBins, allAngSpeedBins,Date,Genotype,binsize, xmax, ymax)

    if ~isempty(findall(0,'Type','Figure'))
        figure
    end
    result = hist_normalised_disp(allSpeedBins,allAngSpeedBins,0.003,2, xmax, ymax);
    ylabel('Speed (mm/sec)')
    xlabel('Angular Speed (deg/sec)')
    title(sprintf('binSize = %d sec',binsize/3));
     axis([0 180 0 0.25]);
     cmap = [jet(255)];
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


function result = hist_normalised_disp(vx, vy, dx, dy, xmax, ymax)

    % xmax = max(vx); ymax = max(vy);
    nx = ceil((xmax) / dx); ny = ceil((ymax) / dy);

    result = zeros(nx,ny);
    binx = ceil(vx ./ dx); biny = ceil(vy ./ dy);

    binx(binx==0)=1;
    biny(biny==0)=1;

    n = min(length(vx),length(vy));

    for i = 1:n
        if ~isnan(binx(i)*biny(i))
            result(binx(i),biny(i)) = result(binx(i),biny(i))+1;
        end
    end

    result = normalise(result);


    imagesc((1:size(result,2))*dy,(1:size(result,1))*dx,result);
    cmap = [1 1 1; jet(254)];
    colormap(cmap);
    axis xy;

    return
end