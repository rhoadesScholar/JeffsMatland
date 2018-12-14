function Ring = find_ring(global_background, localpath, FilePrefix, manualflag, quick)
% Ring = find_ring(global_background, localpath, FilePrefix, manualflag, thresh)

global Prefs;

if(nargin==1)
    if(ischar(global_background))
        if(isempty(global_background))
            Ring = [];
            return;
        end
        Moviename = global_background;
        [localpath, FilePrefix] = fileparts(Moviename);
        if(~isempty(localpath))
            locPath = sprintf('%s%s',localpath,filesep);
        end
        if ~(file_existence(sprintf('%s%s.Ring.mat',locPath, FilePrefix)))
            clear('global_background');
            global_background = calculate_background(Moviename);
        end
    end
end

if(nargin<4)
    manualflag=1;
end

if(~isempty(localpath))
    localpath = sprintf('%s%s',localpath,filesep);
end

ringfile = sprintf('%s%s.Ring.mat',localpath, FilePrefix);

if(file_existence(ringfile))
    load(ringfile);
    if(isfield(Ring,'FrameRate'))
        Prefs.FrameRate = Ring.FrameRate;
    end
    if(~isfield(Ring,'FrameRate'))
        Ring.FrameRate = Prefs.FrameRate;
    end
    if(~isfield(Ring,'NumWorms'))
        Ring.NumWorms = [];
    end
    if(~isfield(Ring,'ring_mask'))
        Ring.ring_mask = [];
    end
    if(~isfield(Ring,'DefaultThresh'))
        Ring.DefaultThresh = [];
    end
    if(~isfield(Ring,'meanWormSize'))
        Ring.meanWormSize = [];
    end
    
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    %disp([sprintf('Loaded ring of area %f mm^2 with level %f and pixelsize %f from %s\t%s',Ring.Area*(Prefs.DefaultPixelSize)^2, Ring.Level, Ring.PixelSize, ringfile, timeString())]);
    return;
end

pixel_dim = size(global_background);

if(pixel_dim(1)~=512)
    if(are_these_equal(8/136.5, Prefs.DefaultPixelSize))
        Prefs.DefaultPixelSize = Prefs.DefaultPixelSize*512/pixel_dim(1);
    end
end

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


if(strcmp(Prefs.Ringtype,'holepunch'))
    circle_ring = find_drawn_lawn_edge(global_background);
    [Ring.PixelSize,r,xc,yc] = calc_pixelsize_from_lawn_edge(circle_ring, Prefs.holepunch_diameter);
    Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
    imshow(global_background);
    hold on;
    plot(circle_ring(:,2), circle_ring(:,1), 'r');
    [x,y] = coords_from_circle_params(r, [xc,yc]);
    plot(y,x,'g');
    dummystring = fix_title_string(sprintf('%f pixel/mm',1/Ring.PixelSize));
    title(dummystring);
    save_pdf(1,sprintf('%s%s.holepunch.pdf',localpath, FilePrefix));
    close;
    pause(0.5);
    Ring.RingX = circle_ring(:,1); Ring.RingY = circle_ring(:,2); 
    save(ringfile,'Ring');
    return;
else if(isempty(strfind(Prefs.Ringtype,'square')))
        Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
        return;
    end
end


% the distribution of pixel intensities has two peaks ... the narrow one
% near zero is the border ring ... find the bottom of the valley and see whether
% it works as a threshold
b = double(matrix_to_vector(global_background))/255; % convert to grayscale between 0 and 1
[y,x] = hist(b,sqrt(length(b)));
idx = find(y==0);
x(idx)=[]; y(idx)=[];
y=y./nansum(y);

% consider two models for the distribution ... min of actual valley between
% the distributions or the min of the fitted valley
[mu1, ~, mu2, ~, ~, ~, fitted_hist_matrix] = fit_histograms_simultaneosly_two_gaussians(y);
if(mu1<1)
    mu1=1;
end
if(mu2<1)
    mu2=1;
end
if(mu1>length(y))
    mu1=length(y);
end
if(mu2>length(y))
    mu2=length(y);
end

% figure(1); imshow(global_background);
% figure(2); plot(x,y); hold on; plot(x,fitted_hist_matrix,'r');
% pause(1)


idx = find(x>=min([x(floor(mu1)) x(floor(mu2))]) & x<=max([x(floor(mu1)) x(floor(mu2))]));
x = x(idx);
y1 = y(idx);
y2 = fitted_hist_matrix(idx);

% which one best fits a square?
level = empirical_ring_threshold(global_background);

[~,idx] = min(y1); idx = idx(1); 
level = [level x(idx)]; 

[~,idx] = min(y2); idx = idx(1);
level = [level x(idx)]; 

level = [level graythresh(global_background)];

level(level<0.05)=[];

for(i=1:length(level))
    RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, level(i)), 'descend'), {'Area','Image'});
    [score(i), rng(i)] = score_potential_ring(RINGSTATS, pixel_dim);
end

idx = find(score<1e6);

Ring.PixelSize = NaN;
[~,idx] = min(score); 
Ring = rng(idx);
Ring.Level = level(idx);


clear('RINGSTATS'); clear('rng'); clear('score');

if(isnan(Ring.PixelSize))
    disp([sprintf('Cannot find square ring\t%s',timeString())])
    Ring = cant_find_square_ring(global_background, localpath, FilePrefix, manualflag, quick);
    disp([sprintf('Use PixelSize of %f',Ring.PixelSize)]);
    return;
end

Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);

disp([sprintf('Ring area is %f mm^2 with level %f and pixelsize %f\t%s',Ring.Area*(Prefs.DefaultPixelSize)^2, Ring.Level, Ring.PixelSize,timeString())])

Ring.ring_mask = uint8(poly2mask(Ring.RingX, Ring.RingY, size(global_background,1), size(global_background,2)));

if(isempty(strfind(Prefs.Ringtype,'square')))
    save(ringfile,'Ring');%%
else
    if(manualflag==1)
        save(ringfile,'Ring');
    else
        if(manualflag==0 && ~isempty(Ring.RingX))
            save(ringfile,'Ring');
        end
    end
end

return;
end

function Ring = cant_find_square_ring(background, localpath, FilePrefix, manualflag, quick)

global Prefs;

ringfile = sprintf('%s%s.Ring.mat',localpath, FilePrefix);

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

if(~isempty(strfind(Prefs.Ringtype,'square')))
    if(manualflag==1)
        moviename = sprintf('%s%s.avi',localpath,FilePrefix);
        summary_image = background; % calculate_summary_image(moviename);
        if (quick == 1)
            Ring = find_square_ring_quick(background, summary_image);%%%
        else
            Ring = find_square_ring_manually(background, summary_image);
        end
        save(ringfile,'Ring');
    end
else
    if(strcmp(Prefs.Ringtype,'holepunch'))
        circle_ring = find_drawn_lawn_edge(background);
        [Ring.PixelSize,r,xc,yc] = calc_pixelsize_from_lawn_edge(circle_ring, Prefs.holepunch_diameter);
        Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
        figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
        imshow(background);
        hold on;
        plot(circle_ring(:,2), circle_ring(:,1), 'r');
        [x,y] = coords_from_circle_params(r, [xc,yc]);
        plot(y,x,'g');
        dummystring = fix_title_string(sprintf('%f pixel/mm',1/Ring.PixelSize));
        title(dummystring);
        save_pdf(1,sprintf('%s%s.holepunch.pdf',localpath, FilePrefix));
        close;
        pause(0.5);
    else
        Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
    end
    save(ringfile,'Ring');
end

return;
end

function [score, Ring] = score_potential_ring(RINGSTATS, pixel_dim)

global Prefs;

score = 1e10;
Ring.RingX = [];
Ring.RingY = [];
Ring.ComparisonArrayX = [];
Ring.ComparisonArrayY = [];
Ring.ring_mask = [];
Ring.Area = 0;
Ring.Level = eps;
Ring.PixelSize = NaN;
Ring.FrameRate = Prefs.FrameRate; % default framerate
Ring.NumWorms = [];
Ring.DefaultThresh = [];
Ring.meanWormSize = [];

MinCopperRingArea = Prefs.MinCopperRingArea/(Prefs.DefaultPixelSize)^2;
MaxCopperRingArea = Prefs.MaxCopperRingArea/(Prefs.DefaultPixelSize)^2;

ring_index = 1;

if(length(RINGSTATS)>1)
    ring_index = find([RINGSTATS.Area] >= MinCopperRingArea & [RINGSTATS.Area] <= MaxCopperRingArea);
    if(length(ring_index)~=1)
        return;
    end
end

if(RINGSTATS(ring_index).Area > MaxCopperRingArea)
    return;
end

B = bwboundaries(RINGSTATS(ring_index).Image); %obtain boundary coordinates for selected objects and put into cell B

for k=1:length(B)
    boundary = B{k};
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

Ring.PixelSize = NaN;

if(~isempty(Ring.RingX) && ~isempty(Ring.RingY))
    [Ring.PixelSize, score] = calc_pixelsize_from_square_ring(Ring, Prefs.RingSideLength, max(pixel_dim));
end

if(isnan(Ring.PixelSize))
    score = 1e10;
    return;
end

Ring.ring_mask = uint8(poly2mask(Ring.RingX, Ring.RingY, pixel_dim(1), pixel_dim(2)));
Ring.Area = RINGSTATS(ring_index).Area;

return;
end
