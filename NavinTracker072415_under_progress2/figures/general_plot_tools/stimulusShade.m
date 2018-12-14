function fillhandle=stimulusShade(stimulus, ymin, ymax, inputcolor, xlims)
% fillhandle=stimulusShade(stimulus, ymin, ymax, color, xlims)
% shades the plot between the times in the stimulus matrix
% stimulus(i,1) = start stimulus i
% stimulus(i,2) = end stimulus i
% ymax and ymin are the max and min of the y-axis respectively
% color = the color of the filled area


fillhandle=[];

if(isempty(stimulus))
    return;
end

if(~isnumeric(stimulus))
    return;
end

if(nargin<5)
    xlims=[];
end

if(nargin<4)
    inputcolor=[];
end

hold on

ypoints(1) = ymax;
ypoints(2) = ymax;
ypoints(3) = ymin; 
ypoints(4) = ymin; 

for(i=1:length(stimulus(:,1)))
    
    if(stimulus(i,2) - stimulus(i,1) > 1e-4)
        
        if(isempty(xlims)) % normal
            xpoints(1) = stimulus(i,1);
            xpoints(2) = stimulus(i,2);
            xpoints(3) = stimulus(i,2);
            xpoints(4) = stimulus(i,1);
        else
            if(stimulus(i,1) >= xlims(2) || stimulus(i,2) <= xlims(1))  % stim start after xlim(2) or stim end before xlim(1)
                xpoints = zeros(1,4)+NaN;
            else
                % stim starts after xlims(1) and ends before xlims(2)
                if(stimulus(i,1) >= xlims(1) && stimulus(i,1) <= xlims(2) && stimulus(i,2) >= xlims(1) && stimulus(i,2)<=xlims(2))
                    xpoints(1) = stimulus(i,1);
                    xpoints(2) = stimulus(i,2);
                    xpoints(3) = stimulus(i,2);
                    xpoints(4) = stimulus(i,1);
                else
                    % stim starts after xlims(1) and ends after xlims(2)
                    if(stimulus(i,1) >= xlims(1) && stimulus(i,2) > xlims(2))
                        xpoints(1) = stimulus(i,1);
                        xpoints(2) = xlims(2);
                        xpoints(3) = xlims(2);
                        xpoints(4) = stimulus(i,1);
                    else
                        % stim starts before xlims(1) and ends before xlims(2)
                        if(stimulus(i,1) < xlims(1) && stimulus(i,2) <= xlims(2))
                            xpoints(1) = xlims(1);
                            xpoints(2) = stimulus(i,2);
                            xpoints(3) = stimulus(i,2);
                            xpoints(4) = xlims(1);
                        else
                            % stim starts before xlims(1) and ends after xlims(2)
                            if(stimulus(i,1) < xlims(1) && stimulus(i,2) > xlims(2))
                                xpoints(1) = xlims(1);
                                xpoints(2) = xlims(2);
                                xpoints(3) = xlims(2);
                                xpoints(4) = xlims(1);
                            end
                            
                        end
                    end
                end
            end
        end
        
        if(isempty(inputcolor))
            color = stimulus_colormap(stimulus(i,3));
        else
            color = inputcolor;
        end
        
        if(~isempty(color) && ~isnan(sum(xpoints)))
            fillhandle=fill(xpoints,ypoints,color);
            set(fillhandle,'EdgeColor','none');
        end
        
        % dot_fill(xpoints,ypoints, color, 50, 100);
        
    end
end

hold off;

return;
