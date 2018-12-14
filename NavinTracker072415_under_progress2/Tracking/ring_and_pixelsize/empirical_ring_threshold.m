function outputlevel = empirical_ring_threshold(global_background, ring_area_limits)

global Prefs;

outputlevel = [];

if(nargin<2)
    ring_area_limits = [];
end

if(isempty(ring_area_limits))
    MinCopperRingArea = Prefs.MinCopperRingArea/(Prefs.DefaultPixelSize)^2;
    MaxCopperRingArea = Prefs.MaxCopperRingArea/(Prefs.DefaultPixelSize)^2;
else
    MinCopperRingArea = ring_area_limits(1)/(Prefs.DefaultPixelSize)^2;
    MaxCopperRingArea = ring_area_limits(2)/(Prefs.DefaultPixelSize)^2;
end


b = double(matrix_to_vector(global_background))/255; % convert to grayscale between 0 and 1
[y,x] = hist(b,sqrt(length(b)));
y = y./nansum(y);

y_gt_0 = find(y>0); % consider only bins with non-zero populations

if(isempty(y_gt_0))
    return;
end

x2 = x(y_gt_0); y2 = y(y_gt_0);

tr = [0.2 0.1 0.3 0.4];

for(i=1:length(tr))
    
    thresh = tr(i);
    
    x_lt_02 = find(x2<thresh);
    
    if(~isempty(x_lt_02))
        x3 = x2(x_lt_02); y3 = y2(x_lt_02); % the major peak is >thresh
        [~,y_peak_index] = max(y3);
        if(~isempty(y_peak_index))
            y_peak_index = y_peak_index(1);
            % find the peak value for the near-zero pixel intensity peak
            x_lt_02_y_max = find(x3 > x3(y_peak_index));
            if(~isempty(x_lt_02_y_max))
                x4 = x3(x_lt_02_y_max); y4 = y3(x_lt_02_y_max);
                [~,index] = min(y4);
                if(~isempty(index))
                    
                    level =  mean(x4(index));
                    
                    RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, level), 'descend'), {'Area','Image'});
                    
                    ring_index = find([RINGSTATS.Area] >= MinCopperRingArea & [RINGSTATS.Area] <= MaxCopperRingArea);
                    if(length(ring_index)==1) % potential ring  found
                        outputlevel = [outputlevel level];
                        stopflag=1;
                    else
                        stopflag=0;
                        if(length(RINGSTATS)==1)
                            outputlevel = [outputlevel level];
                            stopflag=1;
                        end
                    end
                    
                    while(stopflag == 0)
                        level = level + 0.005;
                        if(level>(thresh/2 + 0.05))
                            stopflag = 1;
                        end
                        
                        RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, level), 'descend'), {'Area','Image'});
                        
                        ring_index = find([RINGSTATS.Area] >= MinCopperRingArea & [RINGSTATS.Area] <= MaxCopperRingArea);
                        
                        if(length(ring_index)==1) % potential ring  found
                            outputlevel = [outputlevel level];
                            stopflag=1;
                        end
                        
                        if(length(RINGSTATS)==1)
                            outputlevel = [outputlevel level];
                            stopflag=1;
                        end
                        
                    end
                end
            end
        end
    end
end

outputlevel = [outputlevel graythresh(global_background)];
outputlevel(outputlevel<0.05)=[];

outputlevel = unique(outputlevel);

if(~isempty(outputlevel))
    return;
end

% still no ring ... let's make sure that it's not a small ring or a huge ring ...
for(i=1:length(tr))
    
    thresh = tr(i);
    
    x_lt_02 = find(x2<thresh);
    
    if(~isempty(x_lt_02))
        x3 = x2(x_lt_02); y3 = y2(x_lt_02); % the major peak is >thresh
        [~,y_peak_index] = max(y3);
        y_peak_index = y_peak_index(1);
        if(~isempty(y_peak_index))
            % find the peak value for the near-zero pixel intensity peak
            x_lt_02_y_max = find(x3 > x3(y_peak_index));
            if(~isempty(x_lt_02_y_max))
                x4 = x3(x_lt_02_y_max); y4 = y3(x_lt_02_y_max);
                [~,index] = min(y4);
                if(~isempty(index))
                    level =  mean(x4(index));
                    
                    
                    RINGSTATS = custom_regionprops(bwconncomp_sorted(~im2bw(global_background, level), 'descend'), {'Area','Image'});
                    
                    if(~isempty([RINGSTATS.Area]))
                        if( (  (max([RINGSTATS.Area])) >= (MinCopperRingArea*0.5) ) && ...
                                (  (max([RINGSTATS.Area])) <= (MaxCopperRingArea*1.5)   )   )
                            MinCopperRingArea = MinCopperRingArea*0.25;
                            MaxCopperRingArea = MaxCopperRingArea*1.5;
                            ring_index = find([RINGSTATS.Area] >= MinCopperRingArea & [RINGSTATS.Area] <= MaxCopperRingArea);
                        end
                        
                        if(length(ring_index)==1) % potential ring  found
                            outputlevel = [outputlevel level];
                        end
                        
                    end
                    
                end
            end
        end
    end
end

outputlevel = unique(outputlevel);

return;
end

