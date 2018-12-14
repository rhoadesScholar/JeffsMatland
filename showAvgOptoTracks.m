function showAvgOptoTracks(tracks, indie)
    for o = 1:length({tracks.opto})
        optoTracks(o).refed = tracks(o).opto.refed;
        optoTracks(o).speeds = tracks(o).opto.speeds;
        optoTracks(o).fluors = tracks(o).opto.fluors;
    end
    
    preSpan = max(arrayfun(@(x) find(x.refed, 1), optoTracks)) - 1;
    postSpan = max(arrayfun(@(x) max([find(~flip(x.refed), 1) isempty(find(~flip(x.refed), 1))*length(x.refed)]), optoTracks)) - 1;
    cleanTracks.refed = [zeros(1, preSpan) ones(1, postSpan)];
    
    preSpeeds = NaN(length(optoTracks), preSpan);
    postSpeeds = NaN(length(optoTracks),postSpan);
    preFluors = NaN(length(optoTracks), preSpan);
    postFluors = NaN(length(optoTracks),postSpan);
    
    for w = 1:length(optoTracks)
        speed = optoTracks(w).speeds;
        fluor = optoTracks(w).fluors;
        
%         SPEEDS
        preFedSpeed = speed(~optoTracks(w).refed);
        postFedSpeed = speed(optoTracks(w).refed == 1);
        
        preSpeeds(w, 1:length(preFedSpeed)) = fliplr(preFedSpeed');%NOTE: in reverse order for alignment purposes
        postSpeeds(w, 1:length(postFedSpeed)) = postFedSpeed';  
        
%         FLUORS
        preFedFluor = fluor(~optoTracks(w).refed);
        postFedFluor = fluor(optoTracks(w).refed == 1);
        
        preFluors(w, 1:length(preFedFluor)) = fliplr(preFedFluor');%NOTE: in reverse order for alignment purposes
        postFluors(w, 1:length(postFedFluor)) = postFedFluor';
    end
    cleanTracks.speeds = [fliplr(preSpeeds) postSpeeds];
    cleanTracks.fluors = [fliplr(preFluors) postFluors];
    
    if size(cleanTracks.speeds,1) > 1
        avgSpeed = nanmean(cleanTracks(:).speeds);
        avgFluor = nanmean(cleanTracks(:).fluors);
        if ~indie
            stdErrSpeed = std(cleanTracks.speeds,'omitnan')./sqrt(sum(~isnan([cleanTracks.speeds])));
            stdErrFluor = std(cleanTracks.fluors,'omitnan')./sqrt(sum(~isnan([cleanTracks.fluors])));
        end
    else
        avgSpeed = (cleanTracks.speeds);
        avgFluor = (cleanTracks.fluors);

        stdErrSpeed = 0;
        stdErrFluor = 0;
    end
    
    if ~indie
        showStrainTracksStdErr(length(optoTracks), avgSpeed, avgFluor, stdErrSpeed, stdErrFluor,...
            cleanTracks.refed, 10, preSpan, postSpan)
    else
        showStrainTracksIndie(length(optoTracks), avgSpeed, avgFluor, cleanTracks.speeds, cleanTracks.fluors,...
            cleanTracks.refed, 10, preSpan, postSpan)
    end
end


function [t, timey] = showStrainTracksStdErr(num, speed, fluor, stdErrSpeed, stdErrFluor,...
    refed, frameRate, preSpan, postSpan)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
    end
    
    figure;
    hold on;
    title(sprintf('(n = %i), NSM Calcium vs. Speed\n', num)); %(median window smoothing = -%0.2f  to +%0.2f seconds)
    xlabel(sprintf('Time (%s)', timey));
    
    yyaxis left
    err = stdErrFluor;
    errorshade(t,[fluor + err],[fluor - err], [0 .8 0]);
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1)
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])
    set(gca, 'ylim', [-2 4])
    grid on
    
    yyaxis right
    err = stdErrSpeed;
    errorshade(t,[speed + err],[speed - err], 'b');
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1)
    ylabel('Speed (um/sec)');
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    set(gca, 'xlim', [min(t) max(t)]);%###################XLIM
%     set(gca, 'xlim', [-(medSpan+medBuf)/60 4]);
    xs = xlim;
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);

    ys = [-9999 9999];
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];

    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.13, 'LineStyle', ':');

end

function showStrainTracksIndie(num, speed, fluor, indieSpeeds, indieFluors,...
    refed, frameRate, preSpan, postSpan)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
    end
    
    figure;
    hold on;
    title(sprintf('(n = %i), NSM Calcium vs. Speed', num));
    xlabel(sprintf('Time (%s)', timey));
    ylabel('Speed (um/sec)');
%     for w = 1:size(indieSpeeds,1)
%         plot(t,indieSpeeds(w, :), 'Color', 'b', 'LineStyle', ':', 'LineWidth', 0.1);
%     end
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1.5)
    yyaxis left
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    yyaxis right
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1.5)
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])
    set(gca, 'ylim', [-2 2])

    set(gca, 'xlim', [min(t) max(t)]);
    xs = xlim;
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);

    ys = ylim;
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];

    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
    
    for w = 1:size(indieFluors,1)
        disp('Press any key to continue');
        pause;
        yyaxis right
        plot(t,indieSpeeds(w, :), 'Color', 'b', 'LineWidth', 0.001, 'Marker', 'none', 'LineStyle', ':');
        yyaxis left
        plot(t,indieFluors(w, :), 'Color', [0 .8 0], 'LineWidth', 0.001, 'Marker', 'none', 'LineStyle', ':');
    end
    
end