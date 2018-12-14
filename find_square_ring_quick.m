function Ring = find_square_ring_quick(background, summary_image)

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
 
return;%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other object to define pixelsize
Ring = get_pixelsize_from_arbitrary_object(background);
Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
close all;
pause(1);
return;


close all;
pause(1);

return;
end
