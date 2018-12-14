function chemotaxis_track_movie_v2(Tracks, track_idx, target_verticies, newfilename)
% chemotaxis_track_movie(Tracks)

if(nargin<1)
    disp('chemotaxis_track_movie(Tracks)')
    return;
end

sub_movie_text_coords = [0.01 1.05];

special_track = Tracks(track_idx);
Tracks(track_idx)=[];

startframe = special_track.Frames(1);
i=1;
while(~inpolygon(special_track.SmoothX(i), special_track.SmoothY(i), target_verticies(:,1), target_verticies(:,2)))
    i=i+1;
end  
endframe = special_track.Frames(i);

[r, xc,yc] = circle_from_coords(target_verticies(:,1),target_verticies(:,2));
[xc,yc] = coords_from_circle_params(1.5*r, [xc yc]);

height = Tracks(1).Height;
width = Tracks(1).Width;

filename = Tracks(1).Name;
if(~file_existence(filename))
   filename = filename_from_partialpath(filename); 
   if(~file_existence(filename))
        error(sprintf('Cannot find %s',Tracks(1).Name));
   end
end
movie_info = moviefile_info(filename);
height = movie_info.Height;
width = movie_info.Width;


    xx = Tracks(1).SmoothX;
    yy = Tracks(1).SmoothY;

lrev_code = num_state_convert('lRev');
srev_code = num_state_convert('sRev');
omega_code = num_state_convert('omega');
upsilon_code = num_state_convert('upsilon');

boxwidth =  ceil(special_track.Wormlength/special_track.PixelSize);

tempfilename = sprintf('%s.avi',tempname);
aviobj = VideoWriter(newfilename);
aviobj.Quality = 100;
aviobj.FrameRate = 45;
open(aviobj);

aviread_to_gray;
% aviread_to_gray(filename, startframe:endframe);
f=1; fstep=3;
for(framenum=startframe:fstep:endframe)
    
    figure(1);
    % set(gcf,'position',[0 0 1024 1024],'units','pixels');
    
    Mov = aviread_to_gray(filename,framenum,0);
    
    ori_cdata = Mov.cdata;
    
    x = []; y = [];
            trackseg_start = 1;
            for(ff = trackseg_start:f)
                x = [x special_track.SmoothX(ff)];
                y = [y special_track.SmoothY(ff)];
            end
            x = round(x);
            y = round(y);
            for(q=1:length(x))
                
                
                s = floor(special_track.State(q));
                state_color = [1 1 1];
                    if(s==lrev_code || s==srev_code)
                        state_color = [0 0 1];
                    else
                        if(s==omega_code || s==upsilon_code)
                            state_color = [1 0 0];
                        end
                    end
                state_color = 255.*state_color;
                
                if(~isnan(x(q)) && ~isnan(y(q)))
                    for(z=-2:1:2)
                        for(z2=-2:1:2)
                            Mov.cdata(y(q)+z, x(q)+z2,:) = state_color;
                        end
                    end
                end
            end
            clear('y');
            clear('x');
    
          % h1 = subplot(3,1,[1 2]);
    imshow(Mov.cdata,'Border','tight');
    hold on;
    
    plot(xc,yc,'--r');
    
    for(i=1:length(Tracks))
        idx = find(Tracks(i).Frames == framenum);
        if(~isempty(idx))
            if(~inpolygon(Tracks(i).SmoothX(idx), Tracks(i).SmoothY(idx), target_verticies(:,1), target_verticies(:,2)))
            
            plot(Tracks(i).SmoothX(idx), Tracks(i).SmoothY(idx), 'ow', 'markersize',5);
            
            end
        end
    end
    
    plot(special_track.SmoothX(f), special_track.SmoothY(f), 'sk', 'markersize',10);
    
%    pos1 = get(h1,'position');
%     h2 = subplot(3,1,3);
%     pos2 = get(h2,'position');
%     single_Track_ethogram(special_track, special_track.Frames(1), special_track.Frames(min(f,length(special_track.Frames))));
%     xx = get(gca,'xtick');
%     set(gca,'xticklabel',round(xx./3));
%     xlabel(fix_title_string(sprintf('%s',num_state_convert(special_track.State(f)))));
%     hold off;
%     set(h2,'position',[pos1(1) pos2(2) pos1(3) pos2(4)]); 
        

text(1992/2, 1992, fix_title_string(sprintf('%d sec',(special_track.Time(f)))),...
    'fontsize',18,'color','w', 'horizontalalign','center','verticalalign','bottom','fontweight','bold','fontname','courier');


        f2 = axes('position',[0 0 0.175 0.175]);
        
        if(special_track.body_contour(f).midbody>0)
            little_image = ori_cdata(max(1,special_track.body_contour(f).y(special_track.body_contour(f).midbody)-boxwidth):min(movie_info.Height,special_track.body_contour(f).y(special_track.body_contour(f).midbody)+boxwidth), ...
                max(1,special_track.body_contour(f).x(special_track.body_contour(f).midbody)-boxwidth):min(movie_info.Width, special_track.body_contour(f).x(special_track.body_contour(f).midbody)+boxwidth));
        else
            little_image = ori_cdata(max(1,special_track.SmoothY(f)-boxwidth):min(movie_info.Height,special_track.SmoothY(f)+boxwidth), ...
                max(1,special_track.SmoothX(f)-boxwidth):min(movie_info.Width,special_track.SmoothX(f)+boxwidth));
        end
        
        imshow(little_image,'Border','tight');
        axis on;
        hold on;
%         xlims = get(gca,'xlim'); ylims = get(gca,'ylim');
%         plot([xlims(1) xlims(1)],[ylims(1) ylims(2)],'linewidth',5,'color',state_color);
%         plot([xlims(1) xlims(2)],[ylims(2) ylims(2)],'linewidth',5,'color',state_color);
%         plot([xlims(2) xlims(2)],[ylims(2) ylims(1)],'linewidth',5,'color',state_color);
%         plot([xlims(2) xlims(1)],[ylims(1) ylims(1)],'linewidth',5,'color',state_color);
        
        if(~isempty(special_track.body_contour(f).x))
            x_offset = special_track.body_contour(f).x(special_track.body_contour(f).midbody)-boxwidth;
            y_offset = special_track.body_contour(f).y(special_track.body_contour(f).midbody)-boxwidth;
            
            
            x = smooth(special_track.body_contour(f).x - x_offset);
            y = smooth(special_track.body_contour(f).y - y_offset);
            
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
            
            if(special_track.body_contour(f).head>0)
                plot(special_track.body_contour(f).x(special_track.body_contour(f).head) - x_offset , ...
                    special_track.body_contour(f).y(special_track.body_contour(f).head) - y_offset ,'ow','markerfacecolor','w');
                
            end
        end
        
        if(special_track.State(f)==num_state_convert('fwd') || special_track.State(f)==num_state_convert('pause'))
            hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                fix_title_string(sprintf('%s\n%.2f mm/sec',num_state_convert(special_track.State(f)), special_track.Speed(f))),'units','normalized');
        else
            reori_f = reorientation_frame(special_track, f);
            if(isempty(reori_f))
                hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                    fix_title_string(sprintf('%s\n%.2f mm/sec',num_state_convert(special_track.State(f)), special_track.Speed(f))),'units','normalized');
            else
                if(~isnan(special_track.Reorientations(reori_f).revLen))
                    hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                        [fix_title_string(sprintf('%s\n%.1f bodylen.\n%.1f',special_track.Reorientations(reori_f).class, special_track.Reorientations(reori_f).revLen, special_track.Reorientations(reori_f).delta_dir)) '\circ'],'units','normalized');
                else
                    hT = text(sub_movie_text_coords(1),sub_movie_text_coords(2),...
                        [fix_title_string(sprintf('%s\n%.1f',special_track.Reorientations(reori_f).class, special_track.Reorientations(reori_f).delta_dir)) '\circ'],'units','normalized');
                end
            end
        end
        set(hT,'verticalalign','bottom','horizontalalign','left','color','w','fontname','helvetica','fontsize',18);


    set(gcf,'color','w');
    
    F = getframe(gcf);
    writeVideo(aviobj,F);
    close(1);
    f = f+fstep;
end
aviread_to_gray;

close(aviobj);

% disp(sprintf('Saving the moviefile %s to %s',tempfilename, newfilename))
% mv(tempfilename, newfilename);

return
end
