function movieData = setPrefs()

% Here is where the preferences are intially set...
% Defaults are loaded from WormPlayerPreferences file

WormPlayerPrefs = WormPlayerPreferences();

movieData.Tracks = '';
movieData.TrackNum = WormPlayerPrefs.TrackNum;
movieData.FrameNum = '';
movieData.fps = WormPlayerPrefs.fps;
movieData.DisplayTrack = WormPlayerPrefs.DisplayTrack;
movieData.Movie = '';
movieData.MovieName = '';
movieData.ZoomLevel = WormPlayerPrefs.ZoomLevel;
movieData.MaxZoomLevel = WormPlayerPrefs.MaxZoomLevel;
movieData.PathBounds = [ 0 0 0 0 ];

movieData.Plot = WormPlayerPrefs.Plot;

if ( strcmp(WormPlayerPrefs.WindowGeometry, 'dynamic') )
    % screenCoverage - this is how much of your screen gets covered by the
    % player window.
    movieData.screenCoverage = WormPlayerPrefs.screenCoverage;
    
    % screenSize is the screen resolution
    movieData.screenSize = get( 0, 'ScreenSize');

    % Set player window width
    movieData.playerPosition(3) = movieData.screenSize(3) * movieData.screenCoverage;

    % Set player height
    movieData.playerPosition(4) = movieData.screenSize(4) * movieData.screenCoverage;

    % This is the left side of the player - here I bump it over by WormPlayerPrefs.XAdjust pixels to
    % allow for the window frame
    movieData.playerPosition(1) = WormPlayerPrefs.XAdjust;

    % Bottom of the player window, coordinates start at bottom of screen.  I
    % bring it down additional pixels to allow for the window frame plus
    % some added space.  WormPlayerPrefs.YAdjust will need adjusting if screenCoverage is increased.
    movieData.playerPosition(2) = movieData.screenSize(4) - movieData.playerPosition(4) - WormPlayerPrefs.YAdjust;
    
elseif ( strcmp(WormPlayerPrefs.WindowGeometry, 'static') )
    % Or just use static sizing/position
    movieData.playerPosition = WormPlayerPrefs.WindowSize;
end

return;

end

