function exploration_stats = track_exploration_stats(inputTrack, starttime, endtime)
% exploration_stats = track_exploration_stats(Track, [starttime], [endtime])
% exploration_stats.pathlength = actual distance travelled (mm)
% exploration_stats.path_displacement = distance from start and end of the track (mm)
% exploration_stats.tortuosity = pathlength/path_displacement (unitless)
% exploration_stats.area_explored = total area sampled by the worm's body (mm^2)
% exploration_stats.efficiency = area_explored/pathlength

if(nargin<1)
    disp('usage: exploration_stats = track_exploration_stats(Track, [starttime], [endtime])')
    disp('exploration_stats.pathlength = actual distance travelled (mm)')
    disp('exploration_stats.path_displacement = distance from start and end of the track (mm)')
    disp('exploration_stats.tortuosity = pathlength/path_displacement (unitless)')
    disp('exploration_stats.area_explored = total area sampled by the worm body (mm^2)')
    disp('exploration_stats.efficiency = area_explored/pathlength')
    return
end

if(length(inputTrack)>1)
    for(i=1:length(inputTrack))
        if(nargin>2)
            exploration_stats(i) = track_exploration_stats(inputTrack(i), starttime, endtime);
        else
            exploration_stats(i) = track_exploration_stats(inputTrack(i));
        end
    end
    return;
end

if(nargin>2)
    Track = extract_track_segment(inputTrack, starttime, endtime, 'time');
else
    Track = inputTrack;
end


if(isempty(Track))
    exploration_stats.pathlength  = NaN;
    exploration_stats.path_displacement  = NaN;
    exploration_stats.tortuosity  = NaN;
    exploration_stats.area_explored  = NaN;
    exploration_stats.efficiency  = NaN;
    return;
end

exploration_stats.pathlength = track_path_length(Track)*Track.PixelSize;
exploration_stats.path_displacement = sqrt((Track.SmoothX(1)-Track.SmoothX(end))^2 + (Track.SmoothY(1)-Track.SmoothY(end))^2)*Track.PixelSize;
exploration_stats.tortuosity = exploration_stats.pathlength/exploration_stats.path_displacement;

exploration_stats.area_explored = explored_area(Track);

exploration_stats.efficiency = exploration_stats.area_explored/exploration_stats.pathlength;

return;
end
