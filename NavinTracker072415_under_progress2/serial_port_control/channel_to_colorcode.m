function colorcode = channel_to_colorcode(scope_number, channel)

global LED_CONTROLLER_PORT_CONFIG;

config_array = LED_CONTROLLER_PORT_CONFIG(scope_number,:);

subchannel = channel;

if(channel > 100)
    subchannel(1) =  floor(channel/100);
    subchannel(2) = channel - 100*subchannel(1);
else
    if(channel > 12)
        subchannel(1) =  floor(channel/10);
        subchannel(2) = channel - 10*subchannel(1);
    end
end

subcolor_str='';
for(x=1:length(subchannel))
    subcolor_str = sprintf('%s%d',subcolor_str,config_array(subchannel(x)));
end
colorcode = str2num(subcolor_str);

return;
end
