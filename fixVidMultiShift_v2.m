function fixVidMultiShift_v2(vidFile, refFrameNum, shiftFrameNums)
    
    if ~exist('refFrameNum', 'var')
        refFrameNum = 3;
    end    
    
    try
        v = VideoReader(vidFile);
    catch
        [fn, pn]=uigetfile('*.avi','Select video file');
        vidFile = [pn fn];
        v = VideoReader(vidFile);
    end    
    
    if ~exist('shiftFrameNums', 'var')
        %find shift frames
        implay(vidFile);
        pause
        shiftFrameNums = inputdlg('Enter last frame before shift, and first frame after shift (before1#, after1#; before2#, after2#)');
        shiftFrameNums = str2double(shiftFrameNums{1});
    end
    
    refFrame = read(v, refFrameNum);
    disp('Select reference region');
    [sub_ref,rect_ref] = imcrop(refFrame);%select search region
    disp('Reference region selected');
    tic
    
    refxbegin = NaN(v.NumberOfFrames, 1);
    refxend   = NaN(v.NumberOfFrames, 1);
    refybegin = NaN(v.NumberOfFrames, 1);
    refyend   = NaN(v.NumberOfFrames, 1);

    shiftxbegin = NaN(v.NumberOfFrames, 1);
    shiftxend   = NaN(v.NumberOfFrames, 1);
    shiftybegin = NaN(v.NumberOfFrames, 1);
    shiftyend   = NaN(v.NumberOfFrames, 1);
    
%     last_rect = rect_ref + [-100 -100 200 200];
%     last_rect = last_rect + ...
%         [(last_rect(1)<=0)*(-last_rect(1)+1) ...
%         (last_rect(2)<=0)*(-last_rect(2)+1)...
%         (last_rect(1)+last_rect(3)>size(refFrame,2))*(size(refFrame,2)-(last_rect(1)+last_rect(3)))...
%         (last_rect(2)+last_rect(4)>size(refFrame,1))*(size(refFrame,1)-(last_rect(2)+last_rect(4)))];
    disp('Select search space');
    [~,last_rect] = imcrop(refFrame); %select sampling region        
    disp('Search space selected');
    for s = 1:size(shiftFrameNums,1)
        for f = shiftFrameNums(s, 1):shiftFrameNums(s, 2)
            shiftFrame = read(v, f);
            
%             c = 0;
%             failed = false;
%             while max(c(:)) < 0.56
%                 if failed
%                     last_rect = last_rect + [-200 -200 400 400];
%                 last_rect = last_rect + ...
%                     [(last_rect(1)<=0)*(-last_rect(1)+1) ...
%                     (last_rect(2)<=0)*(-last_rect(2)+1)...
%                     0 0];
%                 last_rect = last_rect + ...
%                     [0 0 ...
%                     (last_rect(1)+last_rect(3)>size(refFrame,2))*(size(refFrame,2)-(last_rect(1)+last_rect(3)))...
%                     (last_rect(2)+last_rect(4)>size(refFrame,1))*(size(refFrame,1)-(last_rect(2)+last_rect(4)))];
%                 end
                [sub_shifted,rect_shifted] = imcrop(shiftFrame, last_rect); %select sampling region        
                
                c = normxcorr2(rgb2gray(sub_shifted),rgb2gray(sub_ref));

                % offset found by correlation
    %             [~, imax] = max(abs(c(:)));
    %             [ypeak, xpeak] = ind2sub(size(c),imax(1));
                [ypeak, xpeak] = find(c==max(c(:)));
                corr_offset = [(xpeak-size(sub_shifted,2))
                                (ypeak-size(sub_shifted,1))];

    %             relative offset of position of subimages
                rect_offset = [(rect_ref(1)-rect_shifted(1))
                                (rect_ref(2)-rect_shifted(2))];

                % total offset
                offset = corr_offset + rect_offset;
                xoffset = round(offset(1));%###NOTE: originally not rounded in this step
                yoffset = round(offset(2));
% 
%                 last_rect = last_rect + [xoffset yoffset 0 0];
%                 last_rect = last_rect + ...
%                     [(last_rect(1)<=0)*(-last_rect(1)+1) ...
%                     (last_rect(2)<=0)*(-last_rect(2)+1)...
%                     0 0];
%                 last_rect = last_rect + ...
%                     [0 0 ...
%                     (last_rect(1)+last_rect(3)>size(refFrame,2))*(size(refFrame,2)-(last_rect(1)+last_rect(3)))...
%                     (last_rect(2)+last_rect(4)>size(refFrame,1))*(size(refFrame,1)-(last_rect(2)+last_rect(4)))];
%                 failed = true
%             end

            refxbegin(f) = round((xoffset)*(xoffset>0))+1;%*~(xoffset>0)
            refxend(f)   = round(size(refFrame,2) + xoffset*(xoffset<0));
            refybegin(f) = round((yoffset)*(yoffset>0))+1;%*~(yoffset>0)
            refyend(f)   = round(size(refFrame,1) + yoffset*(yoffset<0));

            shiftxbegin(f) = round(-1*(xoffset)*(xoffset<0))+1;%*~(xoffset<0)
            shiftxend(f)   = round(size(shiftFrame,2) + -1*xoffset*(xoffset>0));
            shiftybegin(f) = round(-1*(yoffset)*(yoffset<0))+1;%*~(yoffset<0)
            shiftyend(f)   = round(size(shiftFrame,1) + -1*yoffset*(yoffset>0));
            
%             show result
%             recovered_shiftFrame = uint8(zeros(size(refFrame)));
%             recovered_shiftFrame(refybegin(f):refyend(f), refxbegin(f):refxend(f),:) = ...
%                 shiftFrame(shiftybegin(f):shiftyend(f), shiftxbegin(f):shiftxend(f),:);
%             imshowpair(refFrame,recovered_shiftFrame)%CHECK RESULTS            
%             pause
        end
        if s == size(shiftFrameNums,1)
            span = v.NumberOfFrames - shiftFrameNums(s,2);
        else
            span = (shiftFrameNums(s+1,1) - 1) - shiftFrameNums(s,2);
        end
        refxbegin(f+1:f+span) = refxbegin(f);
        refxend(f+1:f+span)   = refxend(f);
        refybegin(f+1:f+span) = refybegin(f);
        refyend(f+1:f+span)   = refyend(f);

        shiftxbegin(f+1:f+span) = shiftxbegin(f);
        shiftxend(f+1:f+span)   = shiftxend(f);
        shiftybegin(f+1:f+span) = shiftybegin(f);
        shiftyend(f+1:f+span)   = shiftyend(f);
    end    
    toc
    disp('Writing corrected video')
    %get background and begin writing fixed vid
    v = VideoReader(vidFile);
    if ~exist('pn', 'var')%NOT FOOL PROOF
        pn = dir(vidFile);
        pn = [pn.folder '\'];
        newVidName = sprintf('%sshiftFixed_%s.avi', pn, vidFile);
    else
        newVidName = sprintf('%sshiftFixed_%s.avi', pn, fn);
    end
    w = VideoWriter(newVidName);
    w.FrameRate = v.FrameRate;
    open(w);
    bg = zeros(size(refFrame));
    for f = 1:shiftFrameNums(1,1)-1
        frame = readFrame(v);
        bg = bg + double(frame);
        writeVideo(w, frame);%write already good video frames
    end
    bg = uint8(round(bg/(shiftFrameNums(1,1)-1)));
%     
%     %fill shifting frames w/ background ###########CONSIDER THIS CAREFULLY
%     for i = (shiftingFrames(1) + 1) : (shiftingFrames(2) - 1)
%         readFrame(v);
%         writeVideo(w, bg);
%     end
    
    %write shift corrected frames
    while hasFrame(v)
        f = f + 1;
        frame = readFrame(v);
        recovered_shiftFrame = bg;
        recovered_shiftFrame(refybegin(f):refyend(f), refxbegin(f):refxend(f), :) = frame(shiftybegin(f):shiftyend(f), shiftxbegin(f):shiftxend(f), :);
        writeVideo(w, recovered_shiftFrame);
    end
    
    toc
end