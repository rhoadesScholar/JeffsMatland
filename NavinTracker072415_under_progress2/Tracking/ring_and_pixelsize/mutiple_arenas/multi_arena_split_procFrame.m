function multi_arena_split_procFrame(input_procFrame, input_Ring, stimulusfile, localpath, FilePrefix)

% this input_Ring does not contain multiple arenas
if(~isfield(input_Ring,'arena_name'))
    return;
end


if(~isempty(localpath))
    original_avifile = sprintf('%s%s%s.avi',localpath, filesep, FilePrefix);
else
    original_avifile = sprintf('%s.avi', FilePrefix);
end

disp([sprintf('Splitting the arenas in %s\t%s',original_avifile,timeString)])

file_info = moviefile_info(original_avifile);
num_frame_pix = 0.05*file_info.Width;

% the RingX and RingY arrays contain the coords of the manually selected
% arena perimeters, which are necessarily closed ie: have the same vertex
% point at the start and the end of the list

ring_pointer=1;
for(ss=1:length(input_Ring.arena_name))
    
    disp([sprintf('Creating directory and files for strain.arena %s\t%s',input_Ring.arena_name{ss},timeString)])
    
    straindir = input_Ring.arena_name{ss}(1:end-2);
    
    if(~isempty(localpath))
        newpath = sprintf('%s%s%s',localpath, filesep, straindir);
    else
        newpath = sprintf('%s', straindir);
    end
    
    mkdir(newpath);
    pref = sprintf('%s%s%s.%s',newpath, filesep, FilePrefix, input_Ring.arena_name{ss});
    
    procFrame_file = sprintf('%s.procFrame.mat',pref);
    
    
    
    start_idx = ring_pointer;
    arena_start_vertex_x = input_Ring.RingX(start_idx);
    arena_start_vertex_y = input_Ring.RingY(start_idx);
    
    
    % find the points that have the same coords as input_Ring.RingX(ring_pointer), input_Ring.RingY(ring_pointer)
    ring_pointer = find(input_Ring.RingX == arena_start_vertex_x & input_Ring.RingY == arena_start_vertex_y);
    ring_pointer = ring_pointer(2); % the first one we already have as arena_start_vertex_x, arena_start_vertex_y
    end_idx = ring_pointer;
    
    
    step = round((end_idx-start_idx+1)/20); % no need to define the polygon at every point
    
    arena_perimeter_x = [input_Ring.RingX(start_idx:step:end_idx-1); input_Ring.RingX(end_idx)];
    arena_perimeter_y = [input_Ring.RingY(start_idx:step:end_idx-1); input_Ring.RingY(end_idx)];
    
    if(does_this_file_need_making(procFrame_file))
        procFrame = [];
        for(p=1:length(input_procFrame))
            
            X=[];
            Y=[];
            for(w=1:length(input_procFrame(p).worm))
                X = [X input_procFrame(p).worm(w).coords(1)];
                Y = [Y input_procFrame(p).worm(w).coords(2)];
            end
            worms_in_arena_idx = inpolygon(X,Y,arena_perimeter_x,arena_perimeter_y);
            
            X=[];
            Y=[];
            for(w=1:length(input_procFrame(p).clump))
                X = [X input_procFrame(p).clump(w).coords(1)];
                Y = [Y input_procFrame(p).clump(w).coords(2)];
            end
            clumps_in_arena_idx = inpolygon(X,Y,arena_perimeter_x,arena_perimeter_y);
            
            procFrame(p).frame_number = input_procFrame(p).frame_number;
            procFrame(p).bkgnd_index = input_procFrame(p).bkgnd_index;
            procFrame(p).threshold = input_procFrame(p).threshold;
            procFrame(p).timestamp = input_procFrame(p).timestamp;
            
            
            procFrame(p).worm = input_procFrame(p).worm;
            for(k=1:length(input_procFrame(p).worm))
                procFrame(p).worm(k).tracked = 1;
                procFrame(p).worm(k).coords = [NaN NaN];
                procFrame(p).worm(k).size = NaN;
                procFrame(p).worm(k).image = [];
                procFrame(p).worm(k).bound_box_corner = [NaN NaN];
                procFrame(p).worm(k).next_worm_idx = [];
                procFrame(p).worm(k).ecc = NaN;
                procFrame(p).worm(k).majoraxis = NaN;
                procFrame(p).worm(k).ringDist = NaN;
                procFrame(p).worm(k).body_contour = [];
            end
            
            for(k=1:length(worms_in_arena_idx))
                if(worms_in_arena_idx(k)==1)
                    procFrame(p).worm(k) = input_procFrame(p).worm(k);
                    procFrame(p).worm(k).tracked = 0;
                end
            end
            
              
            procFrame(p).clump = input_procFrame(p).clump;
            for(k=1:length(input_procFrame(p).clump))
                procFrame(p).clump(k).coords = [NaN NaN];
                procFrame(p).clump(k).size = NaN;
                procFrame(p).clump(k).image = [];
                procFrame(p).clump(k).bound_box_corner = [NaN NaN];
            end
            for(k=1:length(clumps_in_arena_idx))
                if(clumps_in_arena_idx(k)==1)
                    procFrame(p).clump(k) = input_procFrame(p).clump(k);
                end
            end
            
            worms_in_arena_idx = [];
            clumps_in_arena_idx = [];
        end
        
        % eliminate links to worms in other arenas
        for(p=1:length(procFrame))
            for(k=1:length(procFrame(p).worm))
                if(~isempty(procFrame(p).worm(k).next_worm_idx))
                    if(procFrame(p).worm(k).next_worm_idx<1000)
                        if(procFrame(p+1).worm(procFrame(p).worm(k).next_worm_idx).tracked==1)
                            procFrame(p).worm(k).next_worm_idx = [];
                        end
                    end
                end
            end
        end
                
        save_procFrame(procFrame_file,procFrame);
        clear('procFrame');
    end
    
    dummy_avi_filename = sprintf('%s.avi',pref);
    
    disp([sprintf('Saving %s and dummy movie file %s\t%s',procFrame_file,dummy_avi_filename,timeString)])
    
    
    
    truncate_avifile(original_avifile, dummy_avi_filename, 1, 2, ...
        [ min(arena_perimeter_x)-num_frame_pix max(arena_perimeter_x)+num_frame_pix min(arena_perimeter_y)-num_frame_pix max(arena_perimeter_y)+num_frame_pix ], 0);
    
    
    
    Ring.RingX = input_Ring.RingX(start_idx:end_idx);
    Ring.RingY = input_Ring.RingY(start_idx:end_idx);
    
    if(~isempty(input_Ring.ComparisonArrayX))
        Ring.ComparisonArrayX = input_Ring.ComparisonArrayX(start_idx:end_idx);
        Ring.ComparisonArrayY = input_Ring.ComparisonArrayY(start_idx:end_idx);
    else
        Ring.ComparisonArrayX = [];
        Ring.ComparisonArrayY = [];
    end
    
    Ring.Area = input_Ring.Area;
    Ring.ring_mask =  input_Ring.ring_mask;
    Ring.Level = input_Ring.Level;
    Ring.PixelSize = input_Ring.PixelSize;
    Ring.FrameRate = input_Ring.FrameRate;
    Ring.NumWorms = input_Ring.NumWorms;
    Ring.DefaultThresh = input_Ring.DefaultThresh;
    Ring.meanWormSize = input_Ring.meanWormSize;
    
    
    ringfile_name = sprintf('%s.Ring.mat',pref);
    save(ringfile_name,'Ring');
    
    clear('Ring');
    
    ring_pointer = ring_pointer+1;
    
end
clear('input_procFrame');

close all
pause(1);

for(ss=1:length(input_Ring.arena_name))
    straindir = input_Ring.arena_name{ss}(1:end-2);
    if(~isempty(localpath))
        newpath = sprintf('%s%s%s',localpath, filesep, straindir);
    else
        newpath = sprintf('%s', straindir);
    end
    pref = sprintf('%s.%s', FilePrefix, input_Ring.arena_name{ss});
    
    
    disp([sprintf('Analysing worms for strain.arena %s\t%s',input_Ring.arena_name{ss},timeString)])
    
    % Tracker(localpath, pref, stimulusfile);
    command = sprintf('Tracker(''%s'',''%s'',''%s'','''',''framerate'',%d);', newpath, pref, stimulusfile, input_Ring.FrameRate);
    eval(command);
    
    trackfilename = sprintf('%s%s%s.Tracks.mat',newpath,filesep,pref);
    load(trackfilename);
    for(i=1:length(Tracks))
        Tracks(i).Name =  original_avifile;
    end
    save_Tracks(trackfilename,Tracks);
    
    trackfilename = sprintf('%s%s%s.linkedTracks.mat',newpath,filesep,pref);
    load(trackfilename);
    for(i=1:length(linkedTracks))
        linkedTracks(i).Name =  original_avifile;
    end
    save_Tracks(trackfilename,linkedTracks);
    
    
end


return;
end
