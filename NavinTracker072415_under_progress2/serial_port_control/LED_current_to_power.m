function power = LED_current_to_power(current, channel, scope_number)
% power = LED_current_to_power(current, channel, scope_number)

if(nargin==0)
   disp(['power = LED_current_to_power(current, channel, scope_number)'])
   return
end

global SCOPE_NUMBER;

if(nargin < 3)
    scope_number = SCOPE_NUMBER;
end

define_led_prefs();

for(i=1:length(current))
    if(current(i) == 0)
        power(i) = 0;
    else
        [alpha, beta, gamma] = calibrate_if_needed(scope_number,channel(i));
        %current(i) =  alpha*(power(i)^beta)+gamma; 
        power(i) = exp((log((current(i)-gamma)/alpha))/beta);
    end
end

return;
end
