function fork_process_movie_frames(MovieName,localpath, FilePrefix, stimulusfile, startFrame, endFrame, target_numworms)

global Prefs;

if(~isempty(localpath))
    RingFile = sprintf('%s%s%s.Ring.mat',localpath, filesep, FilePrefix);
else
    RingFile = sprintf('%s.Ring.mat',FilePrefix);
end
command = '';
command = sprintf('%s load(''%s'');',command, RingFile);
command = sprintf('%s global Prefs; Prefs=[]; Prefs = define_preferences(Prefs); Prefs.FrameRate = Ring.FrameRate; Prefs.PID = %d; Prefs.aggressive_wormfind_flag = %d; Prefs.timerbox_flag = %d; Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize); Prefs.no_collisions_flag = %d;',command, Prefs.PID, Prefs.aggressive_wormfind_flag, Prefs.timerbox_flag, Prefs.no_collisions_flag);


command = sprintf('%s master_process_movie_frames(''%s'', ''%s'', ''%s'', Ring, ''%s'', %d, %d, %d);', ...
                    command, MovieName, localpath, FilePrefix, stimulusfile, startFrame, endFrame, target_numworms);

launch_matlab_command(command, 1);
disp([sprintf('Launched process for frames %d to %d\t%s',startFrame, endFrame, timeString)])
            
return;
end
