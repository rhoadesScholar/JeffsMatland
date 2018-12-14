buffer = 30; %in seconds
buffy = 0;%120- buffer;
colors = 'krbmgcy'; 

stim = load('MultiPeak_MultiDecay_2.stim');
inds = find(stim(:,4) == 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MAKE STIM MATRIX FROM OPTO STIMS
trimStim = zeros(length(inds)/2, 5);
t = 1;
for i = 1:2:length(inds)
    trimStim(t, :) = [stim(inds(i), 1) + buffy, stim(inds(i+1), 1), stim(inds(i), 3), max(stim(inds(i):inds(i+1), 4)), stim(inds(i), 5)];    
    t = t + 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MAKE PLOT VECTORS FROM OPTO STIMS
t = 1;
for i = 1:2:length(inds)
    stimLength = length(inds(i):inds(i+1));
    x = 0:stimLength - 1;%x in seconds
    stimVec(t) = {[x'/60, stim(inds(i):inds(i+1), 4)]};
    t = t + 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PLOT VECTORS FROM OPTO STIMS
figure; hold on
c = 1;
% st = [3 8]%set to stims to include
for s = st
    thisStim = stimVec{s};
    plot(thisStim(:,1), thisStim(:,2), 'Color',colors(c));
            c = c + 1;      if c > length(colors),    c = 1;     end
end