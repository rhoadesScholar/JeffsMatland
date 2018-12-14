function print_minimalState(Track)

if(isfield(Track,'minimalState'))
    minimalState = Track.minimalState;
else
    minimalState = make_minimalState_string(Track);
end

number_line_unit = '   .     ';
number_line=[];
nn=0;
while(length(number_line)<= length(minimalState))
    number_line = [number_line num2str(nn) number_line_unit];
    nn=nn+1;
end
number_line = number_line(1:length(minimalState));
disp([number_line])
disp([char(minimalState)])

revline = '';
for(j=1:length(Track.Reorientations))
   if(~isnan(Track.Reorientations(j).revLen))
       revline = sprintf('%s\t\t%.1f %f',revline, Track.Reorientations(j).startRev, Track.Reorientations(j).revLen);
   end
end
disp([revline])

return;
end