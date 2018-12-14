function plot_event_locations(Tracks, background, show_upsilon_flag)
% plot_event_locations(Tracks, background, show_upsilon_flag)
% show_upsilon_flag (optional) is 'yes' or 'no'

if(nargin<1)
    disp('usage: plot_event_locations(Tracks, background, show_upsilon_flag)')
    disp('show_upsilon_flag (optional) is ''yes'' or ''no''')
    return
end

if(nargin<3)
    show_upsilon_flag = 'yes';
end

upsilon_code = num_state_convert('upsilon');

if(nargin>1)
    if(~isempty(background))
        imshow(background);
    end
end
hold on;

markersize = 5;

if(strcmpi(show_upsilon_flag,'yes'))
    show_upsilon_flag = [];
    show_upsilon_flag = 1;
else
    show_upsilon_flag = 0;
end

for(i=1:length(Tracks))
    for(j=1:length(Tracks(i).mvt_init))
        if(Tracks(i).mvt_init(j)>=2)
            if(show_upsilon_flag==1)
                if(floor(Tracks(i).mvt_init(j))==upsilon_code)
                    plot(Tracks(i).SmoothX(j), Tracks(i).SmoothY(j), 'o', 'color', plot_track_colormap(Tracks(i).mvt_init(j))/255, 'markersize',4);
                else
                    plot(Tracks(i).SmoothX(j), Tracks(i).SmoothY(j), '.', 'color', plot_track_colormap(Tracks(i).mvt_init(j))/255, 'markersize',markersize);
                end
            else
                if(floor(Tracks(i).mvt_init(j))~=upsilon_code)
                    plot(Tracks(i).SmoothX(j), Tracks(i).SmoothY(j), '.', 'color', plot_track_colormap(Tracks(i).mvt_init(j))/255, 'markersize',markersize);
                end
            end
        end
    end
end

axis ij; axis equal
axis([0 Tracks(1).Width 0 Tracks(1).Height]);
hold off;

return;
end
