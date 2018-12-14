function im_out = trim_empty_regions(im)


% trim the edges of the frame 
% get the intensity profile for each dimension
x_profile = -sum(im,1);
y_profile = -sum(im,2);

x_pk = peakdet(x_profile, 10000);
y_pk = peakdet(y_profile, 10000);

if(x_pk(1,1)<0.1*size(im,1))
    x_pk(1,:)=[];
end
if(y_pk(1,1)<0.1*size(im,2))
    y_pk(1,:)=[];
end

if(x_pk(end,1)>0.9*size(im,1))
    x_pk(end,:)=[];
end
if(y_pk(end,1)>0.9*size(im,2))
    y_pk(end,:)=[];
end

s = size(im);
x_start = x_pk(1,1); x_end = x_pk(end,1);
y_start= y_pk(1,1); y_end = y_pk(end,1);

% plot(1:s(2), x_profile,'b'); hold on; plot(x_pk(:,1), x_pk(:,2),'og'); 
% plot(1:s(1), y_profile,'r'); hold on; plot(y_pk(:,1), y_pk(:,2),'og'); 
% figure
% plot(2:s(2), abs(diff(x_profile)),'b'); 
% figure
% plot(2:s(1), abs(diff(y_profile)),'r'); 
% pause; close all

clear('x_profile');
clear('y_profile');
clear('y_pk');
clear('x_pk');

% trim the frame
im_out = im(y_start:y_end, x_start:x_end);

return;
end