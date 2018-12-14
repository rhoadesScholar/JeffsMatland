function trim_legend_lines(hL, dont_trim_right_flag)

if(nargin<2)
    dont_trim_right_flag=0;
end

% find handle of line inside legend
hLegendline = findobj(hL, 'type', 'line');

for(leg_i = 1:length(hLegendline))
    xd=get(hLegendline(leg_i), 'XData');
    if(length(xd)==2)
        dx = (xd(2)-xd(1))/2;
        if(dont_trim_right_flag==0)
            dx = (xd(2)-xd(1))/4;
            xd(2) = xd(2)-dx;
        end
        
        xd(1) = xd(1)+dx; 
        
        set(hLegendline(leg_i), 'XData',xd);
    end
end


% find handle of patch inside legend
hLegendPatch = findobj(hL, 'type', 'patch');
for(leg_i = 1:length(hLegendPatch))
    xd=get(hLegendPatch(leg_i), 'XData');
    if(length(xd)>=4)
        dx = (max(xd)-min(xd))/2;
        
        if(dont_trim_right_flag==0)
            dx = (max(xd)-min(xd))/4;
            xd(xd==max(xd)) = xd(xd==max(xd))-dx;
        end
        
        xd(xd==min(xd)) = xd(xd==min(xd))+dx;
        
        set(hLegendPatch(leg_i), 'XData',xd);
    end
    xd=get(hLegendPatch(leg_i), 'XData');
end


return;
end
