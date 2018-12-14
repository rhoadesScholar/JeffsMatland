% --------------------------------------------------------
function ChooseTrack(hbutton, eventStruct, hfig)
% 
if nargin<3, hfig  = gcbf; end

movieData = get(hfig,'userdata');

H = movieData.TrackSlider;
TrackNum = get(H, 'Value');
if ( iscell(TrackNum) )
    TrackNum = round(cell2mat(TrackNum(1)));
else
    TrackNum = round(TrackNum(1));
end

movieData.TrackNum = TrackNum;

set(hfig,'userdata', movieData);

loadTrack(hfig);

end

% --------------------------------------------------------

