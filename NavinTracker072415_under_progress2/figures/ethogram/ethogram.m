function [plot_handle, ymax, ymin] = ethogram(Tracks, plot_rows, plot_columns, plot_location, xlabelstring, ylabelstring, speed_flag, all_tracks_flag, cluster_flag, cluster_starttime, cluster_endtime)
% [plot_handle, ymax, ymin] = ethogram(Tracks, plot_rows, plot_columns, plot_location, xlabelstring, ylabelstring, speed_flag, all_tracks_flag, cluster_flag, cluster_starttime, cluster_endtime)

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin < 1)
    disp('[plot_handle, ymax, ymin] = ethogram(Tracks, plot_rows, plot_columns, plot_location, xlabelstring, ylabelstring, speed_flag, all_tracks_flag, cluster_flag, cluster_starttime, cluster_endtime)');
    return;
end

simple_flag = 0; 
if(nargin<3)
    plot_rows=1;
    plot_columns=1;
end
if(nargin<4)
    plot_location=1;
end
if(nargin<5)
    xlabelstring='';
end
if(nargin<6)
    ylabelstring='';
end
if(nargin<7)
    speed_flag = 1;
    simple_flag = 0;
end
if(ischar(speed_flag))
    if(~isempty(strfind(lower(speed_flag),'no')) || ~isempty(strfind(lower(speed_flag),'simple')) )
        speed_flag = 0;
        simple_flag = 1;
    end
end
if(nargin < 8)
    all_tracks_flag = 0;
end

if(nargin<9)
    cluster_flag=0;
end

Tracks = sort_tracks_by_length(Tracks);


% pause_state = find_Track_to_matrix(Tracks,'State','==num_state_convert(''pause'')' );
% pause_state = matrix_replace(pause_state,'==',1,2); % light gray
% fwd_state = find_Track_to_matrix(Tracks,'State','==num_state_convert(''fwd'')' );
% fwd_state = matrix_replace(fwd_state,'==',1,10); % gray
% big_matrix = pause_state + fwd_state;

% edit out highly paused tracks for the ethogram ... might be dead worm
pause_code = num_state_convert('pause');
lRev_code = num_state_convert('lRev');
sRev_code = num_state_convert('sRev');
fwd_code = num_state_convert('fwd');
for(i=1:length(Tracks))
    Tracks(i).numActiveFrames = num_active_frames(Tracks(i));
end
del_idx=[];
for(i=1:length(Tracks))
    
    % superlong reversal probably mis-identified
    idx = find(floor(Tracks(i).State) == lRev_code);
    if(~isempty(idx))
        [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
        if(best_len > 25*Tracks(i).FrameRate)
            Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
        end
    end
    idx = find(floor(Tracks(i).State) == sRev_code);
    if(~isempty(idx))
        [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
        if(best_len > 25*Tracks(i).FrameRate)
            Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
        end
    end
end
if(length(Tracks)>1)
    if(length(del_idx) < length(Tracks))
        Tracks(del_idx) = [];
    end
end
clear('del_idx');

% plot just the long tracks
minNumFrames = Prefs.minFracLongTrack*max_struct_array(Tracks,'NumFrames');
if(isempty(minNumFrames))
    minNumFrames=0;
end
NumLongTracks = 0;
for(i=1:length(Tracks))
    if(length(Tracks(i).Frames) >=  minNumFrames)
        NumLongTracks = NumLongTracks+1;
    end
    
    % round the State to the lowest integer (this info is not saved)
    % used coloring  rev and omega  the same regardless of whether they are
    % stand-alone or in a revOmega, etc
    Tracks(i).State = floor(Tracks(i).State);
    Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
end


if(cluster_flag==1 || strcmpi(cluster_flag,'cluster')==1)
    if(nargin<11)
        cluster_starttime = min_struct_array(Tracks,'Time');
        cluster_endtime = max_struct_array(Tracks,'Time');
    end
    Tracks = cluster_tracks_by_behavior(Tracks, cluster_starttime, cluster_endtime);
end


speed_matrix = track_field_to_matrix(Tracks,'Speed',0);
speed_matrix = colormap_scaling_function(speed_matrix,  33, 2, 0.2, 0.1);
fwd_state = find_Track_to_matrix(Tracks,'State','<=num_state_convert(''fwd_state'')' );
if(speed_flag==1)
    big_matrix = speed_matrix.*fwd_state;
else
    big_matrix = matrix_replace(fwd_state,'==',1,10);
end



omega_state = find_Track_to_matrix(Tracks,'State','==num_state_convert(''omega'')');
omega_state = matrix_replace(omega_state,'==',1,34); % red

upsilon_state = find_Track_to_matrix(Tracks,'State','==num_state_convert(''upsilon'')');
upsilon_state = matrix_replace(upsilon_state,'==',1,35); % magenta

lrev_state =  find_Track_to_matrix(Tracks,'State','==num_state_convert(''lRev'')'); 
lrev_state = matrix_replace(lrev_state,'==',1,36); % blue

srev_state =  find_Track_to_matrix(Tracks,'State','==num_state_convert(''sRev'')'); 
srev_state = matrix_replace(srev_state,'==',1,37); % cyan

big_matrix =  big_matrix + lrev_state + srev_state +  omega_state  + upsilon_state;

big_matrix = round(big_matrix);
big_matrix = matrix_replace(big_matrix,'==',0,1);

xmin = floor(min_struct_array(Tracks,'Time'));
xmax = ceil(max_struct_array(Tracks,'Time'));
ymin = 0;
ymax = NumLongTracks;



if(NumLongTracks > Prefs.MaxNumEthogramTracks)
    ymax = Prefs.MaxNumEthogramTracks;
end
if(all_tracks_flag==1)
    ymax = length(Tracks);
end

if(ymax <= 20)
    ymax=length(Tracks);
end

plot_handle = 1;
if(plot_rows >1 || plot_columns>1)
    pl = plot_location(plot_location>0);
    plot_handle = subplot(plot_rows,plot_columns,pl);
end

if(ymax<1)
    ymin=0;
    ymax=1;
    return
end

% big_matrix = big_matrix(ymin:ymax,:);
% convert to truecolor to avoid clashes with other subplots

if(simple_flag==0)
    colmap = ethogram_colormap; 
else
    colmap = ethogram_simple_colormap;
end

cm=[];
for(i=1:length(big_matrix((ymin+1):ymax,1)))
    for(j=1:length(big_matrix(1,:)))
        cm(i,j,:) = colmap(big_matrix(i,j),:); 
    end
end
if(~isempty(cm))
    image(xmin:xmax, (ymin+1):ymax, cm);
end

axis xy
axis([xmin xmax ymin ymax]);
box('off');
axis tight

fontsize = (plot_rows*plot_columns)*(-2/5) + 16;
if(~isempty(ylabelstring))
    hy = ylabel(ylabelstring);
    set(hy,'FontSize',fontsize);
end
if(~isempty(xlabelstring))
    hx = xlabel(xlabelstring);
    set(hx,'FontSize',fontsize);
end
set(gca,'FontSize',fontsize);

clear('cm');
clear('colmap');
clear('speed_matrix');
clear('fwd_state');
clear('omega_state');
clear('upsilon_state');
clear('lrev_state');
clear('srev_state');
clear('big_matrix');

return;
end
