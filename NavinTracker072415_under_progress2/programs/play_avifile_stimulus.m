function play_avifile_stimulus(original_file, stimfile, FrameRate)
% play_avifile_stimulus(original_file, stimfile)


if(nargin<1)
    disp('play_avifile_stimulus(original_file, <stimfile>)')
    return
end

if(nargin<2)
    stimfile = '';
end

if(nargin<3)
    FrameRate = 3;
end

if(~isempty(stimfile))
    stimulus = load_stimfile(stimfile);
end

% convert times to Frames
stimulus(:,1) = FrameRate*stimulus(:,1);
stimulus(:,2) = FrameRate*stimulus(:,2);

FileInfo = moviefile_info(original_file);

text_location = [ round((1/2)*FileInfo.Width) (19/20)*FileInfo.Height ];


stim_idx = 1;
for(i=1:FileInfo.NumFrames)
    Mov = aviread_to_gray(original_file, i,0);
    
    figure(1);
    imshow(Mov.cdata,'Border','tight');
    
    if(i>stimulus(stim_idx,2))
        stim_idx = stim_idx+1;
    end
    
    hold on;
    if(i>=stimulus(stim_idx,1) && i<=stimulus(stim_idx,2))
        
        if(stimulus(stim_idx,4) < 100)
            text(text_location(1), text_location(2), fix_title_string(sprintf('%.2f  ON %.2f mW  ',i/FrameRate, stimulus(stim_idx,4))),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
        else
            if(stimulus(stim_idx,4) == 101)
                text(text_location(1), text_location(2), fix_title_string(sprintf('%.2f  histamine ON  ',i/FrameRate)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
            end
            if(stimulus(stim_idx,4) == 102)
                text(text_location(1), text_location(2), fix_title_string(sprintf('%.2f  capsaicin ON  ',i/FrameRate)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
            end
            if(stimulus(stim_idx,4) >= 200)
                text(text_location(1), text_location(2), fix_title_string(sprintf('%.2f  odor ON  ',i/FrameRate)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
            end
        end
    else
        text(text_location(1), text_location(2), fix_title_string(sprintf('%.2f',i/FrameRate)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',[0.5 0.5 0.5]);
    end
    hold off;
        
end

return;
end
