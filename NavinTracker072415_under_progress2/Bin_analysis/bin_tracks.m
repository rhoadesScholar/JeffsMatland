function BinData = bin_tracks(Tracks, binwidth)
% BinData = bin_tracks(Tracks, binwidth)

global Prefs;
 
if(isempty(Prefs))
    Prefs = define_preferences(Prefs);
end
 
OPrefs = Prefs;
 
Prefs = define_preferences(OPrefs);
 
Prefs.SpeedEccBinSize = binwidth;
Prefs.FreqBinSize = binwidth;
 
BinData = bin_and_average_all_tracks(Tracks);
 
Prefs = OPrefs;
 
return;
end
