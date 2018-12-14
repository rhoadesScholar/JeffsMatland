function chemotaxis_track_movie(Tracks, newfilename)
% chemotaxis_track_movie(Tracks)

if(nargin<1)
    disp('chemotaxis_track_movie(Tracks)')
    return;
end

comet_flag = 1;
cometlength_frames = 1e10; % 200*Tracks(1).FrameRate;

ghost_trail_flag = 0;

startframe = min_struct_array(Tracks,'Frames');
endframe = max_struct_array(Tracks,'Frames');

height = Tracks(1).Height;
width = Tracks(1).Width;

filename = Tracks(1).Name;
file_info = moviefile_info(filename);
height = file_info.Height;
width = file_info.Width;

if(isfield(Tracks(1),'SmoothX'))
    xx = Tracks(1).SmoothX;
    yy = Tracks(1).SmoothY;
else
    xx = Tracks(1).Path(:,1);
    yy = Tracks(1).Path(:,2);
end
lone_track_axis_lim = [min(xx)-10 max(xx)+10 min(yy)-10 max(yy)+10 ];

cm = colormap(jet(length(Tracks(1).Frames)));

tempfilename = sprintf('%s.avi',tempname);
aviobj = VideoWriter(tempfilename);
aviobj.Quality = 100;
open(aviobj);

aviread_to_gray;
% aviread_to_gray(filename, startframe:endframe);
for(framenum=startframe:6:endframe)
    
    figure(1);
    
    Mov = aviread_to_gray(filename,framenum,0);
    
    if(length(Tracks)==1)
        subplot(4,2,[1 3 5]);
    end
    
%     imshow(Mov.cdata);
%     hold on;
    
    track_idx_frame_idx = find_Track(Tracks, 'Frames', sprintf('==%d',framenum) );
    
    for(i=1:length(track_idx_frame_idx))
        t = track_idx_frame_idx(i).track_idx;
        f = track_idx_frame_idx(i).frame_idx;
        
        % track comet
        if(comet_flag == 1)
            x = []; y = [];
            trackseg_start = max(1, f-cometlength_frames);
            for(ff = trackseg_start:f)
                x = [x Tracks(t).SmoothX(ff)];
                y = [y Tracks(t).SmoothY(ff)];
            end
            x = round(x);
            y = round(y);
            for(q=1:length(x))
                if(~isnan(x(q)) && ~isnan(y(q)))
                    for(z=-2:1:2)
                        for(z2=-2:1:2)
                            Mov.cdata(y(q)+z, x(q)+z2, :) = cm(q,:);
                        end
                    end
                end
            end
            clear('y');
            clear('x');
        end
    end
    
    imshow(Mov.cdata);
    
    if(length(Tracks)==1)
        axis(lone_track_axis_lim);
        % text('Position',[(lone_track_axis_lim(1)+10)  (lone_track_axis_lim(3)+10)],'String',sprintf('%.1f min', Tracks(t).Time(f)/60),'color','r');
    end
    hold off;
    
    f = track_idx_frame_idx(1).frame_idx;
    
    subplot(4,2,2);
    plot(Tracks(1).Time(1:f), Tracks(1).odor_distance(1:f),'.-');
    axis([Tracks(1).Time(1) Tracks(1).Time(end) min(Tracks(1).odor_distance) max(Tracks(1).odor_distance)])
    ylabel(sprintf('odor distance\n(mm)'));
    
    subplot(4,2,4);
    plot(Tracks(1).Time(1:f), Tracks(1).odor_angle(1:f),'.-');
    axis([Tracks(1).Time(1) Tracks(1).Time(end) min(Tracks(1).odor_angle) max(Tracks(1).odor_angle)])
    ylabel(sprintf('odor angle\n(deg)'));
    
    subplot(4,2,6);
    plot(Tracks(1).Time(1:f), Tracks(1).model_odor_conc(1:f),'.-');
    axis([Tracks(1).Time(1) Tracks(1).Time(end) min(Tracks(1).model_odor_conc) max(Tracks(1).model_odor_conc)])
    ylabel('[odor]');
    
    subplot(4,2,8);
    plot(Tracks(1).Time(1:f), Tracks(1).model_odor_gradient(1:f),'.-');
    axis([Tracks(1).Time(1) Tracks(1).Time(end) min(Tracks(1).model_odor_gradient) max(Tracks(1).model_odor_gradient)])
    ylabel(fix_title_string('d[odor]/dt'));
    xtt = get(gca,'xtick');
    xt = get(gca,'xticklabel');
    
    subplot(4,2,7);
    single_Track_ethogram(Tracks(1), Tracks(1).Frames(1), Tracks(1).Frames(min(f,length(Tracks(1).Frames))));
    xx = get(gca,'xtick');
    set(gca,'xticklabel',round(xx./3));
    xlabel(fix_title_string(sprintf('%s',num_state_convert(Tracks(1).State(f)))));
    hold off;
    
    set(gcf,'color','w');
    F = getframe(gcf);
    writeVideo(aviobj,F);
    
    close(1);
end
aviread_to_gray;

close(aviobj);

disp(sprintf('Saving the moviefile %s to %s',tempfilename, newfilename))
mv(tempfilename, newfilename);

return
end
