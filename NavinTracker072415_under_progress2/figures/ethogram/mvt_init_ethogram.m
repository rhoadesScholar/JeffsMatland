function [hh, ymax, ymin] = mvt_init_ethogram(Tracks, stimulus, plot_rows, plot_columns, plot_location, mvt, color, xaxis_vector)
% [hh, ymax, ymin] = mvt_init_ethogram(Tracks, stimulus, plot_rows, plot_columns, plot_location, mvt, color, xaxis_vector)
% [hh, ymax, ymin] = mvt_init_ethogram(Tracks, stimulus, 'initialize') or mvt_init_ethogram(Tracks, stimulus, 'clear')

hh=[];
ymax=[];
ymin=[];

if(isempty(Tracks))
    return;
end

global Prefs;

missing_frame_color = Prefs.missing_frame_ethogram_color;

persistent base_cm;

if(nargin==3)
    if(strcmpi(plot_rows,'initialize'))
        base_cm=[];
        % set some dummys
        plot_rows = 1;
        plot_columns = 1;
        plot_location = 1;
        mvt = 'rev';
    else % clear
        base_cm=[];
        return
    end
end

if(nargin < 7)
    color = 'k';
end

if(ischar(color))
    color = str2rgb(color);
end



% edit out highly paused tracks for the ethogram ... might be dead worm
pause_code = num_state_convert('pause');
lRev_code = num_state_convert('lRev');
sRev_code = num_state_convert('sRev');
fwd_code = num_state_convert('fwd');
for(i=1:length(Tracks))
    Tracks(i).numActiveFrames = num_active_frames(Tracks(i));
end
del_idx=[];
% for(i=1:length(Tracks))
%     if(length(find(abs(Tracks(i).State - pause_code)<1e-4)) >  0.25*Tracks(i).numActiveFrames)
%         del_idx = [del_idx i];
%     end
%     
%     % superlong reversal probably mis-identified
%     idx = find(floor(Tracks(i).State) == lRev_code);
%     if(~isempty(idx))
%         [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
%         if(best_len > 25*Tracks(i).FrameRate)
%             Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
%         end
%     end
%     idx = find(floor(Tracks(i).State) == sRev_code);
%     if(~isempty(idx))
%         [i_best, j_best, best_len] = find_longest_contigious_stretch_in_array(idx);
%         if(best_len > 25*Tracks(i).FrameRate)
%             Tracks(i).State(idx(i_best):idx(j_best)) = fwd_code;
%         end
%     end
% end
% if(length(Tracks)>1)
%     if(length(del_idx) < length(Tracks))
%         Tracks(del_idx) = [];
%     end
% end
clear('del_idx');





lowest_time = min_struct_array(Tracks,'Time');
if(nargin<8)
    xmin = min(0,floor(lowest_time));
    xmax = ceil(max_struct_array(Tracks,'Time'));
else
    xmin = xaxis_vector(1);
    xmax = xaxis_vector(2);
end
time_axis = xmin:(1/Tracks(1).FrameRate):xmax;

mvt = lower(mvt);

ringmiss_code = num_state_convert('ringmiss');


Tracks = sort_tracks_by_length(Tracks);


if(length(Tracks)*length(time_axis) > 300*4200*3)
	Tracks = Tracks(1:round(300*4200*3/length(time_axis)));
end


minNumFrames = Prefs.minFracLongTrack*max_struct_array(Tracks,'Frames');
if(isempty(minNumFrames))
    minNumFrames=0;
end

NumLongTracks = 0;
for(i=1:length(Tracks))
    if(Tracks(i).numActiveFrames >=  minNumFrames)
        NumLongTracks = NumLongTracks+1;
    end
end
if(NumLongTracks < 20)
    
    %    NumLongTracks = min(20, length(Tracks));
    
    Tracks = sort_tracks_by_length(Tracks,1);
    NumLongTracks=0;
    for(i=1:length(Tracks))
        if(length(Tracks(i).Frames) >=  minNumFrames)
            NumLongTracks = NumLongTracks+1;
        end
    end
end

Tracks = sort_tracks_by_length(Tracks);

state_matrix = track_field_to_matrix(Tracks, 'State');
big_matrix = [];

% the actual initiations
if(strcmpi(mvt,'reori')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','>num_state_convert(''fwdstate'')','&','<num_state_convert(''ringmiss'')');
end


if(strcmpi(mvt,'nonupsilon_reori')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','>num_state_convert(''fwdstate'')','&','<num_state_convert(''ringmiss'')');
    
    find_criteria_string = sprintf('==num_state_convert(''%s'')', 'pure_upsilon');
    bm2 =  find_Track_to_matrix(Tracks,'mvt_init',find_criteria_string);
    big_matrix(bm2==1) = 0;
    clear('bm2');
end


if(strcmpi(mvt,'revomega')==1)
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrevomega'')','|','==num_state_convert(''srevomega'')');
end

if(strcmpi(mvt,'revupsilon')==1)
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrevupsilon'')','|','==num_state_convert(''srevupsilon'')');
end

if(strcmpi(mvt,'revomegaupsilon')==1)
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrevomega'')','|','==num_state_convert(''srevomega'')');
    bm = find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrevupsilon'')','|','==num_state_convert(''srevupsilon'')');
    big_matrix = big_matrix + bm;
    clear('bm');
end

if(strcmpi(mvt,'rev')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrev'')','|','==num_state_convert(''srev'')');
end



if(strcmpi(mvt,'rev+omega')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lrev'')','|','==num_state_convert(''srev'')');
    big_matrix = big_matrix + find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''omega'')');
end


if(strcmpi(mvt,'omegaUpsilon')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''omega'')','|','==num_state_convert(''upsilon'')');
end

if(strcmpi(mvt,'lrev')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''lRev'')');
end


if(strcmpi(mvt,'srev')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''sRev'')');
end

if(strcmpi(mvt,'omega')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''omega'')');
end

if(strcmpi(mvt,'upsilon')==1)
    for(i=1:length(Tracks))
        Tracks(i).mvt_init = floor(Tracks(i).mvt_init);
    end
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''upsilon'')');
end

if(strcmpi(mvt,'pure_rev')==1)
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''pure_lrev'')','|','==num_state_convert(''pure_srev'')');
end

if(strcmpi(mvt,'pure_omegaUpsilon')==1)
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init','==num_state_convert(''pure_omega'')','|','==num_state_convert(''pure_upsilon'')');
end




if(isempty(big_matrix))
    find_criteria_string = sprintf('==num_state_convert(''%s'')', mvt);
    big_matrix =  find_Track_to_matrix(Tracks,'mvt_init',find_criteria_string);
end

ymin = 0;

% ymax = length(Tracks);
ymax = NumLongTracks;

if(ymax <= 20)
    ymax = length(Tracks);
end

hh = 1;
if(plot_rows >1 || plot_columns>1)
    hh = subplot(plot_rows,plot_columns,plot_location);
end

if(ymax<1)
    return
end

%
%
% ymin = 0;
%
% disp([mvt, ' ', num2str(xmin), ' ', num2str(xmax), ' ', num2str(size(big_matrix)), ' ' num2str(length(time_axis))])
%
% stimulusShade(stimulus, ymin, ymax);
% hold on;
%
% missing frames
% for(i=1:length(state_matrix((ymin+1):ymax,1)))
%     yrange = [i-1 i];
%
%     indicies = find(state_matrix(i,:)>=ringmiss_code | isnan(state_matrix(i,:)));
%     indicies(find(indicies > length(time_axis)))=[];
%
%     xdata = time_axis(indicies);
%     rasterx(xdata,yrange, [0.9 0.9 0.9]);
% end
% hold on;
%
% for(i=1:length(big_matrix((ymin+1):ymax,1)))
%     yrange = [i-1 i];
%
%     indicies = find(big_matrix(i,:)==1);
%     indicies(find(indicies > length(time_axis)))=[];
%
%     xdata = time_axis(indicies);
%     rasterx(xdata,yrange, color);
% end
%
% hold off;
%


% image dimensions are positive non-zero ... however times are not
% therefore, we need to add columns to the ends of big_matrix to compensate

if(lowest_time>0)
    big_matrix = [zeros(length(Tracks), floor(lowest_time)*Tracks(1).FrameRate) big_matrix(:,1:end)];
end

j_length = length(big_matrix(1,:));

if(~isempty(stimulus))
    i=1;
    while(stimulus(i,3)==0)
        i=i+1;
        if(i==length(stimulus(:,1)))
            break;
        end
    end
    
    % convert times in stimulus to frames
    stimulus(:,1) = round(stimulus(:,1)*Tracks(1).FrameRate);
    stimulus(:,2) = round(stimulus(:,2)*Tracks(1).FrameRate);
    
    if(time_axis(1) < 0)
        timeshift = -time_axis(1)*Tracks(1).FrameRate+1;
        
        stimulus(:,1) = stimulus(:,1) + timeshift;
        stimulus(:,2) = stimulus(:,2) + timeshift;
    end
end


if(isempty(base_cm))
    cm = ones(size(big_matrix,1), size(big_matrix,2), 3);
    
    if(~isempty(stimulus))
        i=1;
        while(stimulus(i,3)==0)
            i=i+1;
            if(i==length(stimulus(:,1)))
                break;
            end
        end
        
        while(i<=length(stimulus(:,1)))
            if(stimulus(i,3)>0)
                stim_colormap_vector = stimulus_colormap(stimulus(i,3));
                for(m=1:3)
                    cm(1:length(big_matrix((ymin+1):ymax,1)),stimulus(i,1):stimulus(i,2),m) = stim_colormap_vector(m);
                end
            end
            i=i+1;
        end
        
    end
    
    if(~isempty(missing_frame_color))
        for(i=1:length(big_matrix((ymin+1):ymax,1)))
            for(j=1:j_length)
                if(state_matrix(i,j) >= ringmiss_code || isnan(state_matrix(i,j)))
                    cm(i,j,:) = missing_frame_color; % [0.95 0.95 0.95]; % gray to mark missing or ring frames
                end
            end
        end
    end
    
else
    cm = base_cm;
end



if(nargin==3)
    base_cm = cm;
    return;
end

j_length_minus1 = j_length-1; % not a great sin since ethogram is for visualization only
for(i=1:length(big_matrix((ymin+1):ymax,1)))
    for(j=2:j_length_minus1) % ignore the ends
        if(big_matrix(i,j) > 0)
            cm(i,j,:)= color; % mark the initiation event
            cm(i,j-1,:)= color;  % make the mark thicker
            cm(i,j+1,:)= color;
        end
    end
end

if(~isempty(cm))
    image(cm);
end
axis xy

if(ymax<2)
    ymin=0;
    ymax=1;
end

box('off');
set(gca,'visible','on');

fontsize = (plot_rows*plot_columns)*(-2/5) + 16;

hx = [];
if(~(plot_rows==1 &&  plot_columns==1 && plot_location==1))
    set(gca,'xtick',[]);
else
    ymin = 1;
    % ymax = 100;
    hx = xlabel('Time (sec)');
    set(gca,'xtick',[0:((ceil(max(time_axis)) - floor(min(time_axis)))/3)*Tracks(1).FrameRate:size(big_matrix,2)]);
    xlim([0 size(big_matrix,2)]);
    set(gca,'xticklabel',[floor(min(time_axis)):(ceil(max(time_axis)) - floor(min(time_axis)))/3:ceil(max(time_axis))]);
end

ylim([ymin ymax]);
set(gca,'ytick',[ymax]);
set(gca,'yticklabel',[ymax]);

hy = ylabel('Track');

set(gca,'FontSize',fontsize);
set(hy,'FontSize',fontsize);
if(~isempty(hx))
    set(hx,'FontSize',fontsize);
end

clear('state_matrix');
clear('cm');
clear('big_matrix');

return;
end

