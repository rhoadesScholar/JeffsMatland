function channel = colorcode_to_channel(colorcode)

define_led_prefs();

global LED_CONTROLLER_PORT_CONFIG;
global SCOPE_NUMBER;

if(isempty(SCOPE_NUMBER))
    scope_num = 100;
else
    scope_num = SCOPE_NUMBER;
end

config_array = LED_CONTROLLER_PORT_CONFIG(scope_num,:);

channel = find(config_array == colorcode);

if(~isempty(channel))
    channel = channel(1);
    return;
end

% for composite channels; ie: more than one light is turned on
% 12 = bluegreen; 22 = doublegreen; 23 = ambergreen; 123=bluegreenamber

chan_txt = num2str(colorcode);


port_pos=[];
for(i=1:length(chan_txt))
    subchannel = str2num(chan_txt(i));
    
    pp = find(config_array == subchannel);
    if(isempty(pp))
        error(sprintf('Cannot find colorcode %d for scope %d',colorcode,scope_num));
        return; 
    end
    port_pos(i) = pp(1); 
    
    if(scope_num~=100)
        config_array(port_pos(i))=0; % for doublecolors
    end
end

port_pos = sort(port_pos);

channelstr = '';
for(i=1:length(port_pos))
    channelstr = sprintf('%s%d', channelstr, port_pos(i));
end

channel = str2num(channelstr);

return;
end
