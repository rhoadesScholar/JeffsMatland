function fixVidShift(vidFile, refFrameNum, shiftFrameNum)
    
    if isempty(refFrameNum)
        refFrameNum = 3
    end
    if isempty(shiftFrameNum)
        shiftFrameNum = Inf
    end
    
    try
        v = VideoReader(vidFile);
    catch
        [fn, pn]=uigetfile('*.avi','Select video file');
        vidFile = [pn fn];
        v = VideoReader(vidFile);
    end
    
    success = '';
    tic
    
    while ~strcmp(success, 'Yes')
        shiftFrame = read(v, shiftFrameNum);
        [sub_shifted,rect_shifted] = imcrop(shiftFrame); %select sampling region
        refFrame = read(v, refFrameNum);
        [sub_ref,rect_ref] = imcrop(refFrame);%select search region

        c = normxcorr2(rgb2gray(sub_shifted),rgb2gray(sub_ref));

        % offset found by correlation
        [~, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c),imax(1));
        corr_offset = [(xpeak-size(sub_shifted,2))
                       (ypeak-size(sub_shifted,1))];

        % relative offset of position of subimages
        rect_offset = [(rect_ref(1)-rect_shifted(1))
                       (rect_ref(2)-rect_shifted(2))];

        % total offset
        offset = corr_offset + rect_offset;
        xoffset = round(offset(1));%###NOTE: originally not rounded in this step
        yoffset = round(offset(2));
    
        
        refxbegin = round((xoffset)*(xoffset>0))+1;%*~(xoffset>0)
        refxend   = round(size(refFrame,2) + xoffset*(xoffset<0));
        refybegin = round((yoffset)*(yoffset>0))+1;%*~(yoffset>0)
        refyend   = round(size(refFrame,1) + yoffset*(yoffset<0));
        
        shiftxbegin = round(-1*(xoffset)*(xoffset<0))+1;%*~(xoffset<0)
        shiftxend   = round(size(shiftFrame,2) + -1*xoffset*(xoffset>0));
        shiftybegin = round(-1*(yoffset)*(yoffset<0))+1;%*~(yoffset<0)
        shiftyend   = round(size(shiftFrame,1) + -1*yoffset*(yoffset>0));
        
        recovered_shiftFrame = uint8(zeros(size(refFrame)));
        recovered_shiftFrame(refybegin:refyend, refxbegin:refxend,:) = shiftFrame(shiftybegin:shiftyend, shiftxbegin:shiftxend,:);
        figure, imshowpair(refFrame,recovered_shiftFrame,'blend')

        success = questdlg('Look good?', 'Successful shift correction?', 'Yes','No', 'Yes');
        if strcmp(success, 'No')
            retry = questdlg('Try again?', 'Unsuccessful shift correction', 'Yes','No', 'Yes');
            if strcmp(retry, 'Yes')
                refFrameChange = questdlg('Change reference frames?', 'Unsuccessful shift correction', 'Yes','No', 'Yes');
                if strcmp(refFrameChange, 'Yes')
                    shiftingFrames = inputdlg({'Enter last frame before shift', 'Enter first frame after shift'});
                    refFrameNum = shiftingFrames{1};
                    shiftFrameNum = shiftingFrames{2};
                end
            else
                return
            end
        end
    end
    
    %find shift frames
    implay(vidFile);
    pause
    shiftingFrames = inputdlg('Enter last frame before shift, and first frame after shift (before#, after#)');
    shiftingFrames = str2num(shiftingFrames{1});
    
    %get background and begin writing fixed vid
    v = VideoReader(vidFile);
    w = VideoWriter(sprintf('%sshiftFixed_%s.avi', pn, fn));
    w.FrameRate = v.FrameRate;
    open(w);
    bg = zeros(size(refFrame));
    for i = 1:shiftingFrames(1)
        frame = readFrame(v);
        bg = bg + double(frame);
        writeVideo(w, frame);
    end
    bg = uint8(round(bg/shiftingFrames(1)));
    
    %fill shifting frames w/ background ###########CONSIDER THIS CAREFULLY
    for i = (shiftingFrames(1) + 1) : (shiftingFrames(2) - 1)
        readFrame(v);
        writeVideo(w, bg);
    end
    
    %write shift corrected frames
    while hasFrame(v)
        frame = readFrame(v);
        recovered_shiftFrame = bg;
        recovered_shiftFrame(refybegin:refyend, refxbegin:refxend, :) = frame(shiftybegin:shiftyend, shiftxbegin:shiftxend, :);
        writeVideo(w, recovered_shiftFrame);
    end
    
    toc
end