function border = findBorder(bkgnd)

[H,theta,rho] = hough(edge(bkgnd,'Canny'));
P = houghpeaks(H,100,'threshold',ceil(0.1*max(H(:))), 'NHoodSize',[1 1]);
lines = houghlines(edge(bkgnd,'Canny'),theta,rho,P,'FillGap',1,'MinLength',10);

figure, imshow(bkgnd), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');

return
end