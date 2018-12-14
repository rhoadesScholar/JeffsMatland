function current = power_to_LED_current(power, channel, scope_number)
% current = power_to_LED_current(power, channel, scope_number)

if(nargin==0)
   disp(['current = power_to_LED_current(power, channel, scope_number)'])
   return
end

global SCOPE_NUMBER;

if(nargin < 3)
    scope_number = SCOPE_NUMBER;
end

% dummy run
if(isempty(scope_number))
    scope_number = 100;
end

define_led_prefs();

for(i=1:length(power))
    if(power(i) == 0)
        current(i) = 0;
    else
        colorcode = channel_to_colorcode(scope_number, channel(i));
        [alpha, beta, gamma] = calibrate_if_needed(scope_number,colorcode);
        current(i) =  alpha*(power(i)^beta)+gamma; 
    end
end

return;
end
