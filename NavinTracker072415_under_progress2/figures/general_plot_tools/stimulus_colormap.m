function x = stimulus_colormap(a)

define_led_prefs();
global LED_CHANNELS_COLORS;

if(isempty(a))
    x=[1 1 1];
    return
end

if(a<1e-4)
    x=[1 1 1];
    return
end


% x = [0.9 0.9 0.9]; 
% return;
% end


v = [1 1 1];

if(a == 1)
    v = [0.2549      0.41176      0.88235]; % royal blue % [0 0.7 0.8]; % 'c';
else if(a == find(strcmp(LED_CHANNELS_COLORS,'green')) || a == find(strcmp(LED_CHANNELS_COLORS,'doublegreen')))
        v = [0 1 0]; % green [0 0.7 0.5]
    else if(a == find(strcmp(LED_CHANNELS_COLORS,'amber')) || a == find(strcmp(LED_CHANNELS_COLORS,'doubleamber'))) % amber
            v = [1 1 0]; % 'y'
        else if(a == find(strcmp(LED_CHANNELS_COLORS,'violet')))
                v = [0.58039 0 0.82745]; % violet [0.58039 0 0.82745]; [0.93333 0.5098 0.93333];
            else if(a == find(strcmp(LED_CHANNELS_COLORS,'ambergreen')) || a == find(strcmp(LED_CHANNELS_COLORS,'greenamber')))
                    v = [0.94118 0.90196 0.54902]; % ambergreen
                else if(a > 0)
                        v = [0.7 0.7 0.7];    % default to light gray ... if the stimulus is actually an "off" step or is something else
                    end
                end
            end
        end
    end
end

x=v;

% x = uint8(v(1,:)*255);

return;
end
