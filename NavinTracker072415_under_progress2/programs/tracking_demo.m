function tracking_demo(moviename, stimulus, starttime, endtime, BinData)
% plays the movie from starttime sec to endtime sec
% main panel shows the entire arena, with each worm circled
% 6 subpanels - worms in man figure boxed instead of dotted
% border line the same color as the main panel box
% Text with fwd speed or reorientation state and stats
% Additional panels showing average speed, rev freq, omega etc

new_file = 'demo.avi';


colors = {'b','c','g','y','m','r'};
sub_movie_text_coords = [0.5 1.05];

% rows = 4;
% columns = 5;
% main_loc = [1 2 3  6 7 8  11 12 13];
% sub_movie_loc = {[4],[5],[9],[10],[14],[15]};
% mean_speed_loc = [16];
% mean_body_angle_loc = [17];
% revfreq_loc = [18];
% omegafreq_loc = [20];

% rows = 4;
% columns = 10;
% main_loc = [1 2 3 4 5  11 12 13 14 15   21 22 23 24 25];
% sub_movie_loc = {[7 8],[9 10],[17 18],[19 20],[27 28],[29 30]};
% mean_speed_loc = [31 32];
% mean_body_angle_loc = [34 35];
% revfreq_loc = [35 36 ];
% omegafreq_loc = [39 40];

rows = 3;
columns = 10;
main_loc = [1 2 3 4 5  11 12 13 14 15 ];
sub_movie_loc = {[7 8],[9 10],[17 18],[19 20],[27 28],[29 30]};
mean_speed_loc = [21 22];
revfreq_loc = [24 25];

[pathstr, prefix] = fileparts(moviename);
if(~isempty(pathstr))
    Tracks = load_Tracks(sprintf('%s%s%s.linkedTracks.mat',pathstr, filesep, prefix));
else
    Tracks = load_Tracks(sprintf('%s.linkedTracks.mat', prefix));
end


fps = Tracks(1).FrameRate;

if(nargin<4)
    starttime = min_struct_array(Tracks,'Time');
    endtime = max_struct_array(Tracks,'Time');
end

if(nargin<5)
    if(~isempty(pathstr))
    BinData = load_BinData(sprintf('%s%s%s.BinData.mat',pathstr, filesep, prefix));
    else
    BinData = load_BinData(sprintf('%s.BinData.mat', prefix));
end
end

if(starttime == 0)
    starttime = min_struct_array(Tracks,'Time');
end

startframe = starttime*fps;
endframe = endtime*fps;

movie_info =  moviefile_info(moviename);
Tracks = sort_tracks_by_pathlength(Tracks);

% tracks that span the entire time and are complete and are not ringed
special_track_idx = []; lens = [];
for(i=1:length(Tracks))
    p=0;
    if(~isempty(find(Tracks(i).Frames == startframe)) && ~isempty(find(Tracks(i).Frames == endframe)))
        special_track_idx = [special_track_idx i];
        idx = find(Tracks(i).Frames >= startframe & Tracks(i).Frames <= endframe);
        
        for(j=1:length(idx))
            if(~isempty(Tracks(i).body_contour(idx(j)).x) && Tracks(i).State(idx(j))~=num_state_convert('pause')) % && Tracks(i).State(idx(j))<num_state_convert('ring') )
                p=p+1;
            end
        end
    end
    lens = [lens p];
end
[~,idx] = sort(-lens);
special_track_idx= idx(1:min(6,length(idx)));
specialTracks = Tracks(special_track_idx);
num_special_tracks = length(specialTracks);
Tracks(special_track_idx) = [];

boxwidth = [];
for(i=1:length(specialTracks))
    boxwidth =  [boxwidth ceil(specialTracks(i).Wormlength/specialTracks(i).PixelSize)];
end
boxwidth = max(boxwidth);

% interpolate and spline to estimate the binned values for each frame
tm = BinData.time*fps;
frq_tm = BinData.freqtime*fps;
frames = 1:movie_info.NumFrames;
[BinData.speed] = interpolate_and_fill_data(tm, BinData.speed, frames);
[BinData.Rev_freq] = interpolate_and_fill_data(frq_tm, BinData.Rev_freq, frames);
[BinData.omega_freq] = interpolate_and_fill_data(frq_tm, BinData.omega_freq, frames);
[BinData.time] = interpolate_and_fill_data(tm, BinData.time, frames);
[BinData.freqtime] = interpolate_and_fill_data(frq_tm, BinData.freqtime, frames);

% BinData.speed = spline(BinData.time, BinData.speed, linspace(BinData.time(1), BinData.time(end), num_frames));
% BinData.Rev_freq = spline(BinData.freqtime, BinData.Rev_freq, linspace(BinData.freqtime(1), BinData.freqtime(end), num_frames));
% BinData.omega_freq = spline(BinData.freqtime, BinData.omega_freq, linspace(BinData.freqtime(1), BinData.freqtime(end), num_frames));
% BinData.time = linspace(BinData.time(1), BinData.time(end), num_frames);
% BinData.freqtime = linspace(BinData.freqtime(1), BinData.freqtime(end), num_frames);


tempfilename = sprintf('%s.avi',tempname);
tempfilename
aviobj = VideoWriter(tempfilename); % , 'MPEG-4');
aviobj.Quality = 100;
aviobj.FrameRate = 15;
open(aviobj);

all_frame_idx = startframe:endframe;


for(i=1:length(Tracks))
    Tracks(i).Reorientations = strip_ring_Reorientations(Tracks(i).Reorientations);
    Tracks(i).State = AssignLocomotionState(Tracks(i));
end


stim_idx = 1;
for(frame = startframe:endframe)
    fig_h = figure(1);
    set(gcf,'position',[0 0 1024 1024],'units','pixels');  
    
    current_time = startframe/fps;
    
    Mov = aviread_to_gray(moviename,frame);
    
    subplot(rows, columns, main_loc);
    imshow(Mov.cdata);
   hold on
   
    for(i=1:length(Tracks))
        idx = find(Tracks(i).Frames == frame);
        if(~isempty(idx))
            plot(Tracks(i).SmoothX(idx), Tracks(i).SmoothY(idx), 'ow', 'markersize',15);
            
            current_time = Tracks(i).Time((Tracks(i).Frames == frame));
            time_string = sprintf('%.1f sec',current_time); % seconds_to_time_colon_string(current_time);
        end
    end
    
    
    hold on;
    if(isempty(stimulus))
        xh = xlabel(sprintf('%s', time_string),'verticalalign','top','HorizontalAlignment','center','FontWeight','bold','BackgroundColor',[0.7 0.7 0.7],'fontsize',12,'fontname','courier');
    else
        if(i>fps*stimulus(stim_idx,2))
            stim_idx = stim_idx+1;
        end
        if(stim_idx > size(stimulus,1))
            stim_idx = 1;
        end
        if(frame >= fps*stimulus(stim_idx,1) && frame <= fps*stimulus(stim_idx,2) && stimulus(stim_idx,3)>0)
            xh = xlabel(fix_title_string(sprintf('%s ON %.2f mW ',time_string, stimulus(stim_idx,4))),'verticalalign','top','HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)),'fontsize',18,'fontname','courier');
        else
            xh = xlabel(sprintf('%s', time_string),'verticalalign','top','HorizontalAlignment','center','FontWeight','bold','BackgroundColor',[0.7 0.7 0.7],'fontsize',18,'fontname','courier');
        end
    end
    pos = get(xh,'position'); 
    set(xh,'position',[pos(1) pos(2)-25 pos(3)]);
    hold on;
    
    for(i=1:num_special_tracks)
        idx = find(specialTracks(i).Frames == frame);
        
        subplot(rows, columns, main_loc);
        hold on;
        plot(specialTracks(i).SmoothX(idx), specialTracks(i).SmoothY(idx), 's', 'markersize',15,'color',colors{i});
        hold off;
        
        subplot(rows, columns, [sub_movie_loc{i}]);
        
        if(specialTracks(i).body_contour(idx).midbody>0)
            little_image = Mov.cdata(max(1,specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).midbody)-boxwidth):min(movie_info.Height,specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).midbody)+boxwidth), ...
                max(1,specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).midbody)-boxwidth):min(movie_info.Width, specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).midbody)+boxwidth));
        else
            little_image = Mov.cdata(max(1,specialTracks(i).SmoothY(idx)-boxwidth):min(movie_info.Height,specialTracks(i).SmoothY(idx)+boxwidth), ...
                max(1,specialTracks(i).SmoothX(idx)-boxwidth):min(movie_info.Width,specialTracks(i).SmoothX(idx)+boxwidth));
        end
        
        imshow(little_image);
        hold on;
        xlims = get(gca,'xlim'); ylims = get(gca,'ylim');
        plot([xlims(1) xlims(1)],[ylims(1) ylims(2)],'linewidth',5,'color',colors{i});
        plot([xlims(1) xlims(2)],[ylims(2) ylims(2)],'linewidth',5,'color',colors{i});
        plot([xlims(2) xlims(2)],[ylims(2) ylims(1)],'linewidth',5,'color',colors{i});
        plot([xlims(2) xlims(1)],[ylims(1) ylims(1)],'linewidth',5,'color',colors{i});
        
        if(~isempty(specialTracks(i).body_contour(idx).x))
            x_offset = specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).midbody)-boxwidth;
            y_offset = specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).midbody)-boxwidth;
            
            
            x = smooth(specialTracks(i).body_contour(idx).x - x_offset);
            y = smooth(specialTracks(i).body_contour(idx).y - y_offset);
            
            % spline to add more points to contour
            t = 1:length(x);
            ts = 1:(length(x)/(100-1)):(length(x)+1);
            if(ts(end)<length(x))
                ts = [ts length(x)];
            end
            xx = (spline(t,x,ts));
            yy = (spline(t,y,ts));
            
%            plot(xx, yy,'.w','markersize',0.01);
            plot(xx, yy,'w');
            
            if(specialTracks(i).body_contour(idx).head>0)
                plot(specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).head) - x_offset , ...
                    specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).head) - y_offset ,'ow','markerfacecolor','w');
                
                %             plot(specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).tail) - x_offset , ...
                %                  specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).tail) - y_offset ,'.r');
                %
                %             plot(specialTracks(i).body_contour(idx).x(specialTracks(i).body_contour(idx).midbody) - x_offset , ...
                %                  specialTracks(i).body_contour(idx).y(specialTracks(i).body_contour(idx).midbody) - y_offset ,'.g');
            end
        end
        
        if(specialTracks(i).State(idx)==num_state_convert('fwd') || specialTracks(i).State(idx)==num_state_convert('pause'))
            hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                fix_title_string(sprintf('%s\n%.2f mm/sec',num_state_convert(specialTracks(i).State(idx)), specialTracks(i).Speed(idx))),'units','normalized');
        else
            reori_idx = reorientation_frame(specialTracks(i), idx);
            if(isempty(reori_idx))
                hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                    fix_title_string(sprintf('%s\n%.2f mm/sec',num_state_convert(specialTracks(i).State(idx)), specialTracks(i).Speed(idx))),'units','normalized');
            else
                if(~isnan(specialTracks(i).Reorientations(reori_idx).revLen))
                    hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                        [fix_title_string(sprintf('%s\n%.1f bodylen. %.1f',specialTracks(i).Reorientations(reori_idx).class, specialTracks(i).Reorientations(reori_idx).revLen, specialTracks(i).Reorientations(reori_idx).delta_dir)) '\circ'],'units','normalized');
                else
                    hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                        [fix_title_string(sprintf('%s\n%.1f',specialTracks(i).Reorientations(reori_idx).class, specialTracks(i).Reorientations(reori_idx).delta_dir)) '\circ'],'units','normalized');
                end
            end
        end
        set(hT,'verticalalign','bottom','horizontalalign','center','color','k','fontname','helvetica','fontsize',18);
        
        hold off;
    end
    
    local_stimulus = [];
    for(s=1:size(stimulus,1))
        if(stimulus(s,1) <= current_time && stimulus(s,2) <= current_time)
            local_stimulus = [local_stimulus; stimulus(s,:)];
        else
            if(stimulus(s,1) <= current_time && stimulus(s,2) > current_time)
                local_stimulus = [local_stimulus; stimulus(s,1) current_time stimulus(s,3)];
            end
        end
    end
    
    [~,start_idx] = find_closest_value_in_array(starttime, BinData.time);
    [~,end_idx] = find_closest_value_in_array(current_time, BinData.time);
    idx = [start_idx:end_idx];
    [~,real_end_idx] = find_closest_value_in_array(endtime, BinData.time);
    bin_idx = [start_idx:real_end_idx];
    subplot(rows,columns,mean_speed_loc);
    stimulusShade(local_stimulus, 0, 0.25); hold on;
    plot(BinData.time(idx), BinData.speed(idx),'k','linewidth',4);
    xlim([starttime endtime]); ylim([0 0.25]);
    ylabel(sprintf('speed\n(mm/sec)'));
    set(gca,'fontsize',18); set(gca,'xticklabel',[]); set(gca,'xcolor','w');
    box off
    
    [~,start_idx] = find_closest_value_in_array(starttime, BinData.freqtime);
    [~,end_idx] = find_closest_value_in_array(current_time, BinData.freqtime);
    idx = [start_idx:end_idx];
    [~,real_end_idx] = find_closest_value_in_array(endtime, BinData.freqtime);
    bin_idx = [start_idx:real_end_idx];
    
    subplot(rows,columns,revfreq_loc);
    stimulusShade(local_stimulus, 0, (max(BinData.Rev_freq(all_frame_idx)))); hold on;
    plot(BinData.freqtime(idx), BinData.Rev_freq(idx),'k','linewidth',4);
    xlim([starttime endtime]);  ylim([0 (max(BinData.Rev_freq(all_frame_idx)))]);
    ylabel(sprintf('Reversal\nfrequency\n(/min)'));
    set(gca,'fontsize',18); set(gca,'xticklabel',[]); set(gca,'xcolor','w');
    box off
    
%     subplot(rows,columns,omegafreq_loc);
%     plot(BinData.freqtime(idx), BinData.omega_freq(idx),'r');
%     xlim([starttime endtime]);  ylim([0 (max(BinData.omega_freq(bin_idx)))]);
%     ylabel(sprintf('omega\nfrequency\n(/min)'));
    
    set(gcf,'color','w');
    
    
    
    F = getframe(fig_h);
    
    F.cdata = F.cdata(1:640,45:1000,:);
    
    writeVideo(aviobj,F);
    close(fig_h);
    
end

close(aviobj);
disp(sprintf('Saving the truncated moviefile %s to %s',tempfilename, new_file))
cp(tempfilename, new_file);

return;
end
