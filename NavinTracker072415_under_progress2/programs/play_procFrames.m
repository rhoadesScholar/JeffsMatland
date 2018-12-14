function play_procFrames(procFrame, filename, startframe, endframe)
% play_procFrames(procFrame, filename_or_dimension_vector, startframe, endframe)

if(nargin<1)
    disp('play_procFrames(procFrame, filename_or_dimension_vector, startframe, endframe)')
    return;
end

colors = 255*str2rgb({'r','g','b','c','y','m'});

if(ischar(procFrame))
    ds = procFrame;
    clear('procFrame');
    load(ds);
    clear('ds');
end

if(nargin<4)
    startframe = 1;
    endframe = length(procFrame);
end

height = 512;
width = 512;
arena = [];

if(nargin<2)
    filename = '';
else
    if(isnumeric(filename))
        if(length(filename)==2)
            width = filename(1);
            height = filename(2);
        else
            arena = filename;
            height = size(arena,1);
            width = size(arena,2);
        end
        filename = '';
    else
        if(~isempty(filename))
            file_info = moviefile_info(filename);
            height = file_info.Height;
            width = file_info.Width;
        end
    end
end

aviread_to_gray;
% aviread_to_gray(filename,[startframe:endframe]);
if(isempty(arena))
    arena = zeros(height,width)+1;
end
    
for(i=startframe:endframe)
    
    if(isempty(filename))
        frame =  arena;
    else
        Mov = aviread_to_gray(filename,i,0);
        frame = Mov.cdata;
    end
    
    
    for(j=1:length(procFrame(i).worm))
        
        [y_coord, x_coord] = find(procFrame(i).worm(j).image==1);
        
        x = x_coord + floor(procFrame(i).worm(j).bound_box_corner(1));
        y = y_coord + floor(procFrame(i).worm(j).bound_box_corner(2));
        
        for(q=1:length(x))
            if(isempty(filename))
                frame(y(q),x(q)) =  0;
            else
              %if(mod(q,2)==0)
                frame(y(q),x(q),:) = [255 0 0]; % colors(mod(j,length(colors))+1,:);  % [0 255 0];
              %end
            end
        end
        
        
        clear('y_coord');
        clear('x_coord');
        clear('y');
        clear('x');
        
    end
    
    if(isfield(procFrame(i), 'clump'))
        for(j=1:length(procFrame(i).clump))
            
            [y_coord, x_coord] = find(procFrame(i).clump(j).image==1);
            
            x = x_coord + floor(procFrame(i).clump(j).bound_box_corner(1));
            y = y_coord + floor(procFrame(i).clump(j).bound_box_corner(2));
            
            for(q=1:length(x))
                if(isempty(filename))
                    frame(y(q),x(q)) = 0.5;
                else
                    %if(mod(q,2)==0)
                    frame(y(q),x(q),:) = [255 255 255];
                    %end
                end
            end
            
            clear('y_coord');
            clear('x_coord');
            clear('y');
            clear('x');
            
        end
    end
    
   
    imshow(frame);
    hold on;
    if(isfield(procFrame,'threshold'))
        text('Position',[10,10],'String',sprintf('%d  %d  %f',procFrame(i).frame_number, length(procFrame(i).worm), procFrame(i).threshold),'color','r');
    else
        text('Position',[10,10],'String',sprintf('%d  %d',procFrame(i).frame_number, length(procFrame(i).worm)),'color','r');
    end
    %     for(j=1:length(procFrame(i).worm))
    %         text('Position', procFrame(i).worm(j).coords,'String',sprintf('%d',j),'color','b');
    %     end
    
%     set(gca,'xlim',1000*[ 1.1286    1.8586]);
%     set(gca,'ylim',1000*[ 1.2516    1.9876]);
    
    hold off;
    pause(0.1);
    clear('frame');
    
    
end
aviread_to_gray;

return

end
