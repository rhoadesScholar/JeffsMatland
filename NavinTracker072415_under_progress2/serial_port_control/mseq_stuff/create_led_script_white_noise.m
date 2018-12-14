function powers = create_led_script_white_noise(mu, SD, stepwidth, num_steps)

% load powers
% countdown_clock(10); hacked_pause(100); for(i=1:1000) LED_control(1, power_to_LED_current(powers(i),1)); hacked_pause(1); end; LED_control(0); hacked_pause(100);


% empirically test stepwidth; 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5 sec
% with ASH 1st, then AWC, AIB
% optimal seq? LNP model?
% event triggered for various rev, omega, etc
% current pulse seqs output reminscent of Mainen and Sejnowski 
% peak, then diffuse

channel = 1;
buffer_time = 100;

if(nargin<3)
    mu = 0.75;
    SD = 0.5;
    stepwidth = 1;
    num_steps = 1000;
end

t = 2*buffer_time + num_steps*stepwidth;
powers = zeros(1,num_steps);

disp([sprintf('\nSet streampix: %d frames at 3fps (0.333sec/frame)\nTotal duration: %d:%d\t\n', ...
    ceil(t*3),floor(t/60), ceil(rem(t,60)))])

countdown_clock(10);

hacked_pause(buffer_time);
for(i=1:num_steps)
    
    powers(i) = max(0.01,SD*randn + mu);
    disp(num2str(powers(i)))
    LED_control(channel, power_to_LED_current(powers(i),channel));
    hacked_pause(stepwidth);
    
end
LED_control(0);
hacked_pause(buffer_time);

return;
end
