function [alpha, beta, gamma] = calibrate_if_needed(scope_number,channel)

global LED_FIT_TOL;
global LED_CALIBRATION_PATH;
global LED_CHANNELS_COLORS;

define_led_prefs();

if(isempty(scope_number) || scope_number==100)
    alpha = 100;
    beta = 1;
    gamma = 0;
    return
end

power_file = sprintf('%s%spower.%d.%s.txt',...
    LED_CALIBRATION_PATH,filesep,scope_number,LED_CHANNELS_COLORS{channel});

fp = fopen(power_file,'r');
if(fp==-1)
    disp([sprintf('Need to calibrate %s LED power and create power file %s',LED_CHANNELS_COLORS{channel},power_file)]);
    calibrate_led(scope_number, channel);
    fp = fopen(power_file,'r');
end

A = textscan(fp,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','commentStyle','%');
fclose(fp);
numlines = length(A{1});

% A{n}(numlines) is word n of the last line

% if the first word of the last line is not today's date, we need to
% measure the power
k = datevec(date);
p = num2str(k(1));
dateline = sprintf('%d_%d_%s',k(2),k(3),p(3:4)); % 2.9.2009 = 2_9_09

if(strcmp(dateline, char(A{1}(numlines)))==0)
    disp([sprintf('Need to calibrate %s LED power for today ...',LED_CHANNELS_COLORS{channel})]);
    calibrate_led(scope_number, channel);
end

clear('dateline');

fp = fopen(power_file,'r');
A = textscan(fp,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','commentStyle','%');
fclose(fp);

numlines = length(A{1});

alpha = A{2}(numlines);
beta = A{3}(numlines);
gamma = A{4}(numlines);

old_alpha = A{2}(numlines-1);
old_beta = A{3}(numlines-1);

if(alpha/old_alpha > LED_FIT_TOL || old_alpha/alpha > LED_FIT_TOL || beta/old_beta > LED_FIT_TOL  || old_beta/beta > LED_FIT_TOL)
    disp(sprintf('Warning: Current alpha, beta calibration %.2f %.2f appears to be different than the previous calibration %.2f %.2f',alpha,beta, old_alpha, old_beta))
end

clear('A');

return;
end
