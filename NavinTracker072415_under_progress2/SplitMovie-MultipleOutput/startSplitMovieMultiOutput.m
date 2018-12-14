function startSplitMovieMultiOutput()

% MovieNameWithPath = 'C:\Users\snyderb\devel\bargmann\Steve\20120405\102111_2_n2_1.avi';
% TrackFileName = 'C:\Users\snyderb\devel\bargmann\Steve\20120405\102111_2_n2_1.finalTracks.mat';
% MovieNameWithPath = 'C:\Users\snyderb\devel\bargmann\Steve\20120116\032610_2_n2_1.avi';
% TrackFileName = 'C:\Users\snyderb\devel\bargmann\Steve\20120116\032610_2_n2_1.finalTracks.mat';
%MovieNameWithPath = 'C:\Users\snyderb\devel\bargmann\Steve\20120302\032610_2_n2_1.orig2.avi';
%TrackFileName = 'C:\Users\snyderb\devel\bargmann\Steve\20120302\032610_2_n2_1.finalTracks.mat';

%startSplitMovie
if (~exist('TrackFileName', 'var'))
    [FileName,PathName] = uigetfile('*.mat', 'Choose a track file');
    TrackFileName = [ PathName FileName ];
end

if (~exist('MovieNameWithPath', 'var'))
    [FileName,PathName] = uigetfile('*.avi', 'Choose a movie file');
    MovieNameWithPath = [ PathName FileName ];
end

% You can specify which track to split out:
splitMovieMultiOutput(TrackFileName, MovieNameWithPath, 4)
% Or say 'all' and it will split everything.
% splitMovie(TrackFileName, MovieNameWithPath, 'all')

end