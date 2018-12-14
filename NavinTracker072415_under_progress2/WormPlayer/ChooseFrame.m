% --------------------------------------------------------
function ChooseFrame(hbutton, eventStruct, hfig)
% 
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');

% I thought this would stop the jitter when
% holding the forward arrow.
% Didn't work...
% if ( ud.paused == 0 )
%     return
% end

% ud.FrameSlider
% ud = get(hfig,'userdata');
H = movieData.FrameSlider; %findobj('tag', 'SLIDER');
%H = findobj('tag', 'SLIDER');
FrameNum = get(H, 'Value');
if ( iscell(FrameNum) )
    FN = round(cell2mat(FrameNum(1)));
else
    FN = round(FrameNum(1));
end
movieData.FrameNum = movieData.Tracks(movieData.TrackNum).Frames(FN);
movieData.TrackFrame = FN;
set(hfig,'userdata', movieData);
displayFrame(hfig);
    
end

% --------------------------------------------------------

