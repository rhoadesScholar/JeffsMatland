function WormPlayerPrefs = WormPlayerPreferences() 
% WormPlayerPreferences
% This file contains the default parameters for WormPlayer 
%

% Which track to start on
WormPlayerPrefs.TrackNum = 1;

% Frames per second
WormPlayerPrefs.fps = 3;

% Zoom levels.  Possible values are:
% 0 - off (no zoom)
% 1 - zoomed to track
% 2 - zoomed to 50% of window
% 3 - zoomed to 25% of window
% 4 - zoomed to 10% of window
% 5 - zoomed to worm's bounding box
WormPlayerPrefs.ZoomLevel = 0;
% Do you want to zoom only to 50%?  Then set this to 2, etc...
WormPlayerPrefs.MaxZoomLevel = 6;

% Display line indicating track
WormPlayerPrefs.DisplayTrack = 'on';

% The following four variables determine initial window size and placement.
% The fifth variable (WindowGeometry) determines which value to use...dynamic uses
% screenCoverage.  static uses WindowSize

% screenCoverage is the amount of screen real estate taken up by WormPlayer
% when started.  
% XAdjust bumps the window over to the right by the specified number of
% pixels  - this compensates for the window frame.
% YAdjust is the same except it operates in the Y direction, bumping the
% window downward.
WormPlayerPrefs.screenCoverage = 3/4; % 2/3
WormPlayerPrefs.XAdjust = 10;
WormPlayerPrefs.YAdjust = 100;

% Fields are X value, Y value, width, height.
% X,Y = (1,1) is the lower-left corner of the screen.
WormPlayerPrefs.WindowSize = [0.1 0.1 0.8 0.8]; % [ 1 1 300 300 ];

% Values are 'dynamic' and 'static'
WormPlayerPrefs.WindowGeometry = 'static';

x_axis_unit = 'Frames';

% Plot parameters
p=1;
WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
WormPlayerPrefs.Plot(p).ydata = 'Speed';
WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
WormPlayerPrefs.Plot(p).ylim = [0 0.25];
WormPlayerPrefs.Plot(p).plotstyle = 'k';
WormPlayerPrefs.Plot(p).frameindicator = 'g';

p=2;
WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
WormPlayerPrefs.Plot(p).ydata = 'Eccentricity';
WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
WormPlayerPrefs.Plot(p).ylim = [0.85 0.975]; % if [], set automatically
WormPlayerPrefs.Plot(p).plotstyle = 'k'; % green line '.g' green dots, etc
WormPlayerPrefs.Plot(p).frameindicator = 'k'; % Color of line indicating current frame

p=3;
WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
WormPlayerPrefs.Plot(p).ydata = 'AngSpeed';
WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
WormPlayerPrefs.Plot(p).ylim = [-180 180];
WormPlayerPrefs.Plot(p).plotstyle = 'm';
WormPlayerPrefs.Plot(p).frameindicator = 'k';

p=4;
WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
WormPlayerPrefs.Plot(p).ydata = 'Direction';
WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
WormPlayerPrefs.Plot(p).ylim = []; % [0 0.25]; % if [], set automatically
WormPlayerPrefs.Plot(p).plotstyle = 'b'; % blue line '.g' green dots, etc
WormPlayerPrefs.Plot(p).frameindicator = 'k'; % Color of line indicating current frame

p=5;
WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
WormPlayerPrefs.Plot(p).ydata = 'Curvature';
WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
WormPlayerPrefs.Plot(p).ylim = []; % [-180 180];
WormPlayerPrefs.Plot(p).plotstyle = 'g';
WormPlayerPrefs.Plot(p).frameindicator = 'r';

% p=6;
% WormPlayerPrefs.Plot(p).xdata = x_axis_unit;
% WormPlayerPrefs.Plot(p).ydata = 'body_angle';
% WormPlayerPrefs.Plot(p).xlabel = WormPlayerPrefs.Plot(p).xdata;
% WormPlayerPrefs.Plot(p).ylabel = WormPlayerPrefs.Plot(p).ydata;
% WormPlayerPrefs.Plot(p).ylim = [90 180]; % if [], set automatically
% WormPlayerPrefs.Plot(p).plotstyle = 'b'; % blue line '.g' green dots, etc
% WormPlayerPrefs.Plot(p).frameindicator = 'k'; % Color of line indicating current frame

return;
end
