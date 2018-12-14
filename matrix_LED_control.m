% controls the serial port per the stimulus matrix
% on-time   off-time    channel  power   freq(or 0)  strobe_on_time(or 0) strobe_off_time(or 0)
% maxtime is the maximum time this matrix is allowed to run ... deals with
% runtime issues when using repeated short stimuli (ie: strobes)

function matrix_LED_control(stimulus)

global DEFAULT_LED_CURRENT;

define_led_prefs();

t0 = absolute_seconds(clock);

k = length(stimulus(:,1));

% wait until it's time to turn on
delT = double(stimulus(1,1));
hacked_pause(delT);

i=1;
while(i<=k)
    
    duration = stimulus(i,2) - stimulus(i,1);
    channel = stimulus(i,3);
    
    if(channel==0)
        LED_control(0);
    else
        current = DEFAULT_LED_CURRENT(channel);
        if(length(stimulus(1,:)) > 4)
            current = stimulus(i,4);
        end
        
        strobe_period = 0;
        if(length(stimulus(1,:)) > 4)
            strobe_period = stimulus(i,5);
        end
        
        strobe_on_time = 0;
        strobe_off_time = 0;
        if(length(stimulus(1,:)) > 5)
            strobe_on_time = stimulus(i,6);
            strobe_off_time = stimulus(i,7);
        end
        
        LED_control(channel, current, duration, strobe_period, strobe_on_time, strobe_off_time);
    end
    
    % wait 'till the start of the next line
    if(i<k)
        delT = (t0 + double(stimulus(i+1,1))) - absolute_seconds(clock);
        hacked_pause(delT);
    end
    
    i=i+1;
end

% wait 'till the end of the program
delT = (t0 + double(stimulus(end,2))) - absolute_seconds(clock);
hacked_pause(delT);
    
return;

end

