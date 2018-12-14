function NumFoundWorms = calc_background_ring_worm_count(PathName, moviefile, scaleRing, quick)

global Prefs;

Prefs.PID = randint(10000);

NumFoundWorms = NaN;

[pathstr, FilePrefix, ext] = fileparts(moviefile);

background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));

ringfile = sprintf('%s%s%s.%d.Ring.mat',PathName, filesep, FilePrefix, Prefs.PID);
final_ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
if(does_this_file_need_making(final_ringfile))
    rm(ringfile);
    rm(final_ringfile);
    
    if(isempty(scaleRing))
        Ring = find_ring(background,sprintf('%s%s',PathName,filesep), sprintf('%s.%d',FilePrefix,Prefs.PID), 1);
    else
        if(strcmp(Prefs.Ringtype(1:6),'square'))
            Ring = find_ring(background,sprintf('%s%s',PathName,filesep), sprintf('%s.%d',FilePrefix,Prefs.PID), 1, quick);
        else
            Ring = scaleRing;
        end
        Ring.PixelSize = scaleRing.PixelSize;
        save(ringfile, 'Ring');
    end
    
    
    % successfully found ring, so calc default threshold for finding animals
    if(~does_this_file_need_making(ringfile) || ~isempty(scaleRing))
        if(isempty(Ring.DefaultThresh))
            [DefaultLevel, NumFoundWorms, mws, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], 0, Ring, 1);
            save(ringfile, 'Ring');
        end
    end
    
    mv(ringfile, final_ringfile);
else
    load(final_ringfile);
    NumFoundWorms = Ring.NumWorms;
end

clear('Ring');
clear('background');

return;
end
