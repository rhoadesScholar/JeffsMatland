function play_Tracks(Tracks, filename, startframe, endframe)
% play_Tracks(Tracks, filename_or_dimension_vector, startframe, endframe)

if(nargin<1)
    disp('play_Tracks(Tracks, filename_or_dimension_vector, startframe, endframe)')
    return;
end

if(ischar(Tracks))
    ds = Tracks;
    clear('Tracks');
    Tracks = load_Tracks(ds);
    clear('ds');
end

comet_flag = 1;
cometlength_frames = 200*Tracks(1).FrameRate;

ghost_trail_flag = 0;

if(nargin<4)
    startframe = min_struct_array(Tracks,'Frames');
    endframe = max_struct_array(Tracks,'Frames');
end

height = Tracks(1).Height;
width = Tracks(1).Width;

if(length(Tracks)==1)
    box_scale_factor = 10;
    bound_box_dim = [];
    for(j=1:length(Tracks(1).Frames))
        if(isfield(Tracks(1),'Image'))
            bound_box_dim = [bound_box_dim max(size(Tracks(1).Image{j}))];
        else
            bound_box_dim = [bound_box_dim (length(Tracks(1).body_contour(j).x))];
        end
    end
    bound_box_dim = 5*nanmean(bound_box_dim);
    %[curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position(Tracks(1));
    curvature_vs_body_position_matrix = Tracks(1).curvature_vs_body_position_matrix;
    kappa_midbody = Tracks(1).midbody_angle;
end

if(nargin<2)
    filename = '';
else
    if(isnumeric(filename))
        width = filename(1);
        height = filename(2);
        filename = '';
    else
        if(~isempty(filename))
            file_info = moviefile_info(filename);
            height = file_info.Height;
            width = file_info.Width;
        end
    end
end



if(length(Tracks)==1)
    if(isfield(Tracks(1),'SmoothX'))
        xx = Tracks(1).SmoothX;
        yy = Tracks(1).SmoothY;
    else
        xx = Tracks(1).Path(:,1);
        yy = Tracks(1).Path(:,2);
    end
    lone_track_axis_lim = [min(xx)-10 max(xx)+10 min(yy)-10 max(yy)+10 ];
    lone_track_center_x = mean([(min(xx)-10) (max(xx)+10)]);
    lone_track_center_y = mean([(min(yy)-10) (max(yy)+10)]);
    
    % lone_track_axis_lim = [(128-100)  (128+100)  (290-100) (290+100)];
end



aviread_to_gray;
for(framenum=startframe:endframe)
    if(isempty(filename))
        frame(height,width) =  0; frame = frame+1;
    else
        Mov = aviread_to_gray(filename,framenum);
        frame = Mov.cdata;
    end
    
    if(length(Tracks)==1)
        subplot(4,2,[1 3 5]);
    end
    
    if(ghost_trail_flag==0 || framenum==startframe)
        imshow(frame);
    end
    hold on;
    
    
    track_idx_frame_idx = find_Track(Tracks, 'Frames', sprintf('==%d',framenum) );
        
    for(i=1:length(track_idx_frame_idx))
        t = track_idx_frame_idx(i).track_idx;
        f = track_idx_frame_idx(i).frame_idx;
        
        % image or body contour
%         if(isfield(Tracks(t),'body_contour'))
%             x_coord = Tracks(t).body_contour(f).x;
%             y_coord = Tracks(t).body_contour(f).y;
%             x = x_coord;
%             y = y_coord;
%         else
            if(isfield(Tracks(t),'Image'))
                [y_coord, x_coord] = find(Tracks(t).Image{f}==1);
                x = x_coord + floor(Tracks(t).bound_box_corner(f,1));
                y = y_coord + floor(Tracks(t).bound_box_corner(f,2));
            else
                x = Tracks(t).SmoothX(f);
                y = Tracks(t).SmoothY(f);
            end
%        end
        color_vector = [rand rand rand];
        for(q=1:length(x))
            if(~isnan(x(q)) && ~isnan(y(q)))
                
                
                if(ghost_trail_flag == 0)
                    plot(x(q), y(q),'.r','markersize',1); % frame(y(q),x(q),:) = [0 255 0];
                else
                    plot(x(q), y(q),'marker','.','color',color_vector,'markersize',10); % frame(y(q),x(q),:) = [0 255 0];
                end
            end
        end
        clear('y_coord');
        clear('x_coord');
        clear('y');
        clear('x');
        
        % track comet
        if(comet_flag == 1)
            x = []; y = [];
            trackseg_start = max(1, f-cometlength_frames);
            for(ff = trackseg_start:f)
                if(isfield(Tracks(t),'SmoothX'))
                    x = [x Tracks(t).SmoothX(ff)];
                    y = [y Tracks(t).SmoothY(ff)];
                else
                    x = [x Tracks(t).Path(ff,1)];
                    y = [y Tracks(t).Path(ff,2)];
                end
            end
            x = round(x);
            y = round(y);
            for(q=1:length(x))
                if(~isnan(x(q)) && ~isnan(y(q)))
                    plot(x(q), y(q),'.k','markersize',1);
                    %                 if(isempty(filename))
                    %                     frame(y(q),x(q)) = 0;
                    %                 else
                    %                     color_vector = [0 0 0];
                    %
                    %                     u=0; v=0;
                    %                     %                 for(u=-1:1)
                    %                     %                     for(v=-1:1)
                    %                     frame(y(q)+u,x(q)+v,:) = color_vector;
                    %                     %                     end
                    %                     %                 end
                    %
                    %                 end
                end
            end
            clear('y');
            clear('x');
        end
    end
    
    
    
    for(i=1:length(track_idx_frame_idx))
        t = track_idx_frame_idx(i).track_idx;
        f = track_idx_frame_idx(i).frame_idx;
        
        if(isfield(Tracks(t),'SmoothX'))
            x = Tracks(t).SmoothX(f);
            y = Tracks(t).SmoothY(f);
        else
            x = Tracks(t).Path(f,1);
            y = Tracks(t).Path(f,2);
        end
        
        if(length(Tracks)>1)
            text('Position', [x y],'String',sprintf('%d',t),'color','b');
        end
    end
    
    
    if(length(Tracks)==1)
        axis(lone_track_axis_lim);
        text('Position',[(lone_track_axis_lim(1)+10)  (lone_track_axis_lim(3)+10)],'String',sprintf('%d  %d', framenum, length(track_idx_frame_idx)),'color','r');
    else
        text('Position',[10,10],'String',sprintf('%d  %d', framenum, length(track_idx_frame_idx)),'color','r');
    end
    
    hold off;
    
    if(length(Tracks)==1 && isfield(Tracks(1),'SmoothX') && ~isempty(track_idx_frame_idx))
        
        f = track_idx_frame_idx(1).frame_idx;
        
        subplot(4,2,2);
        plot(Tracks(1).Frames(1:f), Tracks(1).AngSpeed(1:f),'.-');
        axis([Tracks(1).Frames(1) Tracks(1).Frames(end) -22.5 22.5])
        ylabel('angSpeed');
        
        subplot(4,2,4);
        plot(Tracks(1).Frames(1:f), Tracks(1).Speed(1:f),'.-');
        axis([Tracks(1).Frames(1) Tracks(1).Frames(end) min(Tracks(1).Speed) max(Tracks(1).Speed)])
        ylabel('speed');
        
        subplot(4,2,6);
        plot(Tracks(1).Frames(1:f), Tracks(1).Eccentricity(1:f),'.-');
        axis([Tracks(1).Frames(1) Tracks(1).Frames(end) max(0.9, min(Tracks(1).Eccentricity)) max(Tracks(1).Eccentricity)])
        ylabel('ecc');
        
        subplot(4,2,8);
        plot(Tracks(1).Frames(1:f), kappa_midbody(1:f),'.-');
        axis([Tracks(1).Frames(1) Tracks(1).Frames(end) min(kappa_midbody) max(kappa_midbody)])
        ylabel(fix_title_string('body_curv'));
        
        subplot(4,2,7);
        single_Track_ethogram(Tracks(1), Tracks(1).Frames(1), Tracks(1).Frames(min(f+2,length(Tracks(1).Frames))));
        
        hold off;
    end
    
    %if(isempty(filename))
        pause(0.001);
    %end
    
    clear('frame');
    
end
aviread_to_gray;

return
end
