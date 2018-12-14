% returns 0deg = east orientation system to 0deg = north 
function theta = corrected_orientation(phi)

theta = 90-phi;

theta = corrected_bearing(theta);

return;
end
