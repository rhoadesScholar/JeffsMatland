function im = blank_gridlines(im, blank_level, spread_factor)

s = size(im);

x_profile = -sum(im,1);
y_profile = -sum(im,2);
x_diff = abs(diff(x_profile));
y_diff = abs(diff(y_profile));

% x_lines = find(x_diff > 0.075*max(x_diff));
% y_lines = find(y_diff > 0.075*max(y_diff));

x_lines = find(x_diff > 0.2*max(x_diff));
y_lines = find(y_diff > 0.2*max(y_diff));

% plot(2:s(2), x_diff),'b'); 
% figure
% plot(2:s(1), y_diff),'r'); 

x = x_lines; 
y = y_lines; 

x=[];
for(i=1:length(x_lines))
    x = [x max(floor(x_lines(i)-spread_factor*s(2)),1):1:min(ceil(x_lines(i)+spread_factor*s(2)),s(2))];
end
y=[];
for(i=1:length(y_lines))
    y = [y max(floor(y_lines(i)-spread_factor*s(1)),1):1:min(ceil(y_lines(i)+spread_factor*s(1)),s(1))];
end

im(:,x) = blank_level;
im(y,:) = blank_level;

%figure, imshow(im); pause; close all

return;
end