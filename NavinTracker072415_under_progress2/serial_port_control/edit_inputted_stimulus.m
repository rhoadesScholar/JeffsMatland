function out_stimulus = edit_inputted_stimulus(stimulus)

global DEFAULT_LED_STROBE_PERIOD;
global DEFAULT_STROBE_ON_TIME;
global DEFAULT_STROBE_PAUSE_TIME;
global DEFAULT_LED_POWER;

define_led_prefs();

num_elements = size(stimulus);
num_stim_lines = num_elements(1);
num_elements = num_elements(2);

for(i=1:num_stim_lines)
    for(j=1:num_elements)
        if(isnan(stimulus(i,j)))
            
            % if no channel is listed, assume channel 1
            if(j==3)
                stimulus(i,3) = 1;
            end
            
            % if power not listed, set to defaults
            if(j==4)
                stimulus(i,4) = 0;
                if(stimulus(i,3) > 0)
                    stimulus(i,4) = DEFAULT_LED_POWER(stimulus(i,3));
                end
            end
            
            % if strobe not defined, set to default
            if(j==5)
                stimulus(i,5) = 0;
                if(stimulus(i,3) > 0)
                    stimulus(i,5) = DEFAULT_LED_STROBE_PERIOD(stimulus(i,3));
                end
            end
            
            % if strobe patterns not defined, set to default
            if(j==6)
                stimulus(i,6) = 0;
                if(stimulus(i,3) > 0)
                    stimulus(i,6) = DEFAULT_STROBE_ON_TIME(stimulus(i,3));
                end
            end
            
            if(j==7)
                stimulus(i,7) = 0;
                if(stimulus(i,3) > 0)
                    stimulus(i,7) = DEFAULT_STROBE_PAUSE_TIME(stimulus(i,3));
                end
            end
        end
    end
end

% if no channel is listed, assume channel 1
if(length(~isnan(stimulus(1,:)))==2)
    for(i=1:length(stimulus(:,1)))
        stimulus(i,3) = 1;
    end
end

% if power not listed, set to defaults
if(length(~isnan(stimulus(1,:)))==3)
    for(i=1:length(stimulus(:,1)))
        stimulus(i,4) = 0;
        if(stimulus(i,3) > 0)
            stimulus(i,4) = DEFAULT_LED_POWER(stimulus(i,3));
        end
    end
end

% if strobe not defined, set to default
if(length(~isnan(stimulus(1,:)))==4)
    for(i=1:length(stimulus(:,1)))
        stimulus(i,5) = 0;
        if(stimulus(i,3) > 0)
            stimulus(i,5) = DEFAULT_LED_STROBE_PERIOD(stimulus(i,3));
        end
    end
end

% if strobe patterns not defined, set to default
if(length(~isnan(stimulus(1,:)))==5)
    for(i=1:length(stimulus(:,1)))
        stimulus(i,6) = 0; stimulus(i,7) = 0;
        if(stimulus(i,3) > 0)
            stimulus(i,6) = DEFAULT_STROBE_ON_TIME(stimulus(i,3));
            stimulus(i,7) = DEFAULT_STROBE_PAUSE_TIME(stimulus(i,3));
        end
    end
end

if(stimulus(end,3) > 0)
    stim_len = length(stimulus(:,1));
    stimulus(stim_len+1,:) = stimulus(stim_len,:);
    
    stimulus(stim_len+1,1) = stimulus(stim_len,2);
    stimulus(stim_len+1,2) = stimulus(stim_len,2);
    stimulus(stim_len+1,3) = 0;
    stimulus(stim_len+1,4) = 0;
    stimulus(stim_len+1,5) = 0;
    stimulus(stim_len+1,6) = 0;
    stimulus(stim_len+1,7) = 0;
end

% if > 10 then likely the current is being used
if(stimulus(:,4)< 10)
    stimulus(:,4) = power_to_LED_current(stimulus(:,4), stimulus(:,3));
end

out_stimulus = stimulus;


return;
end
