function timestamp_coords = timestamp_coords_from_image(image)

global Prefs;

timestamp_coords = [];

if(isempty(Prefs))
    timerbox_thresh = 5;
else
    if(Prefs.timerbox_flag == 0)
        return;
    end
    timerbox_thresh =  Prefs.timerbox_thresh;
end

pix = ~custom_im2bw(image, timerbox_thresh);

s = custom_regionprops(bwconncomp_sorted(pix,'descend'), {'PixelList'});

timestamp_coords(1) = s(1).PixelList(1,2);
timestamp_coords(2) = s(1).PixelList(end,2);
timestamp_coords(3) = s(1).PixelList(1,1);
timestamp_coords(4)= s(1).PixelList(end,1);

return;
end
