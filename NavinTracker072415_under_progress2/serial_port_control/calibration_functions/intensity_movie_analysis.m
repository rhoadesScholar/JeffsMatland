function pixel_inten = intensity_movie_analysis(RealMovieName, scope_number,colorcode, channel)

global LED_LEVEL_SETTING;
global LED_CALIBRATION_PATH;
global LED_CALIBRATION_MOVIES_PATH;
global LED_PAPER_METER;
global LED_CHANNELS_COLORS;
global LED_CALIBRATION_STIMULUS;
global LED_FIT_TOL;


define_led_prefs();

MovieName = sprintf('%s.avi',tempname); 
cp(RealMovieName,MovieName);

FileInfo = moviefile_info(MovieName);

for Frame = 1:FileInfo.NumFrames
    Mov = aviread_to_gray(MovieName,Frame);
    TotalFrameIntensity(Frame) = sum(sum(Mov.cdata));
    clear('Mov');
    if(mod(Frame,100)==0 || Frame==1)
        disp(sprintf('Frame %d/%d', Frame, FileInfo.NumFrames))
    end
end
rm(MovieName);

stimulus = LED_CALIBRATION_STIMULUS;

t = 1:FileInfo.NumFrames;
t = t/3;
plot_columns = 3;
plot_rows = 1;
figure(1);
close(1);
figure(1);
title(fix_title_string(RealMovieName));
subplot(plot_rows,plot_columns,1);
plot(t, TotalFrameIntensity);
axis([0 max(t) 0 max(TotalFrameIntensity)]);
axis('auto y');
xlabel('time (sec)');
ylabel('total pixel intensity');

for(i=1:length(stimulus(:,1)))
   idx = (3*stimulus(i,1)):(3*stimulus(i,2));
   pixel_inten(i) = nanmedian(TotalFrameIntensity(idx));
end

subplot(plot_rows,plot_columns,2);
plot(LED_LEVEL_SETTING, pixel_inten, 'oc');
axis([0 1000 0 max(TotalFrameIntensity)]);
axis('auto x');
axis('auto y');
xlabel('current setting (mA)');
ylabel('median intensity');

if(LED_PAPER_METER(scope_number,colorcode,3) == 0)
    led_power = LED_PAPER_METER(scope_number,colorcode,1)*pixel_inten + LED_PAPER_METER(scope_number,colorcode,2);
else
    led_power = LED_PAPER_METER(scope_number,colorcode,1)*pixel_inten.^LED_PAPER_METER(scope_number,colorcode,2) + ...
                    LED_PAPER_METER(scope_number,colorcode,3)*exp(pixel_inten*LED_PAPER_METER(scope_number,colorcode,4));
end

% linearity limits for power vs pixel intensity
% idx = find(pixel_inten <= 5e7);
idx = 1:length(pixel_inten);

[alpha, beta, gamma, R_fit] = fit_led_power([0 led_power(idx)], [0 LED_LEVEL_SETTING(idx)]);

subplot(1,3,3);
plot([0 LED_LEVEL_SETTING(idx)], [0 led_power(idx)], 'oc');
hold on;
xx = [0 led_power(idx)];
plot(alpha*(xx.^beta)+gamma, xx, 'r');
text(LED_LEVEL_SETTING(1), max(led_power), sprintf('Power = \\alpha*current^{\\beta} + \\gamma\n\\alpha = %.3f\n\\beta = %.3f\n\\gamma = %.3f\nR = %.3f', alpha, beta, gamma, R_fit));
xlabel('current setting (mA)');
ylabel('power (mW)');
clear('xx');

dummystring2 = sprintf('%s %f %f %f', dateline(), alpha, beta, gamma);

for(j=1:length(LED_LEVEL_SETTING))
    dummystring2 = sprintf('%s %.3f %d',dummystring2, led_power(j), LED_LEVEL_SETTING(j));
end
dummystring2 = sprintf('%s\n',dummystring2);

power_file = sprintf('%s%spower.%d.%s.txt',...
    LED_CALIBRATION_PATH,filesep,scope_number,LED_CHANNELS_COLORS{colorcode});

fp = fopen(power_file,'a');
fprintf(fp,'%s',dummystring2);
fclose(fp);

pdf_filename = sprintf('%s%s.%d.%s.pdf',LED_CALIBRATION_MOVIES_PATH, dateline(),scope_number,LED_CHANNELS_COLORS{colorcode});
save_pdf(1, pdf_filename);
%open(pdf_filename);

clear('pdf_filename');
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
