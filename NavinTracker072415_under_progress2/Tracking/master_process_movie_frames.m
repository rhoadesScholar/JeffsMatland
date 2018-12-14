function procFrame = master_process_movie_frames(MovieName, localpath, FilePrefix, Ring, stimulusfile, startFrame, endFrame, target_numworms)

global Prefs;

file_info = moviefile_info(MovieName);

% disp(sprintf('Now defining the local background and boundry\t%s',timeString()))


if(Prefs.use_global_background_flag == 1)
    background = calculate_background(MovieName, 1, file_info.NumFrames);
else
    background = calculate_background(MovieName, startFrame, endFrame);
end

q=1;
for(i=startFrame:endFrame)
    procFrame(q).frame_number = i;
    procFrame(q).bkgnd_index = 1; % all frames use the same background unless otherwise specified
    procFrame(q).threshold = 0;
    q=q+1;
end


if(isempty(Ring.NumWorms) || isempty(Ring.DefaultThresh) || isempty(Ring.meanWormSize))
    [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(MovieName, background, procFrame, target_numworms, Ring);
    
    if(startFrame==1 && endFrame==file_info.NumFrames)
        dummystring = sprintf('%s%s.Ring.mat',localpath, FilePrefix);
    else
        dummystring = sprintf('%s%s.%d_%d.Ring.mat',localpath, FilePrefix, startFrame, endFrame);
    end
    
    save(dummystring, 'Ring');
end

procFrame = process_movie_frames(MovieName, background, Ring, procFrame);
dummystring = sprintf('%s%s.%d_%d.procFrame.mat',localpath, FilePrefix, startFrame, endFrame);
save_procFrame(dummystring,procFrame);

clear('background');

if(startFrame>1 || endFrame<file_info.NumFrames)
    dummystring = sprintf('%s%s.%d.%d.background.mat',localpath, FilePrefix, startFrame, endFrame);
    rm(dummystring);
end

return;
end

