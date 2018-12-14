function plotRefeeds(tracks, cmap, clim)
if ~exist('cmap', 'var')
    try
        load('..\cmap.mat', 'cmap', 'clim');
    catch
        load('cmap.mat', 'cmap', 'clim');
    end
end
strains = fields(tracks);
isSteadyState = false;
blankLawn = ones(3840, 5120);

for s = 1:length(strains)%get lawns
    lawns = {''};
    for w = 1:length(tracks.(strains{s}))
        lawnFile = split(tracks.(strains{s})(w).Name, '\');
        lawnFile = lawnFile{end-1};
        if ~ismember(lawnFile, lawns)
            lawns = [lawns; {lawnFile}];
            if ~isSteadyState
                try
                    load(sprintf('%s.lawnFile.mat', lawnFile), 'lawn');
                catch
                    try
                        lawnFile = split(lawnFile, '_');
                        lawnFile = [lawnFile{1} '_refeeding_' lawnFile{2} '_' lawnFile{3} '_' lawnFile{4}];
                        load(sprintf('%s.lawnFile.mat', lawnFile), 'lawn');
                    catch
                        answer = questdlg('Is there a lawnFile for these videos?');
                        if strcmp(answer, 'No')
                            isSteadyState = true; 
                            lawn = blankLawn;
                        else
                            error('Cannot find lawnFile. Make sure it is present in the current directory')
                        end
                    end
                end
            else
                lawn = blankLawn;
            end

            figure; imshow(lawn); hold on; title(sprintf('%s', lawnFile));
            tracks.(strains{s})(w).fig = gcf;
            tracks.(strains{s})(w).fig.Name = tracks.(strains{s})(w).Name;
        else
            tracks.(strains{s})(w).fig = findobj('type','figure','Name', tracks.(strains{s})(w).Name);
        end
    end
end

for s = 1:length(strains)
    for w = 1:length(tracks.(strains{s}))
        x = [tracks.(strains{s})(w).SmoothX NaN];
        y = [tracks.(strains{s})(w).SmoothY NaN];
        c = [tracks.(strains{s})(w).Speed NaN];
        figure(tracks.(strains{s})(w).fig);
        patch(x,y, c,'EdgeColor','interp', 'LineWidth', 1.25);
        ax = gca;
        colormap(ax, cmap);
        caxis(clim);
        colorbar;
    end
end

end