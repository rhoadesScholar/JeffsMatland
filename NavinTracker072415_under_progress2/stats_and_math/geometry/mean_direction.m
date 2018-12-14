function theta = mean_direction(direction_array)
% theta = mean_direction(direction_array)
% converts direction_array of directions (in degrees) to the mean
% uses trig functions to deal w/ the rotation problem

theta = NaN;

direction_array(isnan(direction_array)) = [];

if(~isempty(direction_array))
    theta =  circ_rad2ang( circ_mean( circ_ang2rad(direction_array) ) ); 
end

return;
end
