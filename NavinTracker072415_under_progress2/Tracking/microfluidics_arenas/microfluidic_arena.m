function Ring = microfluidic_arena(summary_image, Ring)

global Prefs;
Prefs.FrameRate = Prefs.DefaultMicrofluidicsFrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

img_size = size(summary_image);


% get scale info
are_we_done_answer(1) = 'N';
row_sum = sum(summary_image,2)';
norm_row_sum = (row_sum-nanmean(row_sum))/nanmean(row_sum);
while(are_we_done_answer(1) == 'N')
    close all;
    
    figure(1); plot(1:img_size(1),norm_row_sum); hold on;
    txt = ['pick minima that define arena edges'];
    title(txt);
    for(i=1:4)
        [x(i), y] = ginput(1);
        plot(x(i), y, '.r');
    end
    hold off;
    pix(1) = x(2)-x(1);
    pix(2) = x(4)-x(3);
    
    figure(2);
    imshow(summary_image);
    hold on
    for(k=1:4)
        plot(1:size(summary_image,2),zeros(1,size(summary_image,2))+x(k),'r');
    end
    
    are_we_done_answer = questdlg('Arena upper/lower edges defined properly?', 'Arena upper/lower edges defined properly?', 'Yes', 'No', 'Yes');
    
end
close all;
Ring.PixelSize = Prefs.quad_microfluidics_arena_sidelength/nanmean(pix);


are_we_done_answer(1) = 'N';
col_sum = sum(summary_image,1)';
norm_col_sum = (col_sum-nanmean(col_sum))/nanmean(col_sum);
while(are_we_done_answer(1) == 'N')
    close all;
    
    figure(1); plot(1:img_size(2),norm_col_sum); hold on;
    txt = ['pick minima that define arena edges'];
    title(txt);
    for(i=1:4)
        [y(i), z] = ginput(1);
        plot(y(i), z, '.r');
    end
    hold off;
    
    figure(2);
    imshow(summary_image);
    hold on
    for(k=1:4)
        plot(zeros(1,size(summary_image,2))+y(k),1:size(summary_image,1),'r');
    end
    
    are_we_done_answer = questdlg('Arena right/left edges defined properly?', 'Arena right/left edges defined properly?', 'Yes', 'No', 'Yes');
    
end
close all;
for(k=1:4)
    summary_image(round(x(k))-1, 1:size(summary_image,2)) = 255;
    summary_image(round(x(k)), 1:size(summary_image,2)) = 255;
    summary_image(round(x(k))+1, 1:size(summary_image,2)) = 255;
    
    summary_image(1:size(summary_image,1), round(y(k))-1) = 255;
    summary_image(1:size(summary_image,1), round(y(k))) = 255;
    summary_image(1:size(summary_image,1), round(y(k))+1) = 255;
end


Ring = multi_arena_identify(summary_image, Ring);

Prefs = CalcPixelSizeDependencies(Prefs, Ring.PixelSize);
Ring.ComparisonArrayX = [];
Ring.ComparisonArrayY = [];
Ring.Area = 0;
Ring.FrameRate = Prefs.FrameRate;

return;
end


% row_sum = sum(summ_img,1);
% col_sum =  sum(summ_img,2);
% dim1= (row_sum-nanmean(row_sum))/nanmean(row_sum);
% dim2 = (col_sum -nanmean(col_sum))/nanmean(col_sum);
% s=10; peak = fpeak(1:1200,dim2, s); figure(3); plot(1:1200, dim2); hold on; plot(peak(:,1), peak(:,2),'.r');
% [sorted_pk, idx] = sort(peak(:,2));
% figure(2); plot(1:1200, dim1)
% figure(3); plot(1:1200, dim2)
%
% peak = fpeak(1:1200,dim1,1); % find peaks/troughs
%
% diff_peak = diff(peak(:,2)); % differences between consequetive peaks/troughs
% pos_idx = find(diff_peak>0 & diff_peak>0.02); % large differences between conseq peaks/troughs
% time_body_bend = peak(pos_idx,1);
% plot(peak(:,1), peak(:,2),'.r');
