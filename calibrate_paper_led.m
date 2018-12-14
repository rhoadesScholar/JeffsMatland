function calibrate_paper_led(scope_number,channel)


global LED_CALIBRATION_PATH;
global LED_CALIBRATION_MOVIES_PATH;
global LED_LEVEL_SETTING;
global LED_PAPER_METER;
global LED_CHANNELS_COLORS;
global LED_CALIBRATION_STIMULUS;

define_led_prefs();

colorcode = channel_to_colorcode(scope_number, channel);

moviefile = sprintf('%s%s.%d.%s.avi',LED_CALIBRATION_MOVIES_PATH, dateline(),scope_number,LED_CHANNELS_COLORS{colorcode});

if(~file_existence(moviefile))
    
    dummystring = '';
    
    dummystring = sprintf('%s\nRemove any filters and place the paper on the stage',dummystring);
    dummystring = sprintf('%s\nTurn the transmitted light off',dummystring);
    dummystring = sprintf('%s\nSet streampix to:\n      brightness=0\n      gamma=100\n      shutter=10000\n      gain=0',dummystring);
    dummystring = sprintf('%s\n375 frames at 3fps (0.333 sec/frame)',dummystring);
    dummystring = sprintf('%s\nSave file as %s',dummystring,moviefile);
    dummystring = sprintf('%s\nFilename in clipboard for pasting into recording software',dummystring);
    
    clipboard('copy', moviefile);
    
    questdlg(dummystring, 'Calibrate LED','OK','OK');
    
    led_power(1:length(LED_LEVEL_SETTING)) = 0;
    
    n = 1:length(LED_LEVEL_SETTING);
    
    stimulus = LED_CALIBRATION_STIMULUS; 
    
    
    k = length(stimulus(:,1));
    
%     disp(['Press any key to start the 10 sec countdown'])
%     pause
%     home
%     disp(['Starting in 10 sec ...'])
%     for(i=10:-1:1)
%         disp([num2str(i) ' sec left'])
%         pause(1)
%         home
%     end
%     disp(['Start'])
    
    countdown_clock(10);
    
    i=1;
    while(i<=k)
        
        disp(sprintf('%d mA',LED_LEVEL_SETTING(i)))
        
        % wait until it's time to turn on
        
        if(i==1)
            delT = double(stimulus(i,1));
        else
            delT = double(stimulus(i,1) - stimulus(i-1,2));
        end
        
        hacked_pause(delT);
        
        t1 = absolute_seconds(clock);
        
        duration = stimulus(i,2) - stimulus(i,1);
        
        LED_control(channel, LED_LEVEL_SETTING(i), duration);
        
        t2 = absolute_seconds(clock);
        
        hacked_pause( (duration - (t2-t1)) );
        
        i=i+1;
    end
    
    pause(10); % wait for the movie to finish and save
    
end

sprintf('Please save the movie file or refresh Streampix!')
sprintf('Hit any key to continue')
pause

% command = sprintf('intensity_movie_analysis(''%s'',%d, %d, %d)',moviefile,scope_number,colorcode,channel);
% launch_matlab_command(command, 1);

intensity_movie_analysis(moviefile, scope_number,colorcode,channel);

return;
end

% pixel_inten = intensity_movie_analysis(moviefile);
%
% if(LED_PAPER_METER(scope_number,colorcode,3) == 0)
%     led_power = LED_PAPER_METER(scope_number,colorcode,1)*pixel_inten + LED_PAPER_METER(scope_number,colorcode,2);
% else
%     led_power = LED_PAPER_METER(scope_number,colorcode,1)*pixel_inten.^LED_PAPER_METER(scope_number,colorcode,2) + ...
%                     LED_PAPER_METER(scope_number,colorcode,3)*exp(pixel_inten*LED_PAPER_METER(scope_number,colorcode,4));
% end
%
% % linearity limits for power vs pixel intensity
% % idx = find(pixel_inten <= 5e7);
% idx = 1:length(pixel_inten);
%
% [alpha, beta, gamma, R_fit] = fit_led_power([0 led_power(idx)], [0 LED_LEVEL_SETTING(idx)]);
%
% subplot(1,3,3);
% plot([0 LED_LEVEL_SETTING(idx)], [0 led_power(idx)], 'oc');
% hold on;
% xx = [0 led_power(idx)];
% plot(alpha*(xx.^beta)+gamma, xx, 'r');
% text(LED_LEVEL_SETTING(1), max(led_power), sprintf('Power = \\alpha*current^{\\beta} + \\gamma\n\\alpha = %.3f\n\\beta = %.3f\n\\gamma = %.3f\nR = %.3f', alpha, beta, gamma, R_fit));
% xlabel('current setting (mA)');
% ylabel('power (mW)');
% clear('xx');
%
% dummystring2 = sprintf('%s %f %f %f', dateline(), alpha, beta, gamma);
%
% for(j=1:length(LED_LEVEL_SETTING))
%     dummystring2 = sprintf('%s %.3f %d',dummystring2, led_power(j), LED_LEVEL_SETTING(j));
% end
% dummystring2 = sprintf('%s\n',dummystring2);
%
% power_file = sprintf('%s%spower.%d.%s.txt',...
%     LED_CALIBRATION_PATH,filesep,scope_number,LED_CHANNELS_COLORS{colorcode});
%
% fp = fopen(power_file,'a');
% fprintf(fp,'%s',dummystring2);
% fclose(fp);
%
% save_pdf(1, sprintf('%s%s.%d.%s.pdf',LED_CALIBRATION_MOVIES_PATH, dateline(),scope_number,LED_CHANNELS_COLORS{colorcode}));
%
%
% clear('dummystring');
% clear('dummystring2');
% clear('led_power');
%
% disp([sprintf('alpha = %f\tbeta = %f\tgamma =% f\tR_fit = %f',alpha,beta,gamma,R_fit)])
% disp([sprintf('Setting for 1.25mW = %f', power_to_LED_current(1.25, channel, scope_number))])
% disp([sprintf('Setting for 2.50mW = %f', power_to_LED_current(2.50, channel, scope_number))])



