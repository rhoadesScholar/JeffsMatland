function Ring = find_square_ring_manually(background, summary_image)

if(nargin<2)
    summary_image=[];
end

global Prefs;

Ring.RingX = [];
Ring.RingY = [];
Ring.ComparisonArrayX = [];
Ring.ComparisonArrayY = [];
Ring.Area = 0;
Ring.ring_mask = [];
Ring.Level = eps;
Ring.PixelSize = Prefs.DefaultPixelSize;
Ring.FrameRate = Prefs.FrameRate; % default framerate
Ring.NumWorms = [];
Ring.DefaultThresh = [];
Ring.meanWormSize = [];

pixel_dim = size(background);

figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
imshow(background);
hold on;

scaleRing = [];

answer = questdlg('Is there a scale object on this movie?', sprintf('PID %d %s',Prefs.PID,'Is there a scale object on this movie?'), ...
    'Yes', 'No', 'Yes with ring', 'Yes');
if(answer(1) == 'Y' )
    scaleRing = get_pixelsize_from_arbitrary_object(background);
    Ring.PixelSize = scaleRing.PixelSize;
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    close all;
    pause(1);
end
if(answer(end)=='s')
    return;
end

ringtype_answer = questdlg('Is this a single copper ring?', sprintf('PID %d %s',Prefs.PID,'Is this a single copper ring?'), ...
    'Arbitrary ring', sprintf('square %.1fmm x %.1fmm',Prefs.RingSideLength, Prefs.RingSideLength), 'No', 'Arbitrary ring');

% a single copper ring
if(ringtype_answer(1) ~= 'N')
    
    % find the ring
    Ring = find_arbitrary_ring(background);
    close all;
    pause(1);
    
    % arbitrary ring
    if(ringtype_answer(1) == 'A')
        if(~isempty(scaleRing))
            Ring.PixelSize = scaleRing.PixelSize;
            Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
        end
        return;
    end
    
    % standard square ring
    
    Ring.PixelSize = calc_pixelsize_from_square_ring(Ring, Prefs.RingSideLength, max(pixel_dim));
    
    if(isnan(Ring.PixelSize))
        disp([sprintf('Cannot find %.1fmm x %.1fmm square ring\t%s',Prefs.RingSideLength, Prefs.RingSideLength,timeString())])
        if(isfield(Prefs,'PixelSize'))
            Ring.PixelSize = Prefs.DefaultPixelSize;
        end
        disp([sprintf('Use PixelSize of %f',Prefs.DefaultPixelSize)]);
        Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
        
        close all;
        pause(1);
        
        Ring.RingX = [];
        Ring.RingY = [];
        Ring.ComparisonArrayX = [];
        Ring.ComparisonArrayY = [];
        Ring.Area = 0;
        return;
    end
    
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    disp([sprintf('Manually defined %.1fmm x %.1fmm square copper ring with pixelsize %f\t%s',Prefs.RingSideLength, Prefs.RingSideLength,Ring.PixelSize, timeString())])
    
    close all;
    pause(1);
    
    return;
end


answer = questdlg('Multiple or Microfluidic Arenas?', sprintf('PID %d %s',Prefs.PID,'Multiple or Microfluidic Arenas?'), 'Multiple or Microfluidic Arenas', 'Other object','No','Multiple or Microfluidic Arenas');

if(answer(1) == 'N')
    answer = questdlg('Boundry?', sprintf('PID %d %s',Prefs.PID,'Boundry?'), 'Exclusion edge','No Boundry','No Boundry');
    while(answer(1) ~= 'N')
        
        questdlg(sprintf('Select inner exclusion edge verticies.\nClose the polygon and return when done.'), sprintf('PID %d %s',Prefs.PID,'Select inner exclusion edge verticies'), 'OK', 'OK');
        
        answer(1) = 'N';
        while(answer(1) == 'N')
            close all
            imshow(background);
            [x, y] = ginput2('*r');
            x = [x; x(1)];
            y = [y; y(1)];
            
            imshow(background);
            hold on;
            plot(x,y,'*g');
            
            answer = questdlg('Is the exclusion edge properly defined?', sprintf('PID %d %s',Prefs.PID,'Exclusion edge'), 'Yes', 'No', 'Yes');
            hold off;
        end
        close all
        
        shape_answer = questdlg('Edge shape?', sprintf('PID %d %s',Prefs.PID,'Edge shape?'), 'Circular','Polygon','Circular');
        if(shape_answer(1) == 'C')
            [radius, xc,yc] = circle_from_coords(x,y);
            [x,y] = coords_from_circle_params(radius, [xc,yc]);
        end
        
        hold off;
        figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
        imshow(background);
        hold on;
        plot(x, y,'g');
        
        Ring.ring_mask = uint8(poly2mask(x, y, size(background,1), size(background,2)));
        
        answer = questdlg('Is the exclusion edge properly defined?', sprintf('PID %d %s',Prefs.PID,'Exclusion edge'), 'Yes', 'No', 'Yes');
        if(answer(1)=='Y')
            answer='No';
        else
            answer='Yes';
        end
        hold off;
        close all
    end
    
    return;
end

if(answer(1) == 'M' )
    answer = questdlg('Multiple or Microfluidic Arenas', sprintf('PID %d %s',Prefs.PID,'Multiple or Microfluidic Arenas'), 'Multiple', 'Microfluidic','Multiple');
    
    if(strcmp(answer,'Multiple'))
        Ring = multi_arena_identify(background, Ring);
    else
        if(strcmp(answer, 'Microfluidic')) % for microfluidic arena
            Ring = microfluidic_arena(summary_image, Ring);
            Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
            return;
        end
    end
else
    % Other object to define pixelsize
    Ring = get_pixelsize_from_arbitrary_object(background);
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    close all;
    pause(1);
    return;
end


close all;
pause(1);

return;
end
