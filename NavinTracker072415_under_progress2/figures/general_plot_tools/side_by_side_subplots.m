function side_by_side_subplots(handle_A, handle_B, xlim, ylim, dist )
% side_by_side_subplots(handle_A, handle_B, xlim, ylim, dist )
% moves plot with handle_B flush with the right side of plot with handle_A 

if(nargin<5)
    dist = 0.0075;
end

if(nargin<3)
    xlim = [];
end

if(~isempty(xlim))
    set(handle_A,'xlim',xlim);
    set(handle_B,'xlim',xlim);
end

if(nargin<4)
    ylim = [];
end

if(isempty(ylim))
    ylimA = get(handle_A, 'ylim');
    ylimB = get(handle_B, 'ylim');
    ylim = [ min(ylimA(1), ylimB(1)) max(ylimA(2), ylimB(2)) ];
end

set(handle_A,'ylim',ylim);
set(handle_B,'ylim',ylim);

set(handle_A,'box','off'); % removes left and top axis lines

set(handle_B,'YAxisLocation','right'); 
set(handle_B,'YTick',[]); % removes axis numbering
set(handle_B,'YColor','w'); % removes axis itself by coloring it white
ylabel('');
set(handle_B,'box','off');

posA = get(handle_A, 'position');
set(handle_B, 'position',[(posA(1)+posA(3)+dist), posA(2), posA(3), posA(4)]);

return;
end
