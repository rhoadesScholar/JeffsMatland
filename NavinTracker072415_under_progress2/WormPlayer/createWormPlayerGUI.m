function hfig = createWormPlayerGUI

movieData = setPrefs();

hfig = figure(...
    'CloseRequestFcn',@closeWormPlayer, ...
    'DeleteFcn',@closeWormPlayer);

set(hfig,'units','normalized'); 
set(hfig,'Position', movieData.playerPosition);

set(hfig,'userdata', movieData);

createToolbar(hfig);

pos1 = [50 0 100 20];
pos2 = [150 0 200 20];
AddFrameSlider(hfig, pos1, pos2);

pos2(1) = pos2(1) + 210;
AddStimulusText(hfig, pos2);

pos2(1) = pos2(1) - 210;
pos1(2) = pos1(2) + 20;
pos2(2) = pos2(2) + 20;
AddTrackSlider(hfig, pos1, pos2);

limitPos = pos1;
limitPos(1) = 360;
limitPos(3) = 50;
% pos2(1) = pos1(1) + 55;
% pos2(3) = 50;
% pos3 = pos2;
% pos3(1) = pos3(1) + 55;
% pos3(3) = pos3(3) + 50;
% pos4 = pos3;
% pos4(1) = pos4(1) + 100;
LimitFrameSelector(hfig, limitPos);%, pos2, pos3, pos4);

AddTimer(hfig);

return;

end

