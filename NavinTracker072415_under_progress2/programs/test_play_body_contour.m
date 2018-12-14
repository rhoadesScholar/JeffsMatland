function test_play_body_contour(filename, tr)


if(~isfield(tr,'body_contour'))
    tr = body_contour_stuff(tr);
end

for(i=1:length(tr.Frames))
    
    figure(1);
    Mov = aviread_to_gray(filename,double(tr.Frames(i)));
    imshow(Mov.cdata);
    hold on;
    % plot(tr.SmoothX, tr.SmoothY, '-.g');
    % plot(tr.SmoothX(i), tr.SmoothY(i),'or');
    
    st = sprintf('%d',tr.Frames(i));
    st = sprintf('%s %d %s %f %f %f',st, tr.State(i), num_state_convert(tr.State(i)), tr.head_angle(i), tr.body_angle(i),tr.tail_angle(i));
    
    text('Position',[10,10],'String',sprintf('%s',st),'color','w');
    
    % plot body image
    s = size(tr.Image{i});
    bodyimage=zeros(length(find(tr.Image{i}==1)),2);
    pp=1;
    for(ii=1:s(1))
        for(jj=1:s(2))
            if(tr.Image{i}(ii,jj) == 1)
                bodyimage(pp,1) = jj +  floor(tr.bound_box_corner(i,1));
                bodyimage(pp,2) = ii +  floor(tr.bound_box_corner(i,2));
                pp=pp+1;
            end
        end
    end
    % plot(bodyimage(:,1), bodyimage(:,2),'.k');
    
    % plot body contour
    plot(tr.body_contour(i).x, tr.body_contour(i).y,'.w','markersize',0.1);
    
    if(tr.body_contour(i).head > 0)
        plot(tr.body_contour(i).x(tr.body_contour(i).head), tr.body_contour(i).y(tr.body_contour(i).head),'.b');
    end
    
    if(tr.body_contour(i).neck > 0)
        plot(tr.body_contour(i).x(tr.body_contour(i).neck), tr.body_contour(i).y(tr.body_contour(i).neck),'.c');
    end
    
    if(tr.body_contour(i).midbody > 0)
        plot(tr.body_contour(i).x(tr.body_contour(i).midbody), tr.body_contour(i).y(tr.body_contour(i).midbody),'.g');
    end
    
    if(tr.body_contour(i).lumbar > 0)
        plot(tr.body_contour(i).x(tr.body_contour(i).lumbar), tr.body_contour(i).y(tr.body_contour(i).lumbar),'.y');
    end
    
    if(tr.body_contour(i).tail > 0)
        plot(tr.body_contour(i).x(tr.body_contour(i).tail), tr.body_contour(i).y(tr.body_contour(i).tail),'.r');
    end
    
    pause(0.05);
    hold off;
    clear('Mov');
end

return

