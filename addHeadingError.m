function tracks = addHeadingError(tracks)

    strains = fields(tracks);
    edges = struct();
    for s = 1:length(strains)
        if ~isfield(tracks.(strains{s}), 'headingError') %get headingError
            for w = 1:length(tracks.(strains{s}))
                Path = tracks.(strains{s})(w).Path;
                edgeFile = split(tracks.(strains{s})(w).Name, '\');
                edgeFile = edgeFile{end-1};
                if ~isfield(edges, 'Name') || ~ismember(edgeFile, [edges(:).Name])
                    try
                        edges(end+(isfield(edges, 'Name'))).Name = {edgeFile};
                        edges(end).edge = load(sprintf('%s.lawnFile.mat', edgeFile), 'edge');
                    catch
                        try
                            edgeFile2 = split(edgeFile, '_');
                            edgeFile2 = [edgeFile2{1} '_refeeding_' edgeFile2{2} '_' edgeFile2{3} '_' edgeFile2{4}];
                            edges(end).edge = load(sprintf('%s.lawnFile.mat', edgeFile2), 'edge');
                        catch
                            error('Cannot find lawnFile. Make sure it is present in the current directory')
                        end
                    end
                end
                edge = [edges(ismember([edges(:).Name], edgeFile)).edge];
                edge = edge.edge;%yeah, i know this is dumb. i will not be offended if you fix it. good luck.
                headingError = arrayfun(@(i) getHeadingError(edge, [Path(i,1), Path(i,2); Path(i-1,1), Path(i-1,2)]), 2:length(Path));
                tracks.(strains{s})(w).headingError = headingError;
            end
        end
    end

    %now save it
    num = 1;
    if length(unique({tracks.(strains{1}).Name})) == 1
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(end);
        name = split(name, '_');
        name = unique(name(1));
    else
        name = split(unique({tracks.(strains{1}).Name}), '\');
        name = name(:, :, end);
        name = split(name, '_');
        name = unique(name(:,:,1));
    end
    while exist(sprintf('allTracks_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end

    eval(sprintf('tracks_%s = tracks', name))
    eval(sprintf('save(''allTracks_%s_%i.mat'', ''tracks_%s'')', name, num, name));

    return

end