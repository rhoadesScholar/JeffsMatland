function play_Track(inputTrack, startframe, endframe)
% play_Track(inputTrack, startframe, endframe, speedup)

Track = inputTrack(1);
for(i=2:length(inputTrack))
    Track = append_track(Track, inputTrack(i));
end

speedup=100;


if(nargin<3)
    startframe=1;
    endframe=length(Track.Frames);
end

% if(startframe <= Track.Frames(1))
%     startframe = Track.Frames(1);
% end
% if(endframe >= Track.Frames(end))
%     endframe = Track.Frames(end);
% end

pausetime=1/(speedup*Track.FrameRate);

fignum = figure;
% set(0,'Units','normalized');
% scrsz = get(0,'ScreenSize');
% set(fignum,'Units','normalized');
% set(fignum,'Position',[0.125 0.125  0.75 0.75]);
% set(fignum,'Position',[0 0  scrsz(3) scrsz(4)]);

for(i=startframe:endframe)
    frame(Track.Width,Track.Height)=0; frame=frame+1;
    
    if(isfield(Track,'Image'))
        [y_coord, x_coord] = find(Track.Image{i}==1);
        x = x_coord + floor(Track.bound_box_corner(i,1));
        y = y_coord + floor(Track.bound_box_corner(i,2));
        for(q=1:length(x))
            frame(y(q),x(q)) = 0;
        end
        clear('x');
        clear('y');
        clear('y_coord');
        clear('x_coord');
        if(~isempty(Track.body_contour(i).x))
            for(q=1:length(Track.body_contour(i).x))
                frame(floor(Track.body_contour(i).y(q)), floor(Track.body_contour(i).x(q))) = 0.5;
            end
        else
            if(isfield(Track,'SmoothX'))
                x = floor(Track.SmoothX(i));
                y = floor(Track.SmoothY(i));
            else
                x = Track.Path(i,1);
                y = Track.Path(i,2);
            end
            if(~isnan(x))
                frame(y, x) = 1;
            end
        end
    else
        if(~isempty(Track.body_contour(i).x))
            for(q=1:length(Track.body_contour(i).x))
                frame(floor(Track.body_contour(i).y(q)), floor(Track.body_contour(i).x(q))) = 0;
            end
        else
            if(isfield(Track,'SmoothX'))
                x = floor(Track.SmoothX(i));
                y = floor(Track.SmoothY(i));
            else
                x = Track.Path(i,1);
                y = Track.Path(i,2);
            end
            if(~isnan(x))
                frame(y, x) = 0;
            end
        end
    end
    
    figure(fignum);
    subplot(3,2,[1 3 5]);
    imshow(frame);
    hold on;
    
    if(isfield(Track,'stimulus_vector'))
        if(isfield(Track,'Time'))
            text('Position',[10,10],'String',fix_title_string(sprintf('%d  %.2f  %d',Track.Frames(i),Track.Time(i),Track.stimulus_vector(i))),'color','k');
        else
            text('Position',[10,10],'String',fix_title_string(sprintf('%d  %d',Track.Frames(i),Track.stimulus_vector(i))),'color','k');
        end
    else
        if(isfield(Track,'Time'))
            text('Position',[10,10],'String',fix_title_string(sprintf('%d  %.2f',Track.Frames(i),Track.Time(i))),'color','k');
        else
            text('Position',[10,10],'String',fix_title_string(sprintf('%d',Track.Frames(i))),'color','k');
        end
    end
    
    if(isfield(Track,'SmoothX'))
        x = floor(Track.SmoothX(startframe:i));
        y = floor(Track.SmoothY(startframe:i));
    else
        x = Track.Path(startframe:i,1);
        y = Track.Path(startframe:i,2);
    end
    plot(x, y, 'g');
    
    
    hold off;
    
    subplot(3,2,2);
    plot(Track.Frames(startframe:i), Track.Eccentricity(startframe:i),'.-');
    axis([Track.Frames(startframe) Track.Frames(endframe) min(Track.Eccentricity) max(Track.Eccentricity)])
    ylabel('ecc');
    
    subplot(3,2,4);
    plot(Track.Frames(startframe:i), Track.Speed(startframe:i),'.-');
    axis([Track.Frames(startframe) Track.Frames(endframe) min(Track.Speed) max(Track.Speed)])
    ylabel('speed');
    
    subplot(3,2,6);
    single_Track_ethogram(Track, Track.Frames(startframe), Track.Frames(min(i+2,length(Track.Frames))));
    
    %     plot(Track.Frames(startframe:i), [Track.body_contour(startframe:i).tail],'.-');
    %     axis([Track.Frames(startframe) Track.Frames(endframe) min([Track.body_contour(startframe:endframe).tail]) max([Track.body_contour(startframe:endframe).tail])])
    hold off;
    
    
    pause(pausetime);
end
return;

end
