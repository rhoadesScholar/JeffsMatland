function theta = angle_between_three_points(A, B, C)
% theta = angle_between_three_points(A, vertex, C)

% law of cosines

% distances between all points
a2 = (B(1) - C(1))^2 + (B(2) - C(2))^2;
b2 = (A(1) - C(1))^2 + (A(2) - C(2))^2; 
c2 = (B(1) - A(1))^2 + (B(2) - A(2))^2; 

% theta = angle B
theta = real((180/pi)*acos((a2 + c2 - b2)/(2*sqrt(a2*c2))));  

return;
end


% function theta = angle_between_three_points(A, vertex, C)
% % theta = angle_between_three_points(A, vertex, C)
% % angle between A, vertex, C 
% 
% a = A - vertex;
% c = C - vertex;
% 
% % theta = (180/pi)*mod(-atan2(a(1)*c(2)-a(2)*c(1), a*c'), 2*pi);
% 
% theta = real((180/pi)*acos(dot(a,c)/(vector_magnitude(a)*vector_magnitude(c))));
% 
% [dot(a,c)/(vector_magnitude(a)*vector_magnitude(c)) theta]
% 
% while(theta>180)
%     theta = 180 - rem(theta,180);
% end
% 
% return;
% end
