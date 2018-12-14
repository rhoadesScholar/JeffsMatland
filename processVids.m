function processVids(dates, numworms, small) %dates is a cell array with lists of foldernames with subfolders to be processed (generally organized by dates videos were taken)

faults = {};
f = 1;

for d=1:length(dates)
    cd (char(dates(d)))
    folders = dir; %avi should be in own folder named date_genotype_vid#_Cam#
    vids = {};
    for i=3:length(folders)
        vids(i-2)={folders(i).name};
        cam = char(vids(i-2));
        cam = cam((length(cam)-3):end);
        measure = strcat('..\measure', cam, '.avi');
        try
            if exist('numworms')
                if exist('small') && small
                    JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure), 'numworms', numworms, 'none'); %FOR SMALL PLATES
                else
                    JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure), 'numworms', numworms);
                end
            else
                if exist('small') && small
                    JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure), 'none'); %FOR SMALL PLATES
                else
                    JeffsTrackerAutomatedScript(vids{i-2}, 'quick', 'scale', char(measure));
                end
            end
        catch
            faults{f} = sprintf('%s failed JeffsTrackerAutomatedScript\n', vids{i-2});
            f = f + 1;
        end
    end
    
    for i=1:length(vids)
        try
            processTracks(char(vids(i)));
        catch
            faults{f} = sprintf('%s failed processTracks\n', vids{i});
            f = f + 1;
        end
    end
    cd ..
end

for v = 1:f-1
    fprintf('%s \n', faults{v})
end

end
