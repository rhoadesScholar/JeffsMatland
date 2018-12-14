function[fillhandle,msg]=errorshade(xpoints,upper,lower,color,transparency)

if(nargin<4)
    color='k'; %default color is black
end

if(ischar(color))
    color = str2rgb(color);
end

if(nargin<5)    %default is to have a transparency of 0.25
    transparency=0.2;
end 

% color(color==0) = 1-transparency;

if(size(xpoints,2)==1)
    xpoints = xpoints';
end

if(size(upper,2)==1)
    upper = upper';
end

if(size(lower,2)==1)
    lower = lower';
end

if length(upper)==length(lower) && length(lower)==length(xpoints)
    msg='';
    
if sum(isnan(upper)) > 0
    start = find(~isnan(upper), 1);
    fin = find(~isnan(upper), 1, 'last');
    xpoints = xpoints(start:fin);
    upper = upper(start:fin);
    lower = lower(start:fin);
    if ~isempty(find(isnan(upper),1))
        upper = fillmissing(upper, 'pchip');
    end
end

if sum(isnan(lower)) > 0
    if ~isempty(find(isnan(lower),1))
        lower = fillmissing(lower, 'pchip');
    end
end

    xpoints =[xpoints xpoints(end:-1:1) xpoints(1)];
    filled = [upper lower(end:-1:1) upper(1)];
    
%     idx = (~isnan(filled)); %non nans
%     filledr = filled(idx); %v non nan
%     filled2 = filledr(cumsum(idx)); %use cumsum to build index into vr
    
    
   fillhandle=fill(xpoints,filled,color); %plot the data
   if length(transparency) == 1
       set(fillhandle,'EdgeColor',color,'EdgeAlpha',transparency, 'FaceAlpha', transparency - 0.02);
   else
       try
           transparency = [transparency; transparency(end:-1:1); transparency(1)];
       catch
           transparency = [transparency, transparency(end:-1:1), transparency(1)];
       end
       set(fillhandle,'EdgeColor',color,'EdgeAlpha', 'interp', 'FaceAlpha', 'interp', 'FaceVertexAlphaData', transparency, 'AlphaDataMapping', 'none');
   end
   
   fillhandle.Annotation.LegendInformation.IconDisplayStyle = 'off';
 %   fillhandle=plot(xpoints,filled,'color',color);
   
    
    % set(fillhandle,'EdgeColor',color,'FaceAlpha',transparency,'EdgeAlpha',transparency);
    
    % dot_fill(xpoints,filled,color);
   
else
    msg='Error: Must use the same number of points in each vector';
end

