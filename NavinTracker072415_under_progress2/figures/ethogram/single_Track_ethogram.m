function single_Track_ethogram(Track, startframe, endframe)

% round the State to the lowest integer (this info is not saved)
% used coloring  rev and omega  the same regardless of whether they are
% stand-alone or in a revOmega, etc

xmin = Track.Frames(1); 
xmax = Track.Frames(end);

if(nargin>1)
    Track = extract_track_segment(Track, find(Track.Frames == startframe), find(Track.Frames == endframe));
end

pause_state = find_Track_to_matrix(Track,'State','==num_state_convert(''pause'')' );
pause_state = matrix_replace(pause_state,'==',1,2); % light gray

fwd_state = find_Track_to_matrix(Track,'State','==num_state_convert(''fwd'')' );
fwd_state = matrix_replace(fwd_state,'==',1,10); % gray

Track.State = floor(Track.State);
Track.mvt_init = floor(Track.mvt_init);

ring_state = find_Track_to_matrix(Track,'State','==num_state_convert(''ring'')' );
ring_state = matrix_replace(ring_state,'==',1,38); % green

omega_state = find_Track_to_matrix(Track,'State','==num_state_convert(''omega'')');
omega_state = matrix_replace(omega_state,'==',1,34); % red

upsilon_state = find_Track_to_matrix(Track,'State','==num_state_convert(''upsilon'')');
upsilon_state = matrix_replace(upsilon_state,'==',1,35); % magenta

lrev_state =  find_Track_to_matrix(Track,'State','==num_state_convert(''lRev'')');
lrev_state = matrix_replace(lrev_state,'==',1,36); % blue

srev_state =  find_Track_to_matrix(Track,'State','==num_state_convert(''sRev'')');
srev_state = matrix_replace(srev_state,'==',1,37); % cyan


big_matrix =    lrev_state + srev_state +  omega_state  + upsilon_state + fwd_state  + ring_state + pause_state;

big_matrix = round(big_matrix);
big_matrix = matrix_replace(big_matrix,'==',0,1);

% big_matrix = big_matrix(ymin:ymax,:);
% convert to truecolor to avoid clashes with other subplots
colmap = ethogram_colormap;
for(j=1:length(big_matrix(1,:)))
    cm(1,j,:) = colmap(big_matrix(1,j),:);
end
image(cm);

box('off');
set(gca,'ytick',[]);

xlim([xmin xmax]);

clear('cm');
clear('cmap');
clear('fwd_state');
clear('pause_state');
clear('ring_state');
clear('omega_state');
clear('upsilon_state');
clear('lrev_state');
clear('srev_state');
clear('big_matrix');

return;
end
