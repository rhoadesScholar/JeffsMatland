function pool = getPooledNavTracks(dates, strains)%dates is cell array of folders with track files
    
    clean = {'Eccentricity' 'MajorAxes' 'RingDistance' 'Image' 'body_contour' 'NumFrames' 'numActiveFrames' 'original_track_indicies' 'Reorientations'...
        'State' 'body_angle' 'head_angle' 'tail_angle' 'midbody_angle' 'curvature_vs_body_position_matrix' 'Curvature' 'mvt_init' 'stimulus_vector'};
    
    varList = getVarList(dates, strains, clean);
    pool = getPooledTracks(varList, strains);
    
end

function pool = getPooledTracks(varList, strains)%varList should be cell array of finalTracks structures

pool = struct();

%if ~contains(strains{s}, 'fed', 'IgnoreCase', true) || (contains(strains{s}, 'fed', 'IgnoreCase', true) && (track.Time(track.refeedIndex)/60 <= fedDelay))
for s = 1:length(strains)
    for t = 1:length(varList)
        if isfield(varList{t}, strains{s}) && ~isfield(pool, strains{s})
           pool.(strains{s}) = varList{t}.(strains{s});
        elseif isfield(varList{t}, strains{s})
           oldPool = pool.(strains{s});
           try
               pool.(strains{s}) = [oldPool varList{t}.(strains{s})];
           catch
               newPool = varList{t}.(strains{s});
               newFields = fields(newPool);
               oldFields = fields(oldPool);
               if length(newFields) > length(oldFields)
                   newPool = rmfield(newPool, setdiff(newFields, oldFields));
               elseif length(oldFields) > length(newFields)
                   oldPool = rmfield(oldPool, setdiff(oldFields, newFields));
               end 
               pool.(strain) = [oldPool newPool];
           end
        end
    end
end

return
end

function varList = getVarList(dates, strains, clean)

    varList = cell(length(dates), 1);
    for d = 1:length(dates)%d for day
        cd(dates{d});
        if isempty(dir('navTracks_*.mat'))
            trackFile = dir(sprintf('allTracks_%s*.mat', dates{d}));
            trackFile = trackFile(end).name;
            load(trackFile);
            eval(sprintf('tracks = tracks_%s', dates{d}));
            if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist') || ~isfield(tracks.(strains{1}), 'edge')
                tracks = addNavFields(tracks);
            end
        else
            trackFile = dir('navTracks_*.mat');
            trackFile = trackFile(end).name;
            load(trackFile);
            eval(sprintf('tracks = tracks_%s', dates{d}));
        end
        tracks = rmfield(tracks, clean);
        varList{d} = tracks;
        cd ..
    end
    
return
end