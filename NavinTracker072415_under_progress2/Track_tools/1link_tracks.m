function linkedTracks = link_tracks(inputTracks, verbose, dir_flag, dist_flag, join_flag)

global Prefs;
persistent num_track_frags;
persistent num_recursion_rounds;
persistent local_MaxInterFrameDistance;

if(nargin<2)
    verbose=1;
end

big_number = inputTracks(1).Width*inputTracks(1).Height; % 4194304

linkedTracks=[];

inputTracks = sort_tracks_by_starttime(inputTracks);

FrameRate = inputTracks(1).FrameRate;

numRealTracks = length(inputTracks);
numMergedTracks = numRealTracks;

if(nargin<3)
    dir_flag=0;
    if(isfield(inputTracks(1),'Direction'))
        dir_flag=1;
    end
    if(Prefs.swim_flag == 1)
        dir_flag=0;
    end
end

if(nargin<4)
    dist_flag=1;
end

if(nargin<5)
    join_flag = 'interpolate'; % 'missing'; % 'interpolate';
end

smooth_path_flag=0;
if(isfield(inputTracks(1),'SmoothX'))
    smooth_path_flag=1;
end

if(isempty(local_MaxInterFrameDistance))
    local_MaxInterFrameDistance = min(Prefs.MaxCentroidShift_mm_per_sec, max_struct_array(inputTracks,'Speed'));
    local_MaxInterFrameDistance = (local_MaxInterFrameDistance(1)/inputTracks(1).FrameRate)/inputTracks(1).PixelSize;
end

% for large track arrays, split into pieces and recursively call link_tracks
if(numRealTracks>Prefs.MaxLinkTracks)
    if(verbose)
        disp([sprintf('%d track fragments > %d ... splitting\t%s',numRealTracks, Prefs.MaxLinkTracks, timeString())])
    end
    
    if(isempty(num_recursion_rounds))
        num_recursion_rounds = 0;
    end
    
    
    track_fieldnames = fieldnames(inputTracks(1));
    
    numSplits = ceil(numRealTracks/Prefs.MaxLinkTracks);
    
    for(i=1:(numSplits-1))
        sTrack{i} = struct2cell(inputTracks(ceil((i-1)*numRealTracks/numSplits)+1:ceil(i*numRealTracks/numSplits)));
    end
    i=numSplits;
    sTrack{i} = struct2cell(inputTracks(ceil((i-1)*numRealTracks/numSplits)+1:end));
    
    for(i=1:numSplits)
        slinkedTracks{i} = link_tracks(cell2struct(sTrack{i},track_fieldnames), verbose, dir_flag, dist_flag, join_flag);
    end
    
    Tracks = [];
    for(i=1:numSplits)
        Tracks = [Tracks slinkedTracks{i}];
    end
    
    num_recursion_rounds = num_recursion_rounds+1;
    if(verbose)
        disp([sprintf('linking recursion round %d resulted in %d linked tracks\taverage tracklength %d frames\t%s',num_recursion_rounds, length(Tracks),average_tracklength(Tracks),timeString())]);
    end
    
    if(~isempty(num_track_frags))
        if(length(Tracks) == num_track_frags)
            
            linkedTracks = Tracks;
            
            if(verbose)
                disp([sprintf('recursion linked and created %d linked tracks\taverage tracklength %d frames\t%s',length(linkedTracks),average_tracklength(linkedTracks),timeString())]);
            end
            
            clear('num_recursion_rounds');
            clear('num_track_frags');
            clear('slinkedTracks');
            clear('sTracks');
            clear('Tracks');
            clear('local_MaxInterFrameDistance');
            return;
        end
    end
    
    num_track_frags = length(Tracks);
    linkedTracks = link_tracks(Tracks, verbose, dir_flag, dist_flag, join_flag);
    
    clear('num_recursion_rounds');
    clear('num_track_frags');
    clear('slinkedTracks');
    clear('sTracks');
    clear('Tracks');
    clear('local_MaxInterFrameDistance');
    return;
end


Tracks = inputTracks;

maxFrame = max_struct_array(Tracks,'Frames');
minFrame = min_struct_array(Tracks,'Frames');

if(verbose)
    disp([sprintf('linking %d track fragments\t%s',numRealTracks, timeString())])
end

% this matrix stores the squared distances between the end of track i and the start of j > i
distance_matrix = zeros(numRealTracks,numRealTracks) + 1e10;

% this matrix stores the difference in frames between the end of track i and the start of j > i
d_frame_matrix = distance_matrix;
time_space_matrix = distance_matrix;

local_MaxTrackLinkDistance = Prefs.MaxTrackLinkFrames*local_MaxInterFrameDistance;

ctr = 0;
for(i=1:(numRealTracks-1))
    if(Tracks(i).Frames(1) > minFrame || Tracks(i).Frames(end) < maxFrame)
        for( j=i+1: numRealTracks)
            if(Tracks(j).Frames(1) > minFrame || Tracks(j).Frames(end) < maxFrame)
                if(Tracks(i).Frames(end) < Tracks(j).Frames(1))
                    [distance_matrix(i,j), d_frame_matrix(i,j)] = calc_link_matricies_elements(Tracks(i), Tracks(j));
                    if(distance_matrix(i,j)<1e9)
                        ctr=ctr+1;
                    end
                end
            end
        end
    end
end

mindist = 0;

% p=1;
while(mindist<=local_MaxTrackLinkDistance)
    
    % given two tracks within range, pick the one closer in time
    % avoids large gaps
    time_space_matrix = distance_matrix + 2*big_number*d_frame_matrix;
    
    
    [mindist,i,j] = minn(time_space_matrix);
    
    %     % find the shortest distance between the end of a track and the start of a later one
    %     [mindist,i,j] = minn(distance_matrix);
    
    i=i(1); % in case there are multiple w/ the same minimum
    j=j(1);
    
    mindist = distance_matrix(i,j);
   
    % [local_MaxTrackLinkDistance i j mindist d_frame_matrix(i,j)]
    
    if(mindist<=local_MaxTrackLinkDistance)
        % append track j to track i
        
        Tracks(i) = append_track(Tracks(i), Tracks(j), join_flag);
        
        % effectively delete track j by giving it a high time, and decrementing numMergedTracks
        Tracks(j).Frames(1:end) = 1e10;
        numMergedTracks = numMergedTracks - 1;
        
        % update the distance matrix ... set all elements for track i&j to 1e10, while
        % calculating distances between the end of new track i and everyone else k
        distance_matrix(j,:)=1e10; distance_matrix(:,j)=1e10;
        distance_matrix(i,:)=1e10; distance_matrix(:,i)=1e10;
        
        d_frame_matrix(j,:)=1e10; d_frame_matrix(:,j)=1e10;
        d_frame_matrix(i,:)=1e10; d_frame_matrix(:,i)=1e10;
        
        for( k=1: i-1)
            if(Tracks(k).Frames(1) < 1e9)
                if(Tracks(k).Frames(end) < Tracks(i).Frames(1))
                    [distance_matrix(k,i), d_frame_matrix(k,i)] = calc_link_matricies_elements(Tracks(k), Tracks(i));
                end
            end
        end
        
        for( k=i+1: numRealTracks)
            if(Tracks(k).Frames(1) < 1e9)
                if(Tracks(i).Frames(end) < Tracks(k).Frames(1))
                    [distance_matrix(i,k), d_frame_matrix(i,k)] = calc_link_matricies_elements(Tracks(i), Tracks(k));
                end
            end
        end
    end
end

Tracks = sort_tracks_by_startframe(Tracks);
linkedTracks = Tracks(1:numMergedTracks);

for(i=1:numMergedTracks)
    linkedTracks(i).numActiveFrames = num_active_frames(linkedTracks(i));
    linkedTracks(i) = ring_effects(linkedTracks(i));
end

linkedTracks = make_single(linkedTracks);

if(verbose)
    disp([sprintf('linked and created %d linked tracks\taverage tracklength %d frames\t%s',numMergedTracks,average_tracklength(linkedTracks),timeString())])
end

clear('distance_matrix');
clear('d_frame_matrix');
clear('time_space_matrix');
clear('Tracks');

if(isempty(num_recursion_rounds))
    clear('local_MaxInterFrameDistance');
end


    function [distance_m, d_frame_m] = calc_link_matricies_elements(Track_i, Track_j)
        
        distance_m = 1e10;
        d_frame_m = 1e10;
        
        d_frame = Track_j.Frames(1) - Track_i.Frames(end);
        
        if(dist_flag==0) % distance doesn't matter, just the time gap between tracks
            distance_m = 0;
            d_frame_m = d_frame;
            return;
        end
        
        if(d_frame <= Prefs.MaxTrackLinkFrames)  % track j starts within MaxTrackLinkFrames of the end of track i
            maxdist = d_frame*local_MaxInterFrameDistance; % Prefs.MaxInterFrameDistance;
            dist = distance_between_worm_images_for_tracking(maxdist, 1e10, ...
                Track_i.Image{end}, Track_i.bound_box_corner(end,:), ...
                Track_j.Image{1}, Track_j.bound_box_corner(1,:));
            if(dist <= 1e-4) % bodies overlap
                % negative give preference if worm body images overlap
                % the baseline big_number is if two or more potential
                % overlaps happen ... then give preference to
                % closest (centroid-centroid) one that also has the proper
                % geometry
                if(smooth_path_flag==1)
                    dist =  ( Track_i.LastCoordinates(1,1) -  Track_j.SmoothX(1) )^2 + ...
                        ( Track_i.LastCoordinates(1,2) -  Track_j.SmoothY(1) )^2 ;
                else
                    dist =  ( Track_i.LastCoordinates(1,1) -  Track_j.Path(1,1) )^2 + ...
                        ( Track_i.LastCoordinates(1,2) -  Track_j.Path(1,2) )^2 ;
                end
                if(keep_or_reject_track_link(Track_i, Track_j, dist, d_frame))
                    distance_m = -big_number + sqrt(dist);
                    d_frame_m = d_frame;
                else
                    distance_m = sqrt(dist);
                    d_frame_m = d_frame;
                end
            else
                if(dist <= maxdist)
                    if(keep_or_reject_track_link(Track_i, Track_j, dist, d_frame))
                        distance_m = dist;
                        d_frame_m = d_frame;
                    end
                end
            end
        end
        
        return;
    end

    function keep_flag = keep_or_reject_track_link(Track1, Track2, d, delta_frame)
        
        
%         % do the tracks have very different sizes? 
%         tr1_upper = Track1.MeanSize + Track1.stdSize;
%         tr1_lower = Track1.MeanSize - Track1.stdSize;
%         tr2_upper = Track2.MeanSize + Track2.stdSize;
%         tr2_lower = Track2.MeanSize - Track2.stdSize;
%         cont_flag=0;
%         if(tr2_upper <= tr1_upper && tr2_upper >= tr1_lower)
%             cont_flag = 1;
%         else
%             if(tr2_lower <= tr1_upper && tr2_lower >= tr1_lower)
%                 cont_flag = 1;
%             else
%                 if(tr1_upper <= tr2_upper && tr1_upper >= tr2_lower)
%                     cont_flag = 1;
%                 else
%                     if(tr1_lower <= tr2_upper && tr1_lower >= tr2_lower)
%                         cont_flag = 1;
%                     end
%                 end
%             end
%         end
%         if(cont_flag==0)
%             keep_flag=0;
%             return;
%         end
        
            
        % no direction given or not required
        if(dir_flag==0)
            keep_flag=1;
            return;
        end
        
        
        start_track1 = max(1,(length(Track1.SmoothX)-FrameRate));
        end_track1 = length(Track1.SmoothX);
        start_track2 = 1;
        end_track2 = min(length(Track2.SmoothX),(FrameRate+1));
        
        track1_idx = start_track1:end_track1;
        track2_idx = start_track2:end_track2;
        
        local_dist_thresh = max([Track1.Speed(track1_idx) Track2.Speed(track2_idx)])*delta_frame/FrameRate;
        
        
        
        % paused track1 ... move back one frame at a time
        nonpause_idx = find(Track1.Speed(track1_idx) > Prefs.pauseSpeedThresh);
        while(length(nonpause_idx)<=FrameRate)
            track1_idx = track1_idx-1;
            if(track1_idx(1)<1)
                if(d*Track1.PixelSize > local_dist_thresh)
                    keep_flag = 0;
                    return;
                end
                keep_flag = 1;
                return;
            else
                local_dist_thresh = max([Track1.Speed(track1_idx) Track2.Speed(track2_idx)])*delta_frame/FrameRate;
            end
            nonpause_idx = find(Track1.Speed(track1_idx) > Prefs.pauseSpeedThresh);
        end
        
        
        
        % paused track2 ... move ahead one frame at a time
        nonpause_idx = find(Track2.Speed(track2_idx) > Prefs.pauseSpeedThresh);
        while(length(nonpause_idx)<=FrameRate)
            track2_idx = track2_idx+1;
            if(track2_idx(end)>length(Track2.SmoothX))
                if(d*Track1.PixelSize > local_dist_thresh)
                    keep_flag = 0;
                    return;
                end
                keep_flag = 1;
                return;
            else
                local_dist_thresh = max([Track1.Speed(track1_idx) Track2.Speed(track2_idx)])*delta_frame/FrameRate;
            end
            nonpause_idx = find(Track2.Speed(track2_idx) > Prefs.pauseSpeedThresh);
        end
        
        
        % use the observed speed to estimate
        % distance travelled during delta_frame missing frames
        %       if(d*Track1.PixelSize > max([ (Track1.Speed(track1_idx)) (Track2.Speed(track2_idx)) ])*delta_frame/FrameRate)
        if(d*Track1.PixelSize > local_dist_thresh)
            keep_flag = 0;
            return;
        end
        
        
        
        % very short track
        if(length(Track1.SmoothX)<FrameRate || length(Track2.SmoothX)<FrameRate)
            if(delta_frame <= FrameRate)
                keep_flag = 1;
            else
                keep_flag = 0;
            end
            return;
        end
        
        
        
        %         % direction not well defined
        %         if(sum(isnan(Track1.Direction(track1_idx)))>0)
        %             keep_flag = 1;
        %             return;
        %         end
        %
        %         % direction not well defined
        %         if(sum(isnan(Track2.Direction(track2_idx)))>0)
        %             keep_flag = 1;
        %             return;
        %         end
        
        %         % paused animals
        %         if(nanmean(Track1.Speed(track1_idx)) <= Prefs.pauseSpeedThresh)
        %             keep_flag = 1;
        %             return;
        %         end
        %
        %         % paused animals
        %         if(nanmean(Track2.Speed(track2_idx)) <= Prefs.pauseSpeedThresh)
        %             keep_flag = 1;
        %             return;
        %         end
        
        % link turns if they are close enough in time
        if(Track1.Eccentricity(end) <= Prefs.UpsilonEccThresh)
            if(Track2.Eccentricity(1) <= Prefs.UpsilonEccThresh)
                if(delta_frame <= Prefs.MaxUpsilonOmegaDuration*Prefs.FrameRate)
                    keep_flag = 1;
                    return;
                end
            end
        end
        
        % worms that are in a turn of some sort may be linked to a forward
        % track if they are close enough
        
        
        
        % Track1 end in turn, Track2 is forward
        if( ((Track1.Eccentricity(end)) <= Prefs.UpsilonEccThresh) && ((Track2.Eccentricity(1)) > Prefs.UpsilonEccThresh) )
            keep_flag = 1;
            return;
        end
        
        % Track2 starts with turn, Track1 ends with forward
        if( ((Track2.Eccentricity(1)) <= Prefs.UpsilonEccThresh) && ((Track1.Eccentricity(end)) > Prefs.UpsilonEccThresh) )
            keep_flag = 1;
            return;
        end
        
        
        % for worms moving forward, link only if post-link is in the same direction
       
        % Track2 moving orthogonal or anti-parallel to Track1 so reject linkage
                if(abs( GetAngleDif( mean_direction(Track1.Direction(track1_idx)), mean_direction(Track2.Direction(track2_idx)) ) ) > 90) % 90
                    keep_flag = 0;
                    return;
                end
        
        % is Track2 actually moving ahead in the same direction as Track1?
        % if so, Track2 after the 1st frame should be further away from the
        % end of Track1
        if(((Track1.SmoothX(end) - Track2.SmoothX(1))^2 + (Track1.SmoothY(end) - Track2.SmoothY(1))^2) > ...
                ((Track1.SmoothX(end) - Track2.SmoothX(track2_idx(end)))^2 + (Track1.SmoothY(end) - Track2.SmoothY(track2_idx(end)))^2))
            keep_flag = 0;
            return;
        end
        
        % fit end of Track1 to a line
        [m,b] = fit_line(Track1.SmoothX(track1_idx), Track1.SmoothY(track1_idx));
        
        % find point Q on Track1 line d away from last point of the track
        [Qx,Qy, dir] = point_on_line_d_away_from_P(m,b,Track1.SmoothX(end),Track1.SmoothY(end),mean_direction(Track1.Direction(track1_idx)),d);
        
        % is the start of the next track within Prefs.TrigMaxTrackLinkDirectionDiff = d*sqrt(2*(1-cos(MaxTrackLinkDirectionDiff)))) Q?
        % If yes, the track is probably not behind the end of Track1
        % see keep_or_reject_link.pdf
        if(sqrt( (Qx - Track2.SmoothX(1) )^2 + (Qy - Track2.SmoothY(1) )^2 ) > d*Prefs.TrigMaxTrackLinkDirectionDiff)
            keep_flag = 0;
            return;
        end
        
        keep_flag = 1;
        
        return;
        
    end


return;
end


