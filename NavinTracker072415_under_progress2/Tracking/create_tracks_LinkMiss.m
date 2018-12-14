function rawTracks = create_tracks_LinkMiss(procFrame, Height, Width, PixelSize, FrameRate, localname)
% rawTracks = create_tracks(procFrame, Height, Width, PixelSize, FrameRate, localname)

global Prefs;

num_worm_vector = [];
rawTracks = [];

total_wormframes = 0;
for(n = 1:length(procFrame))
    try
        num_worm_vector = [num_worm_vector length(procFrame(n).worm)];
    catch
        procFrame = compress_decompress_procFrame(procFrame);
        num_worm_vector = [num_worm_vector length(procFrame(n).worm)];
    end
    for(m=1:length(procFrame(n).worm))
        if(~isnan(procFrame(n).worm(m).coords(1)))
            procFrame(n).worm(m).tracked = 0;
            total_wormframes = total_wormframes + 1;
        else
            procFrame(n).worm(m).tracked = 1;
        end
    end
end

for(n = 1:length(procFrame))
    for(m=1:length(procFrame(n).worm))
        if(~isfield(procFrame(n).worm(m).body_contour,'kappa'))
            procFrame(n).worm(m).body_contour.kappa = [];
        end
    end
end


rt_idx=0;
for(p=1:length(procFrame))
    for(w=1:length(procFrame(p).worm))
        if(procFrame(p).worm(w).tracked == 0)
            rt_idx = rt_idx+1;
            
            % worm_array is array of procFrame and worm indicies that make
            % up a track ... generated by following the trail of
            % next_worm_idx akin to a linked-list; mark used worms w/
            % tracked=1
            pp = p;
            ww = w;
            procFrame(pp).worm(ww).tracked = 1;
            
            
            worm_array(1,:) = [pp ww];
            ww = procFrame(pp).worm(ww).next_worm_idx;
            pp = pp+1;
            if(ww>=1000) % w > 1000 for a worm joining a clump
                ww=[];
            else
                if(~isempty(ww))
                    if(procFrame(pp).worm(ww).tracked==1)
                        ww=[];
                    end
                end
            end
            ii=2;
            while(~isempty(ww))
                procFrame(pp).worm(ww).tracked = 1;
                worm_array(ii,:) = [pp ww];
                
                
                ww = procFrame(pp).worm(ww).next_worm_idx;
                pp = pp+1;
                
                if(ww>=1000) % w > 1000 for a worm joining a clump
                    ww=[];
                else
                    if(~isempty(ww))
                        if(procFrame(pp).worm(ww).tracked==1)
                            ww=[];
                        end
                    end
                end
                ii = ii+1;
            end
            
            worm_array_len = size(worm_array,1);
            startframe = procFrame(worm_array(1,1)).frame_number;
            
            rawTracks(rt_idx).Path = zeros(worm_array_len,2) + NaN;
            rawTracks(rt_idx).Frames = [startframe:(startframe+worm_array_len-1)];
            rawTracks(rt_idx).Time = rawTracks(rt_idx).Frames/FrameRate;
            rawTracks(rt_idx).Size = zeros(1,worm_array_len) + NaN;
            rawTracks(rt_idx).Eccentricity = zeros(1,worm_array_len) + NaN;
            rawTracks(rt_idx).MajorAxes = zeros(1,worm_array_len) + NaN;
            rawTracks(rt_idx).RingDistance = zeros(1,worm_array_len) + NaN;
            rawTracks(rt_idx).Image = [];
            rawTracks(rt_idx).bound_box_corner = zeros(worm_array_len,2) + NaN;
            rawTracks(rt_idx).body_contour = [];
            rawTracks(rt_idx).NumFrames = worm_array_len;
            rawTracks(rt_idx).numActiveFrames = worm_array_len;
            
            for(m=1:worm_array_len)
                pp = worm_array(m,1);
                ww = worm_array(m,2);
                
                rawTracks(rt_idx).Path(m,:) = procFrame(pp).worm(ww).coords;
                rawTracks(rt_idx).bound_box_corner(m,:) = procFrame(pp).worm(ww).bound_box_corner;
                
                rawTracks(rt_idx).Size(m) = procFrame(pp).worm(ww).size;
                rawTracks(rt_idx).Eccentricity(m) = procFrame(pp).worm(ww).ecc;
                rawTracks(rt_idx).MajorAxes(m) = procFrame(pp).worm(ww).majoraxis;
                rawTracks(rt_idx).RingDistance(m) = procFrame(pp).worm(ww).ringDist;
                
                rawTracks(rt_idx).Image{m} = procFrame(pp).worm(ww).image;
                rawTracks(rt_idx).body_contour = [rawTracks(rt_idx).body_contour procFrame(pp).worm(ww).body_contour];
                
                if(isfield(procFrame(pp),'timestamp'))
                    if(~isempty(procFrame(pp).timestamp))
                        if(procFrame(pp).timestamp>0)
                            rawTracks(rt_idx).Time(m) = procFrame(pp).timestamp;
                        end
                    end
                end
                
            end
            pp = worm_array(worm_array_len,1);
            ww = worm_array(worm_array_len,2);
            
            clear('worm_array');
        end
    end
    if(p==1 || mod(p,50)==0)
        disp([sprintf('Frame %d created %d tracks %d frames avg tracklength\t%s',procFrame(p).frame_number,rt_idx,average_tracklength(rawTracks),timeString)])
    end
end

% add additional info to the rawTracks
for i = 1:length(rawTracks)
    rawTracks(i).NumFrames = length(rawTracks(i).Frames);
    rawTracks(i).numActiveFrames = rawTracks(i).NumFrames;
    
    rawTracks(i).Height = Height;
    rawTracks(i).Width = Width;
    rawTracks(i).PixelSize = PixelSize;
    rawTracks(i).FrameRate = FrameRate;
    rawTracks(i).Name = localname;
    
end

rawTracks = sort_tracks_by_starttime(rawTracks);
disp(sprintf('%d raw tracks\taverage length %d frames %d total wormframes\t%s',length(rawTracks), average_tracklength(rawTracks), total_wormframes, timeString))

DeleteTracks = [];
for i = 1:length(rawTracks)
    if(nanmean(rawTracks(i).MajorAxes)*rawTracks(i).PixelSize < Prefs.MinWormLength_mm) % delete short animals ... probably schmutz
        DeleteTracks = [DeleteTracks, i];
    end
end
rawTracks(DeleteTracks) = [];

% % interpolate to fill in gaps between track fragments likely belonging to the same worm
rawTracks = condense_rawTracks(rawTracks);

% get rid of very short tracks or weird dots caught as worms
DeleteTracks = [];
for i = 1:length(rawTracks)
    if(length(rawTracks(i).Frames) < Prefs.MinTrackLengthFrames || ...
            nanmean(rawTracks(i).MajorAxes)*rawTracks(i).PixelSize < Prefs.MinWormLength_mm) % delete short tracks short animals
        DeleteTracks = [DeleteTracks, i];
    end
end
rawTracks(DeleteTracks) = [];

disp(sprintf('Final %d raw tracks\taverage tracklength %d frames\t%s',length(rawTracks), average_tracklength(rawTracks), timeString))

% interpolate ring distances for frames for which it wasn't measured
rawTracks = ring_distance_interpolate(rawTracks);

rawTracks = sort_tracks_by_starttime(rawTracks);

for(i=1:length(rawTracks))
    rawTracks(i).original_track_indicies = i;
end

% make array elements into single-precision ... saves space over doubles
rawTracks = make_single(rawTracks);


num_worms = round(nanmean(num_worm_vector));


return;
end


function rawTracks = condense_rawTracks(rawTracks)
% rawTracks = condense_rawTracks(rawTracks)
% conservatively interpolate to fill in gaps between track fragments likely belonging to the same worm

global Prefs;

OPrefs = Prefs;

disp(sprintf('Condensing %d raw tracks\taverage length %d frames\t%s',...
    length(rawTracks), average_tracklength(rawTracks), timeString))


Prefs.MaxTrackLinkFrames = Prefs.FrameRate+1;
Prefs.aggressive_linking = 0;

SmoothWinSize = Prefs.SmoothWinSize*Prefs.FrameRate;
StepSize = Prefs.StepSize*Prefs.FrameRate;

if(SmoothWinSize<3)
    SmoothWinSize=3;
end
if(StepSize<3)
    StepSize=3;
end

for(i=1:length(rawTracks))
    
    if(rawTracks(i).NumFrames > SmoothWinSize) %used to be >=
        % Smooth Track data by sliding window of size SmoothWinSize;
        rawTracks(i).SmoothX = RecSlidingWindow(rawTracks(i).Path(:,1)', SmoothWinSize);
        rawTracks(i).SmoothY = RecSlidingWindow(rawTracks(i).Path(:,2)', SmoothWinSize);
        Xdif = CalcDif(rawTracks(i).SmoothX, StepSize) * Prefs.FrameRate;
        Ydif = -CalcDif(rawTracks(i).SmoothY, StepSize) * Prefs.FrameRate;    % Negative sign allows "correct" direction
    else
        rawTracks(i).SmoothX = rawTracks(i).Path(:,1)';
        rawTracks(i).SmoothY = rawTracks(i).Path(:,2)';
        if(length(rawTracks(i).SmoothX)>1)
            Xdif = CalcDif(rawTracks(i).SmoothX, length(rawTracks(i).SmoothX)) * Prefs.FrameRate;
            Ydif = -CalcDif(rawTracks(i).SmoothY, length(rawTracks(i).SmoothX)) * Prefs.FrameRate;    % Negative sign allows "correct" direction
        else
            Xdif = 0;
            Ydif = 0;
        end
    end
    
    % Calculate Direction & Speed
    
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation
    
    rawTracks(i).Direction = atan(Xdif./Ydif)*360/(2*pi);	    % In degrees, 0 = Up ("North")
    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(rawTracks(i).Direction(NegYdifIndexes) <= 0);
    Index2 = find(rawTracks(i).Direction(NegYdifIndexes) > 0);
    rawTracks(i).Direction(NegYdifIndexes(Index1)) = rawTracks(i).Direction(NegYdifIndexes(Index1)) + 180;
    rawTracks(i).Direction(NegYdifIndexes(Index2)) = rawTracks(i).Direction(NegYdifIndexes(Index2)) - 180;
    
    rawTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*rawTracks(i).PixelSize;
    
    rawTracks(i).original_track_indicies = i;
    
end

%rawTracks = link_tracks(rawTracks,1,1,1,'missing');

% linkage w/o regard for direction
rawTracks = link_tracks(rawTracks, 1, 0, 1, 'missing');

for(i=1:length(rawTracks))
    rt(i) = rmfield(rawTracks(i),'Path');
end
clear('rawTracks');
rawTracks = rt;
clear('rt');

rawTracks = sort_tracks_by_starttime(rawTracks);

Prefs = OPrefs;

disp(sprintf('%d raw tracks\taverage length %d frames\t%s',length(rawTracks), average_tracklength(rawTracks), timeString))

return;
end

