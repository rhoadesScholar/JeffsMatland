% --------------------------------------------------------
function LimitFrames(hbutton, eventStruct, hfig)
% 
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');

MinFrame = movieData.Tracks(movieData.TrackNum).Frames(1);
MaxFrame = movieData.Tracks(movieData.TrackNum).Frames(movieData.TrackNumFrames);

BEG = movieData.FrameSelectorBeg;
BegFrameNum = str2double(get(BEG, 'string'));
if ( length(BegFrameNum) ~= 1 || BegFrameNum < MinFrame )
    BegFrameNum = MinFrame;    
end
if ( BegFrameNum > MaxFrame )
    BegFrameNum = MaxFrame;
end
        
    
END = movieData.FrameSelectorEnd;
EndFrameNum = str2double(get(END, 'string'));
if ( length(EndFrameNum)~= 1 || EndFrameNum > MaxFrame )
    EndFrameNum = MaxFrame;
end
if ( EndFrameNum < MinFrame )
	EndFrameNum = MinFrame;
end

if ( BegFrameNum > EndFrameNum )
    Temp = EndFrameNum;
    EndFrameNum = BegFrameNum;
    BegFrameNum = Temp;
end

set(BEG, 'string', BegFrameNum, 'enable', 'on');
set(END, 'string', EndFrameNum, 'enable', 'on');

STR = movieData.FullTrackFramesText;
set(STR, 'string', ['Full track frames: ' num2str(MinFrame) ':' num2str(MaxFrame)]);

% Create new track from existing track, place at end of tracks array and
% load it
movieData.OrigTrackNum = movieData.TrackNum;
newTrackNum = length(movieData.Tracks) + 1;
movieData.Tracks = [movieData.Tracks extract_track_segment(movieData.Tracks(movieData.TrackNum), BegFrameNum, EndFrameNum,'frames')];
movieData.TrackNum = newTrackNum;
movieData.TempTrack = newTrackNum;

H = movieData.FrameSelectorReset;
set(H, 'enable', 'on');

H = movieData.FrameSelectorText;
set(H, 'enable', 'off');

set(hfig,'userdata', movieData);
loadTrack(hfig);

% WormPlayer(extract_track_segment(movieData.Tracks(movieData.TrackNum), BegFrameNum, EndFrameNum,'frames'));

% movieData.Tracks(movieData.TrackNum);
% extract_track_segment(movieData.Tracks(movieData.TrackNum), BegFrameNum, EndFrameNum,'frames');
end

% --------------------------------------------------------

