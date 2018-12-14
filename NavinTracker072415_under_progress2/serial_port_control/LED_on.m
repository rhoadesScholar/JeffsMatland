function LED_on(channelA, channelB, channelC, channelD)

define_led_prefs();

if(nargin==0)
    channelA = 1;
    channelB = 0;
    channelC = 0;
    channelD = 0;
end

if(nargin==1)
    channelB=0;
    channelC=0;
    channelD = 0;
end

if(nargin==2)
    channelC=0;
    channelD = 0;
end

if(channelA > 0)
    LED_control(channelA);
end

if(channelB > 0)
    LED_control(channelB);
end

if(channelC > 0)
    LED_control(channelC);
end

if(channelD > 0)
    LED_control(channelD);
end

disp(['Press any key to end.'])
pause

LED_control(0);

return;

