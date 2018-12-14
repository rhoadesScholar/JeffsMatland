function plot_track(Track, filename, startframe_idx, endframe_idx)
% plot_track(Track, filename, startframe_idx, endframe_idx)

if(nargin<2)
    filename = '';
end

if(nargin<4)
    startframe_idx = 1;
    endframe_idx = max_struct_array(Track,'Frames');
end

if(nargin>3)
    Track = extract_track_segment(Track,startframe_idx, endframe_idx);
end

if(length(Track)>1)
    for(i=1:length(Track))
        hold on;
        if(nargin>3)
            plot_track(Track(i), filename, startframe_idx, endframe_idx);
        else
            plot_track(Track(i), filename);
        end
        disp([i])
        pause(0.1);
    end
    return;
end


markertype = '.';

if(isfield(Track,'SmoothX'))
    x = Track.SmoothX;
    y = Track.SmoothY;
else
    x = Track.Path(:,1);
    y = Track.Path(:,2);
end

if(nargin>1)
    if(~isempty(filename))
        background = calculate_background(filename);
        imshow(background);
        hold on;
    end
end

markersize=5;

point_color = [rand rand rand]; % 'k';

cm = (jet(length(Track.Frames)));

% point_color = [rand rand rand];
for(i=1:length(Track.Frames))
    
    point_color = cm(i,:);
    markersize=5;
    
    if(isfield(Track,'State'))
        if(~isnan(Track.State(i)))
            if(isfield(Track,'State'))
                
%                 if(floor(Track.State(i)) ~= num_state_convert('fwd')) 
%                     point_color =  plot_track_colormap(Track.State(i))/255;
%                 else
%                     markersize=markersize/2;
%                 end
            else
                point_color = 'k';
            end
            
            
                   if(Track.State(i)<= num_state_convert('fwd_state'))
                        if(isfield(Track,'Curvature'))
                            % Track.Curvature(i)
                            % point_color =  curvature_colormap(Track.Curvature(i));
                        end
                   end
                   
            plot(x(i), y(i), markertype, 'color', point_color, 'markersize',markersize, 'LineStyle','none');
            hold on;
        end
    else
        plot(x(i), y(i), markertype, 'color', point_color, 'markersize',markersize, 'LineStyle','none');
        hold on;
    end
end




plot(x(1),y(1),'ob','markersize',10, 'linewidth',2);
hold on;
plot(x(end),y(end),'or', 'markersize',10,'linewidth',2);
hold on;
axis('ij');

axis([0 Track.Width 0 Track.Height]);

% axis([min(x) max(x) min(y) max(y)]);



return;

end

