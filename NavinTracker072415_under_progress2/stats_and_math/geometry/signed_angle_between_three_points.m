function theta = signed_angle_between_three_points(A, vertex, C)
% theta = signed angle_between_three_points(A, vertex, C)
% angle between A, vertex, C 

a = vertex - A;
c = C - vertex;

theta = real((180/pi)*acos(dot(a,c)/(vector_magnitude(a)*vector_magnitude(c))));

return;
end
