function calibrate_led(scope_number,channel, manual_flag)
% calibrate_led(scope_number,channel, manual_flag)

global LED_CALIBRATION_PATH;
global DEBUG_FLAG;
global LED_LAMBDA;
global LED_LEVEL_SETTING;
global LED_CHANNELS_COLORS;
global LED_PAPER_METER;
global SCOPE_NUMBER;
global LED_FIT_TOL;

define_led_prefs();

if(nargin == 0)
    if(~isempty(SCOPE_NUMBER))
        scope_number = SCOPE_NUMBER;
    else
        scope_number = input('Which scope are you using?\n');
    end
end

if(nargin<2)
    channel = inputdlg('Which LED color?'); % input('Which LED color?\n','s');
end

if(~isnumeric(channel))
    channel = lower(channel);
    colorcode=1;
    while(strcmp(LED_CHANNELS_COLORS{colorcode},channel)==0)
        colorcode=colorcode+1;
        if(colorcode>length(LED_CHANNELS_COLORS))
            error('Do not know color %s', channel)
        end
    end
    clear('channel');
    channel = colorcode_to_channel(colorcode);
end


if(nargin<3)
    manual_flag=0;
end

if(manual_flag == 0)
    if(sum(LED_PAPER_METER(scope_number,channel_to_colorcode(scope_number, channel),:))~=0)
        calibrate_paper_led(scope_number,channel);
        return;
    end
end

sprintf('Set power meter to %d nm, put meter into power mode.',LED_LAMBDA(colorcode))
sprintf('Hit any key to continue')
pause

led_power(1:length(LED_LEVEL_SETTING)) = 0;

for(j=1:length(LED_LEVEL_SETTING))

    if(DEBUG_FLAG==0)
        pause(5);
    end

    LED_control(channel, LED_LEVEL_SETTING(j))

    dummystring = sprintf('Power (mW) for %d: ', LED_LEVEL_SETTING(j));

    inputted_number=[];
    while(isempty(inputted_number))
        inputted_number = input(dummystring);
    end

    led_power(j) = inputted_number;

    LED_control(0);

end


[alpha, beta, gamma, R_fit] = fit_led_power(led_power, LED_LEVEL_SETTING);

dummystring2 = sprintf('%s %f %f %f', dateline(), alpha, beta, gamma);

for(j=1:length(LED_LEVEL_SETTING))
    dummystring2 = sprintf('%s %.3f %d',dummystring2, led_power(j), LED_LEVEL_SETTING(j));
end
dummystring2 = sprintf('%s\n',dummystring2);

colorcode = channel_to_colorcode(scope_number, channel);
power_file = sprintf('%s%spower.%d.%s.txt',...
    LED_CALIBRATION_PATH,filesep,scope_number,LED_CHANNELS_COLORS{colorcode});

fp = fopen(power_file,'a');
fprintf(fp,'%s',dummystring2);
fclose(fp);

clear('dummystring');
clear('dummystring2');
clear('led_power');

disp([sprintf('alpha = %f\tbeta = %f\tgamma =% f\tR_fit = %f',alpha,beta,gamma,R_fit)])
disp([sprintf('Setting for 1.25mW = %f', power_to_LED_current(1.25, channel, scope_number))])
disp([sprintf('Setting for 2.50mW = %f', power_to_LED_current(2.50, channel, scope_number))])


fp = fopen(power_file,'r');
A = textscan(fp,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','commentStyle','%');
fclose(fp);

numlines = length(A{1});

old_alpha = A{2}(numlines-1);
old_beta = A{3}(numlines-1);

if(alpha/old_alpha > LED_FIT_TOL || old_alpha/alpha > LED_FIT_TOL || beta/old_beta > LED_FIT_TOL  || old_beta/beta > LED_FIT_TOL)
    disp(sprintf('Warning: Current alpha, beta calibration %.2f %.2f appears to be different than the previous calibration %.2f %.2f',alpha,beta, old_alpha, old_beta))
end

clear('A');

return;
end


