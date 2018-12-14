function addNavFieldsBatch(dates)%dates is cell array of folders with track files
    
    for d = 1:length(dates)%d for day
        cd(dates{d});
        if isempty(dir('navTracks_*.mat'))
            trackFile = dir(sprintf('allTracks_%s*.mat', dates{d}));
            trackFile = trackFile(end).name;
            load(trackFile);
            eval(sprintf('tracks = tracks_%s', dates{d}));
            strains = fields(tracks);
            if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist')
                addNavFields(tracks);
                clearvars -except dates d
            else
                eval(sprintf('save(''navTracks_%s_1.mat'', ''tracks_%s'')', dates{d}, dates{d}));
            end
        end
        cd ..
    end
end