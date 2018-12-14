function processSmallVids(dates, numworms) %dates is a cell array with lists of foldernames with subfolders to be processed (generally organized by dates videos were taken)

for d=1:length(dates)
    cd (char(dates(d)))
    folders = dir; %avi should be in own folder named date_genotype_vid#_Cam#
    vids = {};
    for i=3:length (folders)
        vids(i-2)={folders(i).name};
        cam = char(vids(i-2));
        cam = cam((length(cam)-3):end);
        measure = strcat('..\measure', cam, '.avi');
        if exist('numworms')
            JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure), 'numworms', numworms, 'none'); %FOR SMALL PLATES
        else
            JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure), 'none'); %FOR SMALL PLATES            
        end
        %JeffsTrackerAutomatedScript(vids(i-2), 'scale', char(measure));
    end
    for i=1:length(vids)
        try
            processTracks(char(vids(i)));
        catch
            fprintf('%s failed processTracks\n', vids{i});
            pause
        end
    end
    cd ..
end

end
