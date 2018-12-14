function Ring = get_pixelsize_from_arbitrary_object(MovieName, segment_length_mm)

global Prefs;

Prefs = define_preferences(Prefs);

Ring.RingX = [];
Ring.RingY = [];
Ring.ComparisonArrayX = [];
Ring.ComparisonArrayY = [];
Ring.Area = 0;
Ring.Level = eps;
Ring.PixelSize = Prefs.DefaultPixelSize;
Ring.FrameRate = Prefs.FrameRate; % default framerate
Ring.NumWorms = [];
Ring.DefaultThresh = [];
Ring.ring_mask = [];
Ring.meanWormSize = [];



if(ischar(MovieName))
    [PathName, FilePrefix] = fileparts(MovieName);
    if(~isempty(PathName))
        PathName = sprintf('%s%s',PathName, filesep);
    else
        PathName = '';
    end
    ringfile = sprintf('%s%s.Ring.mat',PathName,FilePrefix);
    if(~does_this_file_need_making(ringfile))
        load(ringfile);
        return;
    end
    
    Mov = aviread_to_gray(MovieName,1);
    background = Mov.cdata;
    clear('Mov');
else
    background = MovieName;
end

if(nargin<2)
    segment_length_mm = 0;
end
figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
imshow(background);
hold on;

questdlg(sprintf('Pick two points defining a segment of known length'), sprintf('PID %d %s',Prefs.PID,'Manually select pixelsize segment'), 'OK', 'OK');

    answer(1) = 'N';
    while answer(1) == 'N'
        
        [x, y] = ginput2(2, '*r');
        
        hold off
        figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
        imshow(background);
        hold on;
        plot(x, y,'g');
        
        answer = questdlg('Is the pixelsize defining segment properly defined?', sprintf('PID %d %s',Prefs.PID,'Manually select pixelsize segment'), 'Yes', 'No', 'Yes');
    end
    
    if(segment_length_mm<=0)
        segment_length_txt = char(inputdlg(sprintf('What is the segment length in mm?')));
        segment_length_mm = sscanf(segment_length_txt,'%f');
    end
    
close all;
pause(1);


Ring.PixelSize = segment_length_mm/sqrt((x(2)-x(1))^2+(y(2)-y(1))^2);
Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);

disp([sprintf('Manually defined pixelsize %f mm/pixel\t%s',Ring.PixelSize, timeString())])

if(ischar(MovieName))
    save(ringfile, 'Ring');
end

return;
end
