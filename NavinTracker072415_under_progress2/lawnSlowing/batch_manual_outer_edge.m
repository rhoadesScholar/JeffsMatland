function batch_manual_outer_edge(dirname)

lawn_diameter = 6; % in mm
framerate=1;
timerbox_flag=1;

global Prefs;
Prefs = [];
Prefs = define_preferences(Prefs);

Prefs.lawn_diameter = lawn_diameter;
Prefs.FrameRate = framerate;
Prefs.timerbox_flag = timerbox_flag;

PathName = deblank(dirname);
if(PathName(end)~=filesep)
    PathName = sprintf('%s%s',PathName, filesep);
end

dummystring = sprintf('%s*.avi',PathName);
movieList = dir(dummystring);

for(j=1:length(movieList))
    MovieName = sprintf('%s%s',PathName, movieList(j).name);
    [pn, FilePrefix, ext] = fileparts(MovieName);
    outeredge_filename = sprintf('%s%s.outer_edge.mat',PathName, FilePrefix);
    
    if(~file_existence(outeredge_filename))
        MovieName = sprintf('%s%s',PathName, movieList(j).name);
        [pn, FilePrefix, ext] = fileparts(MovieName);
        outeredge_filename = sprintf('%s%s.outer_edge.mat',PathName, FilePrefix);
        
        FileInfo = moviefile_info(MovieName);
        FrameNum = FileInfo.NumFrames;
        if FrameNum < 3500
            startframe = 1;
            endframe = 1800;
        else
            if FrameNum < 5300
                startframe = 1801;
                endframe = 3600;
            else
                startframe = 3601;
                endframe = 5400;
            end
        end
        
        if(file_existence(outeredge_filename))
            load(outeredge_filename);
        else
            outer_edge=[];
            
            disp([sprintf('Manually assign outer edge %s',MovieName)])
            
            background = calculate_background(MovieName,startframe,endframe);
            outer_edge = outer_edge_check(background, outer_edge);
            
            save(outeredge_filename, 'outer_edge');
            
            clear('background');
            clear('outer_edge');
        end
    end
end

return;
end
