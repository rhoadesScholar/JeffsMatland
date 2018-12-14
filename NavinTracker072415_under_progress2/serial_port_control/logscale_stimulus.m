function logscale_stimulus(channel)

global DEFAULT_LED_CURRENT;
global DEFAULT_LED_STROBE_FREQ;
global DEFAULT_STROBE_ON_TIME;
global DEFAULT_STROBE_PAUSE_TIME;

define_led_prefs();

if(nargin==0)
    channel=1;
end

if(channel(1) == 'b' || channel(1) == 'B')
    channel=1;
end
if(channel(1) == 'g' || channel(1) == 'G')
    channel=2;
end   


stimulus = [    100.000000	100.250000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                200.250000	200.750000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                300.750000	301.750000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                401.750000	404.250000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                504.250000	509.250000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                609.250000	619.250000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel); ...
                719.250000	819.250000	channel DEFAULT_LED_CURRENT(channel) DEFAULT_LED_STROBE_FREQ(channel) DEFAULT_STROBE_ON_TIME(channel) DEFAULT_STROBE_PAUSE_TIME(channel);
                919.250000	919.250000	0   0   0   0   0;];
% 
% 919.25sec; round to 920sec; 2760frames; 15.33min ; 0.25, 0.5, 1, 2.5, 5, 10, 100 sec


% stimulus = [    100.0000  100.1000    1.0000; ...
%                 200.1000  200.6000    1.0000; ...
%                 300.6000  301.6000    1.0000; ...
%                 401.6000  406.6000    1.0000; ...
%                 506.6000  516.6000    1.0000; ...
%                 616.6000  666.6000    1.0000;
%                 766.6000  766.6000    0.0000];
% % % 766.6sec; 2300frames; 13min ; 0.1, 0.5, 1, 5, 10, 50 sec

matrix_LED_control(stimulus);

return

