function pool = getAllNavTracks(dates, strains)%dates is cell array of folders with track files
    
    clean = {'Eccentricity' 'MajorAxes' 'RingDistance' 'Image' 'body_contour' 'NumFrames' 'numActiveFrames' 'original_track_indicies' 'Reorientations'...
        'State' 'body_angle' 'head_angle' 'tail_angle' 'midbody_angle' 'curvature_vs_body_position_matrix' 'Curvature' 'mvt_init' 'stimulus_vector'};
    
    varList = getVarList(dates, clean);
    pool = getPooledTracks(varList, strains);
    
end

function pool = getPooledTracks(varList, strains)%varList should be cell array of finalTracks structures

pool = struct();

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
               pool.(strains{s}) = [oldPool newPool];
           end
        end
    end
end

return
end

function varList = getVarList(dates, clean)

    varList = cell(length(dates), 1);
    for d = 1:length(dates)%d for day
        cd(dates{d});
%         if isempty(dir('navTracks_*.mat'))
%             trackFile = dir(sprintf('allTracks_%s*.mat', dates{d}));
%             trackFile = trackFile(end).name;
%             load(trackFile);
%             eval(sprintf('tracks = tracks_%s', dates{d}));
%             if ~isfield(tracks.N2, 'headingError') || ~isfield(tracks.N2, 'lawnDist') || ~isfield(tracks.N2, 'edge')
%                 tracks = addNavFields(tracks);
%             end
%         else
%             trackFile = dir('navTracks_*.mat');
%             trackFile = trackFile(end).name;
%             load(trackFile);
%             eval(sprintf('tracks = tracks_%s', dates{d}));
%         end
%         tracks = rmfield(tracks, clean);
        if ~isempty(dir('allNavTracks_*.mat'))
            trackFile = dir('allNavTracks_*.mat');
            trackFile = trackFile(end).name;
            load(trackFile);
            trackName = whos(matfile(trackFile));
            trackName = trackName.name;
            eval(sprintf('tracks = %s', trackName));
            strains = fields(tracks);
            if ~isfield(tracks.(strains{1}), 'headingError') || ~isfield(tracks.(strains{1}), 'lawnDist') || ~isfield(tracks.(strains{1}), 'edge') || ~isfield(tracks.(strains{1}), 'refed')
                tracks = addNavFields(tracks);
            end
        else
            tracks = getDayTracks(clean);
        end
        %clear({trackName}); ####$$$$
        varList{d} = tracks;
        cd ..
    end
    
return
end

function allFinalTracks = getDayTracks(clean)
    files = dir('*.finalTracks.mat'); %all finalTracks files should be in current directory

    for i=1:length(files)%make edge files if not present (front loaded)
        fileName = strread(files(i).name,'%s','delimiter','.');
        lawnFile = dir([fileName{1} '*.lawnFile.mat']);
        if isempty(lawnFile)
            edgeFile = dir([fileName{1} '*.edge.mat']);
            if ~isempty(edgeFile)
                load(edgeFile.name);
            else
                edge = [];
            end
            bgFile = dir([fileName{1} '*.background.mat']);
            load(bgFile.name);
            [edge, lawn] = findBorderManually(bkgnd, edge);
            save([fileName{1} '.lawnFile.mat'], 'edge', 'lawn');
        end
    end
    
    allFinalTracks = struct();
    for i=1:length (files)
        vidName = strread(files(i).name,'%s','delimiter','_');
        group = vidName{3}; 
        load(files(i).name);
        fileName = strread(files(i).name,'%s','delimiter','.');
        lawnFile = dir([fileName{1} '*.lawnFile.mat']);
        hold off; title([vidName{1} vidName{3:4}]);
        load(lawnFile(1).name);
        finalTracks = processRefeed(finalTracks, edge, lawn);
        if ~isempty(finalTracks) && length(fields(finalTracks))>0
           finalTracks = rmfield(finalTracks, clean);
           if (isfield(allFinalTracks,group))
               oldFinalTracks = allFinalTracks.(group);
               allFinalTracks.(group) = [oldFinalTracks finalTracks];
           else
               allFinalTracks.(group) = finalTracks;
           end
       end
    end

    strains = fields(allFinalTracks);
    N2s = contains(strains,'N2');
    strainOrder = [{strains{N2s}} {strains{~N2s}}];
    allFinalTracks = orderfields(allFinalTracks, strainOrder);
    allFinalTracks = addNavFields(allFinalTracks);

    num = 1;

    if length(unique({allFinalTracks.(strains{1}).Name})) == 1
        name = split(unique({allFinalTracks.(strains{1}).Name}), '\');
        name = name(end);
        name = split(name, '_');
        name = unique(name(1));
    else
        name = split(unique({allFinalTracks.(strains{1}).Name}), '\');
        name = name(:, :, end);
        name = split(name, '_');
        name = unique(name(:,:,1));
    end

    while exist(sprintf('allNavTracks_%s_%i.mat', name, num), 'file')
        num = num + 1;
    end

    eval(sprintf('tracks_%s = allFinalTracks', name))
    eval(sprintf('save(''allNavTracks_%s_%i.mat'', ''tracks_%s'')', name, num, name));

    return
end

function patchTracks = processRefeed(finalTracks, edge, lawn)%bkgrnd can also be passed as edge to expedite process and find lawn anew
    buffer = 3;%this version does not throw out any tracks
    
    imshow(lawn); hold on; plot(edge(:,1), edge(:,2),'LineWidth', 5);%reality check

    patchTracks = struct();
    
    for t=1:length(finalTracks)
        xAll = [];
        yAll = [];
        iAll = [];
        xydif = abs([finalTracks(t).bound_box_corner - finalTracks(t).Path]) + [finalTracks(t).Wormlength/(buffer*finalTracks(t).PixelSize)];
        bx1 = [finalTracks(t).SmoothX - xydif(:,1)'];
        bx1(bx1 < 1)= 1;
        bx2 = [finalTracks(t).SmoothX + xydif(:,1)'];
        bx2(bx2 > size(lawn,2))=size(lawn,2);
        by1 = [finalTracks(t).SmoothY - xydif(:,2)'];
        by1(by1 < 1) = 1;
        by2 = [finalTracks(t).SmoothY + xydif(:,2)'];
        by2(by2 > size(lawn,1))=size(lawn,1);
        [x1, y1, i1] = polyxpoly(bx1, by1, edge(:,1), edge(:,2));
            if ~isempty(i1)
                xAll = [x1(1)];
                yAll = [y1(1)];
                iAll = [i1(1)];
            end
        [x2, y2, i2] = polyxpoly(bx2, by1, edge(:,1), edge(:,2));
            if ~isempty(i2)
                xAll = [xAll x2(1)];
                yAll = [yAll y2(1)];
                iAll = [iAll i2(1)];
            end
        [x3, y3, i3] = polyxpoly(bx1, by2, edge(:,1), edge(:,2));
            if ~isempty(i3)
                xAll = [xAll x3(1)];
                yAll = [yAll y3(1)];
                iAll = [iAll i3(1)];
            end
        [x4, y4, i4] = polyxpoly(bx2, by2, edge(:,1), edge(:,2));
            if ~isempty(i4)
                xAll = [xAll x4(1)];
                yAll = [yAll y4(1)];
                iAll = [iAll i4(1)];
            end
        [x5, y5, i5] = polyxpoly(finalTracks(t).SmoothX , finalTracks(t).SmoothY,edge(:,1), edge(:,2));
            if ~isempty(i5)
                xAll = [xAll x5(1)];
                yAll = [yAll y5(1)];
                iAll = [iAll i5(1)];
            end
        i = min(iAll);
        x = xAll(iAll == i);
        y = yAll(iAll == i);
        plot(finalTracks(t).SmoothX(1:5:end), finalTracks(t).SmoothY(1:5:end))
        verdict = false;
        tempTracks = finalTracks(t);
        if ~isempty(i)%refine lawn encounter
            for v = 1:i
                if ~isnan(finalTracks(t).Path(v,:))
                    trackPoints = [bx1(v) by1(v); bx2(v) by1(v); bx1(v) by2(v); bx2(v) by2(v); finalTracks(t).Path(v,:)];

                    for tP = 1:length(trackPoints)
                        verdict = ~lawn(round(trackPoints(tP,2)), round(trackPoints(tP,1)));%verdict = not on lawn yet
                        if ~verdict
                            break
                        end
                    end
                    if ~verdict 
                        verdict = v >= 3;
                        i = v;
                        break;
                    end
                end
            end
        else
            tempTracks.refeedIndex = NaN;%%%NaN's for worms that don't make it to lawn or start there
        end
            
        if ~isempty(i) && verdict
           if i
               xy = finalTracks(t).Path(i(1),:);
               mapshow(x(1),y(1),'DisplayType','point','Marker','v');
               mapshow(xy(1),xy(2),'DisplayType','point','Marker','o');
               plot([xy(1) x(1)], [xy(2) y(1)]);
               tempTracks.refeedIndex = i(1);
           end
        elseif ~verdict && ~isempty(i)
            tempTracks.refeedIndex = NaN;%%%NaN's for worms that don't make it to lawn or start there
        end
            
        try
           patchTracks = [patchTracks tempTracks];
        catch
           patchTracks = tempTracks;
        end
    end
    
    return
end