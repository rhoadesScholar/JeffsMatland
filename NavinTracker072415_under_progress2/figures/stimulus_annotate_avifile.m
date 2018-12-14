function stimulus_annotate_avifile(original_file, new_file, stimfile, framerate, text_location)
% stimulus_annotate_avifile(original_file, new_file, stimfile, text_location)


if(nargin<4)
    disp('stimulus_annotate_avifile(original_file, new_file, stimfile, framerate, <text_location>)')
    return
end

FileInfo = moviefile_info(original_file);

if(nargin<5)
    text_location = [ round((1/2)*FileInfo.Width) (19/20)*FileInfo.Height ];
end

global Prefs;
Prefs = define_preferences(Prefs);
Prefs.FrameRate = framerate;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

define_led_prefs();
global LED_CONTROLLER_PORT_CONFIG;
global LED_CHANNELS_COLORS;


if(isempty(strfind(new_file,'avi')))
    new_file = sprintf('%s.avi',new_file);
end

if(isempty(strfind(new_file,'/')) && isempty(strfind(new_file,'\')))
    new_file = sprintf('%s%s%s', pwd,filesep,new_file);
end

if(file_existence(new_file))
    rm(new_file);
end

if(ischar(stimfile))
    stimulus = load_stimfile(stimfile);
    stimulus(end,:) = []; 
else
    stimulus = stimfile;
end

tempfilename = sprintf('%s.avi',tempname);
tempfilename

aviobj = VideoWriter(tempfilename); % , 'MPEG-4');
open(aviobj);


close all
stim_idx = 1;
current_time = 0;
for(i=1:FileInfo.NumFrames)
    Mov = aviread_to_gray(original_file, i);
    
    fig = figure('menubar','none','toolbar','none');
    
    idx = max(1,floor(i/Prefs.FrameRate));
    
    % time_string = seconds_to_time_colon_string(bd_N2.time(idx));
     
    current_time = current_time + 1/framerate;
    time_string = seconds_to_time_colon_string(current_time);
     

      imshow(Mov.cdata ,'Border','tight');
    

    if(i>Prefs.FrameRate*stimulus(stim_idx,2))
        stim_idx = stim_idx+1;
    end
    if(stim_idx > size(stimulus,1))
        stim_idx = 1;
    end
    if(i>=Prefs.FrameRate*stimulus(stim_idx,1) && i<=Prefs.FrameRate*stimulus(stim_idx,2) && stimulus(stim_idx,3)>0)
        if(stimulus(stim_idx,3)>10 && stimulus(stim_idx,3)<100)
            stimulus(stim_idx,3) = floor(stimulus(stim_idx,3)/10);
        end
        hold on;
        if(LED_CONTROLLER_PORT_CONFIG(100,stimulus(stim_idx,3)) < 100)
            text(text_location(1), text_location(2), fix_title_string(sprintf('%s ON %.2f mW ',time_string, stimulus(stim_idx,4))),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
        else
            if(strcmp(LED_CHANNELS_COLORS{LED_CONTROLLER_PORT_CONFIG(100,stimulus(stim_idx,3))},'histamine')) % if(stimulus(stim_idx,4) == 101)
                text(text_location(1), text_location(2), fix_title_string(sprintf('%s histamine ON',time_string)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
            end
            if(strcmp(LED_CHANNELS_COLORS{LED_CONTROLLER_PORT_CONFIG(100,stimulus(stim_idx,3))},'capsaicin')) % if(stimulus(stim_idx,4) == 102)
                text(text_location(1), text_location(2), fix_title_string(sprintf('%s capsaicin ON',time_string)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
            end
%             if(strcmp(LED_CHANNELS_COLORS{stimulus(stim_idx,4)},'odor')) % if(stimulus(stim_idx,4) >= 200)
%                 text(text_location(1), text_location(2), fix_title_string(sprintf('  %.2f s odor ON  ',i/Prefs.FrameRate)),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',stimulus_colormap(stimulus(stim_idx,3)));
%             end
        end
        hold off;
    else
        text(text_location(1), text_location(2), sprintf('%s', time_string),'HorizontalAlignment','center','FontWeight','bold','BackgroundColor',[0.7 0.7 0.7]);
    end
    
        
    set(gcf,'color','w');
    F = getframe(fig);
    writeVideo(aviobj,F);
    close(fig);
    
    
end

close(aviobj);

% converts the large uncompressed temp file to a compressed xvid mpeg4
disp(sprintf('Saving the truncated moviefile %s to %s',tempfilename, new_file))
cp(tempfilename, new_file);
% command = sprintf('ffmpeg -i %s -c libxvid -vtag xvid %s', tempfilename,new_file);
% run_command(command);
% rm(tempfilename);

return;
end
