function LED_control(channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time)
% LED_control(channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time)

if(nargin == 0)
    disp(['LED_control(channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time)'])
    return
end

global MAX_LED_CURRENT;
global LED_CONTROL_PROGRAM;

if(nargin==1)
    current =  MAX_LED_CURRENT;
    duration = 0;
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
    
    % is a vector of inputs ... row from stimulus matrix?
    if(length(channel)>1)
        x = channel;
        for(i=1:length(x))
            if(i==1)
                channel = x(i);
            end
            if(i==2)
                current = x(i);
            end
            if(i==3)
                duration = x(i);
            end
            if(i==4)
                strobeperiod = x(i);
            end
            if(i==5)
                strobe_on_time = x(i);
            end
            if(i==6)
                strobe_pause_time = x(i);
            end
        end
    end
end

if(nargin==2)
    duration = 0;
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

if(nargin==3)
    strobeperiod = -10;
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

if(nargin==4)
    strobe_on_time = 0;
    strobe_pause_time = 0;
end

if(current<1)
    current = round(current);
end

if(channel >= 123)
    channel1 =  floor(channel/100);
    channel2 = floor((channel - 100*channel1)/10);
    channel3 = (channel - 100*channel1) - 10*channel2;
    
    command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel1, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
    run_command(command);
    
    command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel2, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
    run_command(command);
    
    command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel3, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
    run_command(command);
    
    return;
end

if(channel >= 12)
    channel1 =  floor(channel/10);
    channel2 = channel - 10*channel1;
    
    command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel1, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
    run_command(command);
    
    command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel2, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
    run_command(command);
    
    return;
end

command = sprintf('start /b %s %d %f %f %f %f %f',LED_CONTROL_PROGRAM,channel, current, duration, strobeperiod, strobe_on_time, strobe_pause_time);
run_command(command);

return;
end

