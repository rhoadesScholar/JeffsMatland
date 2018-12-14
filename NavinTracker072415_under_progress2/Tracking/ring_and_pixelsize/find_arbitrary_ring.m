function Ring = find_arbitrary_ring(global_background, manual_flag, model_code)
% Ring = find_arbitrary_ring(global_background)


% re-write all the ways to find a ring are used, then user picks the best
% one

global Prefs;

if(nargin==1)
    if(ischar(global_background))
        Moviename = global_background;
        clear('global_background');
        global_background = calculate_background(Moviename);
        [localpath, FilePrefix] = fileparts(Moviename);
    end
end

if(nargin<2)
    manual_flag=1;
end

if(nargin<3)
    model_code=1;
end

pixel_dim = size(global_background);

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
Ring.DefaultThresh = [];
Ring.meanWormSize = [];

% if(manual_flag==1)
%     h_im = imshow(global_background); hold on;
%     questdlg(sprintf('Draw around the region containing the inner ring.'), 'Manually select copper ring', 'OK', 'OK');
%     hh = impoly;
%     BW = createMask(hh);
%     global_background = global_background.*uint8(BW);
%     clear('BW');
%     hold off;
%     imshow(global_background);
%     close all;
% end

% the distribution of pixel intensities has two peaks ... the narrow one
% near zero is the border ring ... find the bottom of the valley and see whether
% it works as a threshold
b = double(matrix_to_vector(global_background))/255;
[y,x] = hist(b,sqrt(length(b)));
idx = find(y==0);
x(idx)=[]; y(idx)=[];
y=y./nansum(y);


% figure(1); imshow(global_background);
% figure(2); plot(x,y); hold on;

[mu1, ~, mu2, ~, ~, ~, fitted_hist_matrix] = fit_histograms_simultaneosly_two_gaussians(y);
% plot(x,fitted_hist_matrix,'r');


if(mu1<1)
    mu1 = 1;
end
if(mu2<1)
    mu2 = 1;
end
if(mu1>=length(x))
    mu1 = length(x);
end
if(mu2>=length(x))
    mu2 = length(x);
end

idx = find(x>=min([x(floor(mu1)) x(floor(mu2))]) & x<=max([x(floor(mu1)) x(floor(mu2))]));
x = x(idx);

if(model_code==1)
    y = y(idx);
else
    y = fitted_hist_matrix(idx);
end

[~,idx] = min(y); idx = idx(1);

Ring.Level = x(idx);

%     plot(x,y,'g'); plot(x(idx),y(idx),'ok'); pause


RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, Ring.Level), 'descend'), {'Area','Image','BoundingBox'});
RINGSTATS = RINGSTATS(1);

Ring.Area = RINGSTATS.Area;


B = bwboundaries(RINGSTATS.Image); %obtain boundary coordinates for selected objects and put into cell B

for k=1:length(B)
    boundary = B{k};
    boundarysize = size(boundary);
    boundary(:,2) = boundary(:,2) + RINGSTATS.BoundingBox(1)-0.5;
    boundary(:,1) = boundary(:,1) + RINGSTATS.BoundingBox(2)-0.5;
    if boundarysize(1) > 1000
        NewRingX = boundary(:,2);
        NewRingY = boundary(:,1);
        Ring.RingX = [Ring.RingX; NewRingX]; %make an array of all the x coordinates of boundaries for all selected objects
        Ring.RingY = [Ring.RingY; NewRingY];
    end
end


Ring.ComparisonArrayX = ones([length(Ring.RingX) 1]);
Ring.ComparisonArrayY = ones([length(Ring.RingY) 1]);

% get rid of the "outer" boundry
idx = find(pixel_dim(2) - Ring.RingX <=2);
Ring.RingX(idx)=[];
Ring.RingY(idx)=[];
Ring.ComparisonArrayX(idx)=[];
Ring.ComparisonArrayY(idx)=[];

idx = find(Ring.RingX<=2);
Ring.RingX(idx)=[];
Ring.RingY(idx)=[];
Ring.ComparisonArrayX(idx)=[];
Ring.ComparisonArrayY(idx)=[];

idx = find(pixel_dim(1) - Ring.RingY <=2);
Ring.RingX(idx)=[];
Ring.RingY(idx)=[];
Ring.ComparisonArrayX(idx)=[];
Ring.ComparisonArrayY(idx)=[];

idx = find(Ring.RingY<=2);
Ring.RingX(idx)=[];
Ring.RingY(idx)=[];
Ring.ComparisonArrayX(idx)=[];
Ring.ComparisonArrayY(idx)=[];

% find neighbor-free points and remove ... these are spurious noise
idx = find_neighborfree_points(Ring.RingX,Ring.RingY);
Ring.RingX(idx)=[];
Ring.RingY(idx)=[];
Ring.ComparisonArrayX(idx)=[];
Ring.ComparisonArrayY(idx)=[];

Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);

disp([sprintf('Ring area is %f mm^2 with level %f\t%s',Ring.Area*(Prefs.DefaultPixelSize)^2, Ring.Level, timeString())])

if(manual_flag==1)
    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
    imshow(global_background);
    hold on;
    plot(Ring.RingX,Ring.RingY,'.r','markersize',1);
    
    [Ring, answer] = restrict_ring_region(global_background, Ring);
    
    if(answer(1) == 'N')
        close all;
        pause(0.1);
        
        Ring = find_arbitrary_ring(global_background, 0, 2);
        figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
        imshow(global_background);
        hold on;
        plot(Ring.RingX,Ring.RingY,'.r','markersize',1);
        
        [Ring, answer] = restrict_ring_region(global_background, Ring);
        
        if(answer(1) == 'N')
            close all;
            pause(0.1);
            
            levels = empirical_ring_threshold(global_background, [Prefs.MinCopperRingArea 1e10]);
            
            if(~isempty(levels))
                stopflag=0; rr=1;
                while(stopflag==0)
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
                    Ring.DefaultThresh = [];
                    Ring.meanWormSize = [];
                    
                    Ring.Level = levels(rr);
                    
                    RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, Ring.Level), 'descend'), {'Area','Image','BoundingBox'});
                    RINGSTATS = RINGSTATS(1);
                    
                    Ring.Area = RINGSTATS.Area;
                    
                    B = bwboundaries(RINGSTATS.Image); %obtain boundary coordinates for selected objects and put into cell B
                    
                    for k=1:length(B)
                        boundary = B{k};
                        boundary(:,2) = boundary(:,2) + RINGSTATS.BoundingBox(1)-0.5;
                        boundary(:,1) = boundary(:,1) + RINGSTATS.BoundingBox(2)-0.5;
                        boundarysize = size(boundary);
                        if boundarysize(1) > 1000
                            NewRingX = boundary(:,2);
                            NewRingY = boundary(:,1);
                            Ring.RingX = [Ring.RingX; NewRingX]; %make an array of all the x coordinates of boundaries for all selected objects
                            Ring.RingY = [Ring.RingY; NewRingY];
                        end
                    end
                    
                    
                    Ring.ComparisonArrayX = ones([length(Ring.RingX) 1]);
                    Ring.ComparisonArrayY = ones([length(Ring.RingY) 1]);
                    
                    % get rid of the "outer" boundry
                    idx = find(pixel_dim(2) - Ring.RingX <=2);
                    Ring.RingX(idx)=[];
                    Ring.RingY(idx)=[];
                    Ring.ComparisonArrayX(idx)=[];
                    Ring.ComparisonArrayY(idx)=[];
                    
                    idx = find(Ring.RingX<=2);
                    Ring.RingX(idx)=[];
                    Ring.RingY(idx)=[];
                    Ring.ComparisonArrayX(idx)=[];
                    Ring.ComparisonArrayY(idx)=[];
                    
                    idx = find(pixel_dim(1) - Ring.RingY <=2);
                    Ring.RingX(idx)=[];
                    Ring.RingY(idx)=[];
                    Ring.ComparisonArrayX(idx)=[];
                    Ring.ComparisonArrayY(idx)=[];
                    
                    idx = find(Ring.RingY<=2);
                    Ring.RingX(idx)=[];
                    Ring.RingY(idx)=[];
                    Ring.ComparisonArrayX(idx)=[];
                    Ring.ComparisonArrayY(idx)=[];
                                        
                    % find neighbor-free points and remove ... these are spurious noise
                    idx = find_neighborfree_points(Ring.RingX,Ring.RingY);
                    Ring.RingX(idx)=[];
                    Ring.RingY(idx)=[];
                    Ring.ComparisonArrayX(idx)=[];
                    Ring.ComparisonArrayY(idx)=[];
                    
                    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
                    imshow(global_background);
                    hold on;
                    plot(Ring.RingX,Ring.RingY,'.r','markersize',1);
                    
                    [Ring, answer] = restrict_ring_region(global_background, Ring);
                    
                    if(answer(1) == 'Y')
                        Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
                        
                        disp([sprintf('Ring area is %f mm^2 with level %f\t%s',Ring.Area*(Prefs.DefaultPixelSize)^2, Ring.Level, timeString())])
                        
                        stopflag=1;
                    end
                    rr = rr+1;
                    if(rr>length(levels))
                        stopflag=1;
                    end
                end
            end
            figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
            imshow(global_background);
            hold on;
            plot(Ring.RingX,Ring.RingY,'.r','markersize',1);
            [Ring, answer] = restrict_ring_region(global_background, Ring);
            if(answer(1) == 'N')
                Ring = manual_arbitrary_ring(global_background);
            end
        end
    end
    
end

[Ring.RingX, Ring.RingY] = close_polygon(Ring.RingX, Ring.RingY);
Ring.ComparisonArrayX = ones([length(Ring.RingX) 1]);
Ring.ComparisonArrayY = ones([length(Ring.RingY) 1]);

if(~isempty(Ring.RingX) && ~isempty(Ring.RingY))
    if(~isnan(sum(Ring.RingX)) && ~isnan(sum(Ring.RingY)))
        Ring.ring_mask = uint8(poly2mask(Ring.RingX, Ring.RingY, size(global_background,1), size(global_background,2)));
    end
end

return;
end

function Ring = manual_arbitrary_ring(background)

global Prefs;


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
Ring.meanWormSize = [];


questdlg(sprintf('Draw the inner part of the copper ring with line segments.\nDouble-click when done to close the polygon'), sprintf('PID %d %s',Prefs.PID,'Manually select copper ring'), 'OK', 'OK');

answer(1) = 'N';
while answer(1) == 'N'
    
    [Ring.RingX, Ring.RingY] = roi_perimeter(background);
    
    hold off;
    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
    imshow(background);
    hold on;
    plot(Ring.RingX, Ring.RingY,'.g','markersize',1);
    
    Ring.ComparisonArrayX = ones([length(Ring.RingX) 1]);
    Ring.ComparisonArrayY = ones([length(Ring.RingY) 1]);
    
    answer = questdlg('Is the ring properly defined?', sprintf('PID %d %s',Prefs.PID,'Manually define copper ring'), 'Yes', 'No', 'Yes');
    
end

return;
end

function [Ring, answer] = restrict_ring_region(global_background, Ring)

global Prefs;

    x = Ring.RingX;
    y = Ring.RingY;

answer = questdlg('Is the ring properly defined?', sprintf('PID %d %s',Prefs.PID,'Manually define copper ring'), 'Yes', 'No', 'Restrict','Yes');
while(answer(1) == 'R')
    x = Ring.RingX;
    y = Ring.RingY;
    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
    imshow(global_background);
    hold on;
    plot(x,y,'.r','markersize',1);
    hold off;
    
    questdlg(sprintf('Draw around the region containing the inner ring.'), sprintf('PID %d %s',Prefs.PID,'Manually select copper ring'), 'OK', 'OK');
    
%     hh = imrect;
%     boundingbox = getPosition(hh);
%     X = [boundingbox(1) (boundingbox(1)+boundingbox(3))    (boundingbox(1)+boundingbox(3))   boundingbox(1)                   boundingbox(1)];
%     Y = [boundingbox(2) boundingbox(2)                     (boundingbox(2)+boundingbox(4))    (boundingbox(2)+boundingbox(4)) boundingbox(2)];
%         idx = find(x > max(X)); x(idx)=[]; y(idx)=[];
%     idx = find(y > max(Y)); x(idx)=[]; y(idx)=[];
%     idx = find(x < min(X)); x(idx)=[]; y(idx)=[];
%     idx = find(y < min(Y)); x(idx)=[]; y(idx)=[];
    
    hh = impoly;
    boundingbox = getPosition(hh);
    X = boundingbox(:,1); 
    Y = boundingbox(:,2); 
    
    IN = inpolygon(x,y,X,Y);
    x(~IN) = []; 
    y(~IN) = []; 
    close;
    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
    imshow(global_background);
    hold on;
    plot(x,y,'.r','markersize',1);
    hold off;
    
    answer = questdlg('Is the ring properly defined?', sprintf('PID %d %s',Prefs.PID,'Manually define copper ring'), 'Yes', 'No', 'Restrict again','Yes');
end

Ring.RingX = x;
Ring.RingY = y;

return;
end

