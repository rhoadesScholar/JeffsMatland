% on/off time units
% example file:
% off 1 min 0
% on 30 sec 1
% off 1 min 0
% on 15 sec 1
% off 2 min 0
% converts to stimulus matrix and .stim file (use for stimulus shading in plotting scripts):
% 60 90 1
% 150 165 1

function stimulus = txt_to_stim(stimulusfile, experiment_flag)

global DEFAULT_LED_CURRENT;
global DEFAULT_LED_STROBE_PERIOD;
global DEFAULT_STROBE_ON_TIME;
global DEFAULT_STROBE_PAUSE_TIME;
global DEFAULT_LED_POWER;
global LED_CHANNELS_COLORS;

if(nargin<2)
    experiment_flag=0;
end

define_led_prefs();

if(file_existence(stimulusfile)==0)
   error(sprintf('%s does not exist', stimulusfile));
end

fp = fopen(stimulusfile,'r');

tline = fgetl(fp);
i=0;
while(ischar(tline))
    
    i=i+1;
    
    %disp(tline)
    
    [words, num_words] = words_from_line(tline,'%');
    
    ledCommand(i).toggle = char(words{1});
    ledCommand(i).time = sscanf(char(words(2)),'%f');
    
    if(strcmp(char(words{3}),'min'))
        ledCommand(i).time = 60*ledCommand(i).time;
    end
    
    if(strcmp(char(words{3}),'hr'))
        ledCommand(i).time = 3600*ledCommand(i).time;
    end
    
    ledCommand(i).channel = 1; % default
    colorcode = 1;
    
    if(num_words >= 4)
        % if channel is given as a number
        
        ledCommand(i).channel = str2num(words{4});
        
        % if channel is given as a word
        if(ischar(words{4}))
            words{4} = lower(words{4});
            
            colorcode=1;
            while(strcmp(LED_CHANNELS_COLORS{colorcode},words{4})==0)
                colorcode=colorcode+1;
                if(colorcode>length(LED_CHANNELS_COLORS))
                   error('Do not know color %s in %s', words{4}, stimulusfile)
                end
            end
        end
        
        ledCommand(i).channel = colorcode_to_channel(colorcode);
    end
    ledCommand(i).colorcode = colorcode;
    
    if(ledCommand(i).channel > 0)
        ledCommand(i).power = DEFAULT_LED_CURRENT(colorcode);
        ledCommand(i).strobe_period = DEFAULT_LED_STROBE_PERIOD(colorcode);
        ledCommand(i).strobe_on = DEFAULT_STROBE_ON_TIME(colorcode);
        ledCommand(i).strobe_pause = DEFAULT_STROBE_PAUSE_TIME(colorcode);
    else
        ledCommand(i).power = 0;
        ledCommand(i).strobe_period = 0;
        ledCommand(i).strobe_on = 0;
        ledCommand(i).strobe_pause = 0;
    end
    
    if(num_words == 4 )
        if(ledCommand(i).channel > 0)
            ledCommand(i).power = DEFAULT_LED_POWER(colorcode);
        else
            ledCommand(i).power = 0;
        end
    end
    
    if(num_words >= 5)
        ledCommand(i).power = sscanf(char(words(5)),'%f');
    end
    
    if(num_words >= 6)
        ledCommand(i).strobe_period = sscanf(char(words(6)),'%f');
    end
    
    if(num_words > 6)
        ledCommand(i).strobe_on = sscanf(char(words(7)),'%f');
        ledCommand(i).strobe_pause = sscanf(char(words(8)),'%f');
    end
    
    
    clear('words');
    clear('num_words');
    tline = fgetl(fp);
end

fclose(fp);

% [pathstr, FilePrefix, ext] = fileparts(stimulusfile);
% if(~isempty(pathstr))
%     dummystr = sprintf('%s%s%s.stim',pathstr,filesep,FilePrefix);
% else
%     dummystr = sprintf('%s.stim',FilePrefix);
% end



dummystr = sprintf('%s.stim', tempname);
fp = fopen(dummystr,'w');

t=0;
i=1;
while(i<=length(ledCommand))
    
    if(strcmp(ledCommand(i).toggle,'on') == 1)
        if(strcmp(LED_CHANNELS_COLORS{ledCommand(i).colorcode},'ambergreen') && experiment_flag==1)
            channel_txt = num2str(ledCommand(i).channel);
            if(length(channel_txt)==2)
                subchannel(1) = str2num(channel_txt(1)); subchannel(2) = str2num(channel_txt(2));
            else % three digit for using two controller boxes ... 11, 12 = channel 1,2 on 2nd box
                subchannel(1) = str2num(channel_txt(1)); subchannel(2) = str2num(channel_txt(2:3));
            end
            fprintf(fp,'%f\t%f\t%d\t%f\t%f\t%f\t%f\n',t, t + ledCommand(i).time, subchannel(1), ledCommand(i).power, ledCommand(i).strobe_period, ledCommand(i).strobe_on,ledCommand(i).strobe_pause );
            fprintf(fp,'%f\t%f\t%d\t%f\t%f\t%f\t%f\n',t, t + ledCommand(i).time, subchannel(2), ledCommand(i).power, ledCommand(i).strobe_period, ledCommand(i).strobe_on,ledCommand(i).strobe_pause );
        else
            fprintf(fp,'%f\t%f\t%d\t%f\t%f\t%f\t%f\n',t, t + ledCommand(i).time, ledCommand(i).channel, ledCommand(i).power, ledCommand(i).strobe_period, ledCommand(i).strobe_on,ledCommand(i).strobe_pause );
        end
    end
    
    if(i<length(ledCommand))
        if(strcmp(ledCommand(i).toggle,'on') == 1 && strcmp(ledCommand(i+1).toggle,'off') == 1)
            t = t + ledCommand(i).time;
        end
        
        if(strcmp(ledCommand(i).toggle,'off') == 1)
            t = t + ledCommand(i).time;
        end
    end
    
    if(i==length(ledCommand))
        if(strcmp(ledCommand(i).toggle,'off') == 1)
            t = t + ledCommand(i).time;
            fprintf(fp,'%f\t%f\t%d\t%f\t%f\t%f\t%f\n',t, t, 0, 0, 0, 0,0);
        end
    end
    
    i=i+1;
end

fclose(fp);

stimulus = load_stimfile(dummystr, experiment_flag);
rm(dummystr);

return;
end
