function run_led_file(inputstimfile, scope_number)

define_led_prefs();

global SCOPE_NUMBER;


if(nargin==0)
    sprintf('Usage: run_led_file(''stimulus_interval_file.stim'', scope_number)')
    return
end


if(nargin < 2)
    scope_number = SCOPE_NUMBER; % input('Which scope are you using?\n');
else
    SCOPE_NUMBER = scope_number;
end

stimulus = load_stimfile(inputstimfile,1); 
stimulus = edit_inputted_stimulus(stimulus); 

t = stimulus(end,2);
disp([sprintf('\nSet streampix: %d frames at 3fps (0.333sec/frame)\nTotal duration: %d:%d\t\n', ceil(t*3),floor(t/60), ceil(rem(t,60)))])

% stupid UNC pathname issues ... see run_command.m ... faster to do it here
% than to do it repeatedly when running a pulse program
currentdir = pwd;
cd(tempdir); 

countdown_clock(10);
matrix_LED_control(stimulus);

cd(currentdir);

return;
end
