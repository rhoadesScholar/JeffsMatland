function [allFinalTracks] = getCleanFinalTracks(nested) %filenames must be Date_Group_vid#.finalTracks.mat
%nested is boolean indicating whether all mat files are in same folder or
%individual folders
if nargin < 1
    nested = false;
end
allFinalTracks = struct();
clean = {'Eccentricity'
    'MajorAxes'
    'RingDistance'
    'Image'
    'body_contour'
    'NumFrames'
    'numActiveFrames'
    'original_track_indicies'
    'Reorientations'
    'State'
    'body_angle'
    'head_angle'
    'tail_angle'
    'midbody_angle'
    'curvature_vs_body_position_matrix'
    'Curvature'
    'mvt_init'
    'stimulus_vector'};

if nested
    folders = dir; %each video's files should be in own folder named date_genotype_vid#(_Cam#)...
    folders = folders([folders.isdir]);
    for i=3:length (folders)
        refeed = false;
        fileName = strread(folders(i).name,'%s','delimiter','_');
        if strcmp(fileName{2},'refeeding')
            group = [fileName{3} '_rf'];
            refeed = true;
        else
            group = fileName{2};
        end
        cd (folders(i).name)
        file = dir('*.finalTracks.mat');
        load(file.name);
        if refeed
            lawnFile = dir('*.lawnFile.mat');
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
                vidName = strread(folders(i).name,'%s','delimiter','.');
                save([vidName{1} '.lawnFile.mat'], 'edge', 'lawn');
            else
                load(lawnFile(1).name);
                figure; hold on; title([fileName{1} fileName{3:4}]);
            end
            finalTracks = processRefeed(finalTracks, edge, lawn);
        end
        finalTracks = rmfield(finalTracks, clean);
       if (isfield(allFinalTracks,group))
           oldFinalTracks = allFinalTracks.(group);
           allFinalTracks.(group) = [oldFinalTracks finalTracks];
       else
           allFinalTracks.(group) = finalTracks;
       end
       cd ..
    end
else
    files = dir('*.finalTracks.mat'); %all finalTracks files should be in current directory
    for i=1:length (files)
        refeed = false;
        vidName = strread(files(i).name,'%s','delimiter','_');
        if strcmp(vidName{2},'refeeding')
            group = [vidName{3} '_rf'];
            refeed = true;
        else
            group = vidName{2};
        end
        load(files(i).name);
        if refeed
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
            else
                figure; hold on; title([vidName{1} vidName{3:4}]);
                load(lawnFile(1).name);
            end
            finalTracks = processRefeed(finalTracks, edge, lawn);
        end
       if ~isempty(finalTracks)
           finalTracks = rmfield(finalTracks, clean);
           if (isfield(allFinalTracks,group))
               oldFinalTracks = allFinalTracks.(group);
               allFinalTracks.(group) = [oldFinalTracks finalTracks];
           else
               allFinalTracks.(group) = finalTracks;
           end
       end
    end

end

strains = fields(allFinalTracks);
N2s = contains(strains,'N2');
strainOrder = [{strains{N2s}} {strains{~N2s}}];
allFinalTracks = orderfields(allFinalTracks, strainOrder);
return

end