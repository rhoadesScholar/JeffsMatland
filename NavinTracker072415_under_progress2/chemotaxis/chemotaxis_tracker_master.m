function chemotaxis_tracker_master(movienames, ref_movie, plate_type, framerate)

global Prefs;
Prefs = [];

Prefs = define_preferences(Prefs);
aviread_to_gray;

if(nargin<1)
    disp(['usage: chemotaxis_tracker_master(movienames, ref_movie, plate_type, framerate)']);
    return;
end

if(nargin<2)
    ref_movie='';
end

if(nargin<3)
    plate_type = 'round';
end

if(nargin < 4)
    framerate = 3;
end

if(~iscell(movienames))
    tempname = movienames;
    clear('movienames');
    movienames{1} = tempname;
    clear('tempname');
end

% is a directory
if(isdir(movienames{1}))
    PathName = sprintf('%s%s',movienames{1},filesep);
    clear('movienames');
    
    dummystring = sprintf('%s*.avi',PathName);
    movieList = dir(dummystring);
    
    for j=1:length(movieList)
        movienames{j} = sprintf('%s%s',PathName, movieList(j).name);
    end
    clear('movieList');
end

trackflag = 0;
% parallel processing for animal finding
if(length(movienames)>1)
    if(Prefs.NumCPU > 3)
        prefsfile = sprintf('%s%sPrefs.%d.mat',tempdir,filesep,Prefs.PID);
        save(prefsfile, 'Prefs');
        num_cpus = Prefs.NumCPU;
        doneflag=0;
        while(doneflag == 0)
            doneflag = 1;
            
            for j=1:length(movienames)
                [PathName, FilePrefix] = fileparts(movienames{j});
                
                if(~isempty(PathName))
                    PathName = sprintf('%s%s',PathName,filesep);
                end
                
                ringfile = sprintf('%s%s.Ring.mat',PathName,  FilePrefix);
                regionfile = sprintf('%s%s.chemotaxis_regions.mat',PathName,  FilePrefix);
                
                working_file = sprintf('%s%s.Ring.working',PathName,  FilePrefix);
                
                if(does_this_file_need_making(ringfile) || does_this_file_need_making(regionfile))
                    doneflag = 0;
                    
                    if(file_existence(working_file) == 0)
                        fp = fopen(working_file,'w'); fclose(fp);
                        disp([sprintf('%s%s.avi\t%s',PathName,  FilePrefix, timeString())])
                        moviefile = sprintf('%s%s.avi',PathName,  FilePrefix);
                        
                        command = sprintf('cd %s; global Prefs; Prefs = []; load %s;', pwd, prefsfile);
                        command = sprintf('%s chemotaxis_tracker({''%s'', ''%s''}, ''%s'', %d, %d);', command, movienames{j}, ref_movie, plate_type, framerate, trackflag);
                        
                        if(num_cpus>1)
                            launch_matlab_command(command,1);
                            num_cpus = num_cpus - 1;
                        else
                            calc_background_ring_worm_count(PathName, moviefile, scaleRing);
                        end
                    end
                else
                    % working file exists and the ringfile exists ...
                    % so, the ringfile was just made
                    if(file_existence(working_file)==1 && does_this_file_need_making(ringfile) == 0)
                        num_cpus = num_cpus+1;
                        %                         load(ringfile);
                        %                         if(Ring.NumWorms < Prefs.DefaultNumWormRange(1) || Ring.NumWorms > Prefs.DefaultNumWormRange(2))
                        %                             animal_find_dud_idx = [animal_find_dud_idx; i j];
                        %                         end
                        clear('Ring');
                        rm(working_file);
                    end
                end
            end
            
            pause(2);
        end
    end
end

trackflag = 0;
for(i=1:length(movienames))
    chemotaxis_tracker({movienames{i}, ref_movie}, plate_type, framerate, trackflag);
end

for(i=1:length(movienames))
    Tracker(movienames{i});
end

trackflag = 1;
for(i=1:length(movienames))
    chemotaxis_tracker({movienames{i}, ref_movie}, plate_type, framerate, trackflag);
end

return;
end
