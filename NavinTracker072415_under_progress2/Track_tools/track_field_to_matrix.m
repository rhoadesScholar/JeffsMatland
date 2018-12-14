function x = track_field_to_matrix(Tracks, field, nan_replacement)
% x = track_field_to_matrix(Tracks, field, nan_replacement)
% returns a matrix length(Tracks)-by-max(length(Tracks.field)) filled w/
% the value of the field
% NaN for missing values replaced by nan_replacement

x=[];
if(~isfield(Tracks,field))
    return;
end

x = zeros(length(Tracks), max_struct_array(Tracks,'Frames'),'single') + NaN;

for(i=1:length(Tracks))
    x(i,Tracks(i).Frames(1):Tracks(i).Frames(end)) = Tracks(i).(field);
end

if(nargin==3)
    x = matrix_replace(x,'==',NaN,nan_replacement);
end

return;
end
