function [speedN2, speedCX, speedresc] = getSpeeds(allFinalTracks)
    
speedN2 = [];
for(i=1:length(allFinalTracks.N2))
speedN2 = [speedN2 allFinalTracks.N2(i).Speed];
end

speedCX = [];
for(i=1:length(allFinalTracks.CX16814))
speedCX = [speedCX allFinalTracks.CX16814(i).Speed];
end

speedresc = [];
for(i=1:length(allFinalTracks.del3del7rescue3C))
speedresc = [speedresc allFinalTracks.del3del7rescue3C(i).Speed];
end