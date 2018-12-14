% adjust level to minimize the difference between false (numObjects) to real worms (NumFoundWorms)
% if there is a ring, look at the num_worm distribution, flag outliers, and
% recalc best threshold w/o them 

function [DefaultLevel, NumFoundWorms, meanWormSize, Ring] = default_worm_threshold_level(MovieName, background, procFrame, target_numworms, Ring, manual_flag, obj_penalty_coeff)

global Prefs;

persistent force_manual_flag;

if(nargin<5)
    Ring.RingX = [];
    Ring.RingY = [];
    Ring.ComparisonArrayX = [];
    Ring.ComparisonArrayY = [];
    Ring.ring_mask = [];
    Ring.Area = 0;
    Ring.Level = eps;
    Ring.PixelSize = Prefs.DefaultPixelSize;
    Ring.FrameRate = Prefs.FrameRate; % default framerate
    Ring.NumWorms = [];
    Ring.meanWormSize = [];
    Ring.DefaultThresh = [];
end

if(nargin<6)
    manual_flag=1;
    
    % already calculated the default level
    if(~isempty(Ring.NumWorms) && ~isempty(Ring.DefaultThresh) && ~isempty(Ring.meanWormSize))
        DefaultLevel = Ring.DefaultThresh;
        NumFoundWorms = Ring.NumWorms;
        meanWormSize = Ring.meanWormSize;
        return;
    end
end

if(nargin<7)
    obj_penalty_coeff = 1;
end

if(nargin<4)
    target_numworms=0;
end

if(~isempty(Ring.NumWorms) && ~isempty(Ring.DefaultThresh) && ~isempty(Ring.meanWormSize))
    if((manual_flag==0) && (target_numworms==0) && ((Ring.NumWorms >= Prefs.DefaultNumWormRange(1)) && (Ring.NumWorms <= Prefs.DefaultNumWormRange(2))))
        % already calculated the default level
        DefaultLevel = Ring.DefaultThresh;
        NumFoundWorms = Ring.NumWorms;
        meanWormSize = Ring.meanWormSize;
        return;
    end
end

FileInfo = moviefile_info(MovieName);

if(nargin<3)
    procFrame = [];
end

if(isempty(procFrame))
    for(i=1:FileInfo.NumFrames)
        procFrame(i).frame_number = i;
        procFrame(i).bkgnd_index = 1;
    end
end


if(target_numworms>0)
    disp([sprintf('adjusting local object detection level and looking for %d worms with obj penalty %d\t%s',target_numworms, obj_penalty_coeff, timeString())])
else
    disp([sprintf('adjusting local object detection level and counting worms with obj penalty %d\t%s', obj_penalty_coeff, timeString())])
end

frameinterval = 60*Prefs.FrameRate; % floor(FileInfo.NumFrames/(60*Prefs.FrameRate)); % sample every minute

startFrame = procFrame(1).frame_number;
endFrame = procFrame(end).frame_number;

if(endFrame <= frameinterval)
    frameinterval = 1;
end

frame_numbers = unique([startFrame startFrame:frameinterval:endFrame endFrame]);

fit_level = zeros(length(frame_numbers),1);
numWorms_vector = zeros(length(frame_numbers),1);
numObjects_vector = zeros(length(frame_numbers),1);
error_vector = zeros(length(frame_numbers),1);
meanWormSize_vector = zeros(length(frame_numbers),1) + (Prefs.MinWormArea + Prefs.MaxWormArea)/2;

if(isempty(background))
    background = calculate_background(MovieName, startFrame, endFrame);
end


% used for blanking ring pixels ... sometimes the ring doesn't subtract cleanly
if(~isfield(Ring,'ring_mask'))
    Ring.ring_mask = [];
end
if(~isempty(Ring.ring_mask))
    ring_mask = Ring.ring_mask; % uint8(poly2mask(Ring.RingX, Ring.RingY, size(background,1), size(background,2)));
    ring_mask = double(ring_mask);
else
    ring_mask = []; % uint8(ones(size(background,1), size(background,2)));
end
background = double(background);


Mov = aviread_to_gray(MovieName, frame_numbers(1));
timerbox_coords = timestamp_coords_from_image(Mov.cdata);



disp([sprintf('%s\t%s\t%s\t%s','Frame', 'thresh', 'numWorms', 'numObjects')]);
for(i=1:length(frame_numbers))
    Frame = frame_numbers(i);
    
    p=1;
    while(procFrame(p).frame_number ~= Frame)
        p=p+1;
    end
    
    % subtract the background from the frame and mask out the ring
    Movsubtract = background_subtracted_frame(MovieName, Frame, background, timerbox_coords);
    if(~isempty(ring_mask))
        Movsubtract = Movsubtract.*ring_mask;
    end
        
%     % black out timer pixels
%     if(Prefs.timerbox_flag == 1)
%         Movsubtract(1:ceil(FileInfo.Height*(30/1024)), 1:ceil(FileInfo.Width*(125/1024))) = 0;
%     end
        
    [fit_level(i), numWorms_vector(i), numObjects_vector(i), meanWormSize_vector(i)] = find_optimal_threshold(Movsubtract, target_numworms, [], obj_penalty_coeff);
    error_vector(i) = abs(numWorms_vector(i) - numObjects_vector(i));
    
 %   if(mod(i,10)==0 || i == 1 || i == length(frame_numbers))
        disp([sprintf('%d\t\t%.4f\t\t%d\t\t%d\t\t%s',frame_numbers(i), fit_level(i), numWorms_vector(i), numObjects_vector(i), timeString)]);
 %   end
    
% imshow(Movsubtract);
% pause

    clear('Movsubtract');
end

idx = find(numWorms_vector >= 1);

% DefaultLevel = nanmedian(fit_level(idx));
% NumFoundWorms = ceil(magnitude_weighted_mean((numWorms_vector(idx))));
% numObjects = ceil(nanmedian((numObjects_vector(idx))));
% min_err = round(nanmedian((error_vector(idx))));
% meanWormSize(1) = nanmedian(meanWormSize_vector(idx));
% meanWormSize(2) = nanstd(meanWormSize_vector(idx));

%
% June 11 2015
local_numWorms_vector = numWorms_vector; 
local_numWorms_vector(~idx) = [];
NumFoundWorms = nanmedian(local_numWorms_vector);
median_idx = find(numWorms_vector == NumFoundWorms);
DefaultLevel = nanmedian(fit_level(median_idx));
numObjects = ceil(nanmedian((numObjects_vector(median_idx))));
min_err = round(nanmedian((error_vector(median_idx))));
meanWormSize(1) = nanmedian(meanWormSize_vector(median_idx));
meanWormSize(2) = nanstd(meanWormSize_vector(median_idx));
%

num_median_worms = NumFoundWorms;
% if(target_numworms==0)
%     NumFoundWorms = NumFoundWorms + ceil(nanstd(numWorms_vector(idx)));
% end
NumFoundWorms_initial = NumFoundWorms;

if((target_numworms>0) && isempty(force_manual_flag))
    force_manual_flag=1;
else
    force_manual_flag=0;
end


disp([sprintf('Overall: %d worms\t%d objects\t%s', num_median_worms, numObjects, timeString)]);


% now do manual adjustment if necessary
if( ((manual_flag==1) && ((NumFoundWorms_initial < Prefs.DefaultNumWormRange(1)) || (NumFoundWorms_initial > Prefs.DefaultNumWormRange(2)))) || ...
        force_manual_flag==1)
    
    % Frame = 60*Prefs.FrameRate;
    
    diff_worms = abs(numWorms_vector - num_median_worms);
    Frame = find(diff_worms==0); Frame = frame_numbers(Frame(1));
    
    if(Frame > endFrame)
        Frame = floor(endFrame/2);
    end
    
    Mov = aviread_to_gray(MovieName, Frame);
    
    Movsubtract = background_subtracted_frame(MovieName, Frame, background, timerbox_coords);
    if(~isempty(ring_mask))
        Movsubtract = Movsubtract.*ring_mask;
    end
    
    
    
    [cc, NumWorms] = worm_bwconncomp(Movsubtract, find_optimal_threshold(Movsubtract, NumFoundWorms, DefaultLevel, obj_penalty_coeff));
    objects = custom_regionprops(cc, {'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength','BoundingBox'});
    
    local_numWorms_vector = ones(1,length(objects));
    for(i=1:length(objects))
        local_numWorms_vector(i) = max(1, round(objects(i).Area/meanWormSize(1)));
    end
    
    objects2 = add_delete_worms_with_mouse(Mov.cdata, objects, local_numWorms_vector); % Mov.cdata
    added_worms = (length(objects2) -  length(objects));
    target_numworms = NumWorms + added_worms;
    close(gcf);
    clear('objects');
    clear('objects2');
    
    if(added_worms~=0)
        if(abs(target_numworms - NumFoundWorms) > 10)
            obj_penalty_coeff = ~obj_penalty_coeff;
        end
        
        disp(sprintf('Looking for %d worms',target_numworms));
        [DefaultLevel, NumFoundWorms, meanWormSize] = default_worm_threshold_level(MovieName, background, procFrame, target_numworms, Ring,0, obj_penalty_coeff);
        display_found_worms_on_movieframe(Mov, Movsubtract, Ring, NumFoundWorms, obj_penalty_coeff, meanWormSize(1));
        num_worm_text = sprintf('Found %d worms on average',NumFoundWorms);
        ok_flag = questdlg(num_worm_text, sprintf('PID %d %s',Prefs.PID,num_worm_text), 'OK', 'No','OK');
        close(gcf);
        pause(0.5);
        
        if(strcmpi(ok_flag,'OK')==0)
            disp(sprintf('Looking for %d worms',target_numworms));
            [DefaultLevel, NumFoundWorms, meanWormSize] = default_worm_threshold_level(MovieName, background, procFrame, target_numworms, Ring,0, ~obj_penalty_coeff);
            display_found_worms_on_movieframe(Mov, Movsubtract, Ring, NumFoundWorms, ~obj_penalty_coeff, meanWormSize(1));
            num_worm_text = sprintf('Found %d worms on average',NumFoundWorms);
            ok_flag = questdlg(num_worm_text, sprintf('PID %d %s',Prefs.PID,num_worm_text), 'OK', 'No','OK');
            close(gcf);
            pause(0.5);
            if(strcmpi(ok_flag,'OK')==1)
                obj_penalty_coeff = ~obj_penalty_coeff;
            end
        end
        
        ctr=1;
        while(strcmpi(ok_flag,'OK')==0)
            if(target_numworms > NumFoundWorms)
                coef = (ctr*0.5+1);
            else
                coef = 1;
            end
            
            if(target_numworms - NumFoundWorms > 10)
                obj_penalty_coeff = 0;
                coef = 1;
            else
                obj_penalty_coeff = 1;
            end
            
            disp(sprintf('Looking for %d worms',round(coef*target_numworms)));
            [DefaultLevel, NumFoundWorms, meanWormSize] = default_worm_threshold_level(MovieName, background, procFrame, round(coef*target_numworms), Ring,0, obj_penalty_coeff);
            display_found_worms_on_movieframe(Mov, Movsubtract, Ring, NumFoundWorms, obj_penalty_coeff, meanWormSize(1));
            num_worm_text = sprintf('Found %d worms on average',NumFoundWorms);
            ok_flag = questdlg(num_worm_text, sprintf('PID %d %s',Prefs.PID,num_worm_text), 'OK', 'No','OK');
            
            if(strcmpi(ok_flag,'OK')==0)
                disp(sprintf('Looking for %d worms',target_numworms));
                [DefaultLevel, NumFoundWorms, meanWormSize] = default_worm_threshold_level(MovieName, background, procFrame, round(coef*target_numworms), Ring,0, ~obj_penalty_coeff);
                display_found_worms_on_movieframe(Mov, Movsubtract, Ring, NumFoundWorms, ~obj_penalty_coeff, meanWormSize(1));
                num_worm_text = sprintf('Found %d worms on average',NumFoundWorms);
                ok_flag = questdlg(num_worm_text, sprintf('PID %d %s',Prefs.PID,num_worm_text), 'OK', 'No','OK');
                close(gcf);
                pause(0.5);
                if(strcmpi(ok_flag,'OK')==1)
                    obj_penalty_coeff = ~obj_penalty_coeff;
                end
            end
            
            ctr = ctr+1;
            close(gcf); pause(0.5);
        end
    end
    clear('Mov');
    clear('Movsubtract');
    force_manual_flag = [];
end

close(gcf);

% add the worms and thresh data to Ring
Ring.DefaultThresh = [DefaultLevel obj_penalty_coeff];
if(NumFoundWorms>5)
    Ring.NumWorms = NumFoundWorms+1;
end

% if the number of worms fluctuate a lot, estimate the numWorms for each frame

% if very few worms, assume this was a weird frame ... set to be the mean
% of the two frames before and two after
idx = find(numWorms_vector <= 2);
for(f=1:length(idx))
    ff = idx(f);
    
    numWorms_vector(ff) = ceil(nanmean(numWorms_vector([(max(1,(ff-2))) (max(1,(ff-1))) ...
                                (min(length(numWorms_vector),(ff+1))) (min(length(numWorms_vector),(ff+2)))])));

    if(ff == 1)
        numWorms_vector(ff) = ceil(nanmean(numWorms_vector([(min(length(numWorms_vector),(ff+1))) (min(length(numWorms_vector),(ff+2)))])));
    end
    if(ff == length(numWorms_vector))
        numWorms_vector(ff) = ceil(nanmean(numWorms_vector([(max(1,(ff-2))) (max(1,(ff-1)))])));
    end

end
idx = find(numWorms_vector >= 1);
numWorms_vector = numWorms_vector(idx);

frame_numbers = frame_numbers(idx);
fit_level = fit_level(idx);
% spline to estimate for each frame
frame_vector = startFrame:endFrame;
Ring.NumWorm_vector(:,1) = frame_vector;
Ring.NumWorm_vector(:,2) = round(smooth(spline(frame_numbers,numWorms_vector,frame_vector))+1);
Ring.NumWorm_vector(:,3) = smooth(spline(frame_numbers,fit_level,frame_vector));

% plot(Ring.NumWorm_vector(:,1), Ring.NumWorm_vector(:,3));
% hold on
% plot(frame_numbers, fit_level, 'or');
% pause


Ring.meanWormSize = meanWormSize;

DefaultLevel = Ring.DefaultThresh;

disp([sprintf('numWorm=%d\tnumObjects=%d\tdiff=%d\tbestLevel=%f %d\t%s\n', NumFoundWorms, numObjects, min_err, DefaultLevel, obj_penalty_coeff, timeString())])
% disp(sprintf('Found %d animals with a level of %f %d\t%s',NumFoundWorms, DefaultLevel, obj_penalty_coeff, timeString()))


clear('FileInfo');
clear('fit_level');
clear('numWorms_vector');
clear('numObjects_vector');
clear('error_vector');
clear('t_i'); clear('t_j');
clear('ring_mask');

return;
end


function display_found_worms_on_movieframe(Mov, Movsubtract, Ring, NumFoundWorms, obj_penalty_coeff, mean_worm_area)

global Prefs;

[cc, NumWorms] = worm_bwconncomp(Movsubtract, find_optimal_threshold(Movsubtract, NumFoundWorms, [], obj_penalty_coeff));
STATS = custom_regionprops(cc, {'Area', 'Centroid', 'MajorAxisLength','BoundingBox'});
figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
imshow(Mov.cdata);
hold on;
if(~isempty(Ring.RingX))
    plot(Ring.RingX,Ring.RingY,'.r','markersize',1);
end

for(pp=1:length(STATS))
    if(STATS(pp).Area <= Prefs.MaxWormArea &&   STATS(pp).Area >= Prefs.MinWormArea )
        plot(STATS(pp).Centroid(:,1), STATS(pp).Centroid(:,2),'og','markersize',0.5*sqrt(STATS(pp).BoundingBox(3)^2+STATS(pp).BoundingBox(4)^2));
    else
        text(STATS(pp).Centroid(:,1), STATS(pp).Centroid(:,2),num2str(round(STATS(pp).Area/mean_worm_area)),'color','r');
    end
    hold on;
end
hold off;

return;
end
