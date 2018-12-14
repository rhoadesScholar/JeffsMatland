function linkedTracks = aggresive_track_linkage(Tracks)

global Prefs;

OPrefs = Prefs;

Prefs = [];
Prefs = define_preferences(Prefs);
Prefs.PixelSize = Tracks(1).PixelSize;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);


%Prefs.aggressive_linking = 0;
%linkedTracks = link_tracks(Tracks);


%  %linkage w/o regard for direction
 Prefs.aggressive_linking = 0;
 linkedTracks = link_tracks(Tracks, 1, 0, 1, 'missing');
% Prefs.aggressive_linking = 1;
% linkedTracks = link_tracks(linkedTracks, 1, 0, 1, 'interpolate');
% Prefs.aggressive_linking = 2;
% linkedTracks = link_tracks(linkedTracks, 1, 0, 1, 'interpolate');
% 
%  %linkage w/o regard for direction or distance
% Prefs.aggressive_linking = 0;
% linkedTracks = link_tracks(linkedTracks, 1, 0, 0, 'interpolate');
% Prefs.aggressive_linking = 1;
% linkedTracks = link_tracks(linkedTracks, 1, 0, 0, 'interpolate');
% Prefs.aggressive_linking = 2;
% linkedTracks = link_tracks(linkedTracks, 1, 0, 0, 'interpolate');

Prefs = OPrefs;

return;
end
