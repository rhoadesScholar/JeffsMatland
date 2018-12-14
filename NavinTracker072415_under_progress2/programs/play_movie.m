function play_movie(filename, stimulus, startframe, endframe)
% play_movie(filename, stimulus, startframe, endframe)

global LED_CHANNELS_COLORS;
define_led_prefs;

file_info = moviefile_info(filename);

if(nargin<4)
    startframe = 1;
    endframe = file_info.NumFrames;
end

if(nargin<2)
    stimulus = [];
end

if(~isempty(stimulus))
    stimulus(:,1:2) = 3*stimulus(:,1:2);
end

fignum=figure;
s=1;
for(i=startframe:endframe)
    
    Mov = aviread_to_gray(filename,i);

    figure(fignum);
    imshow(Mov.cdata);
    
    hold on;
    if(~isempty(stimulus))
        
        while(i > stimulus(s,2))
            s = s+1;
            if(s == stimulus(1))
                break;
            end
        end
        
        if(i >= stimulus(s,1) && i <= stimulus(s,2) && stimulus(s,3) > 0)
            text('Position',[10,10],'String',sprintf('%d %s',i, LED_CHANNELS_COLORS{stimulus(s,3)}),'color','r');
        else
            text('Position',[10,10],'String',sprintf('%d',i),'color','r');
        end
        
    else
        text('Position',[10,10],'String',sprintf('%d',i),'color','r');
    end
    hold off;
    
    % pause(0.1);
    % clear('Mov');
end
return

end
