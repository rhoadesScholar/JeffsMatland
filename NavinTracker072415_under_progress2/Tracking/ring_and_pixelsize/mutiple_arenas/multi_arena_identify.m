function Ring = multi_arena_identify(inputbackground, Ring)

are_we_done_answer(1)='N';
Ring.ring_mask = uint8(zeros(size(inputbackground,1), size(inputbackground,2)));

while(are_we_done_answer(1)=='N')
    
    background = inputbackground;
    
    imshow(background);
    
    ss=1;
    more_arenas_answer(1)='Y';
    while(more_arenas_answer(1)=='Y')
        
        answer(1) = 'N';
        while answer(1) == 'N'
            
            hold off
            imshow(background);
            hold on;
            plot(Ring.RingX, Ring.RingY,'r');
            
            [RingX, RingY] = roi_perimeter(background);
            
            for(p=1:length(RingX))
                if(mod(p,2)==0)
                    background(RingY(p),RingX(p)) = 0;
                else
                    background(RingY(p),RingX(p)) = 255;
                end
            end
            
            hold off
            imshow(background);
            hold on;
            plot(RingX, RingY,'r');
            
            ComparisonArrayX = ones([length(RingX) 1]);
            ComparisonArrayY = ones([length(RingY) 1]);
            
            answer = questdlg('Is the arena properly defined?', 'Is the arena properly defined?', 'Yes', 'No', 'Yes');
            
        end
        
        Ring.arena_name{ss} = char(inputdlg('What is the strain name?'));
        Ring.arena_name{ss} = sprintf('%s.%d',Ring.arena_name{ss}, ss);
        Ring.arena_center(ss,:) = [nanmean(RingX) nanmean(RingY)];
        
        Ring.RingX = [Ring.RingX; RingX];
        Ring.RingY = [Ring.RingY; RingY];
        Ring.ComparisonArrayX = [Ring.ComparisonArrayX; ComparisonArrayX];
        Ring.ComparisonArrayY = [Ring.ComparisonArrayY; ComparisonArrayY];
        
        ring_mask = uint8(poly2mask(RingX, RingY, size(inputbackground,1), size(inputbackground,2)));
        Ring.ring_mask = Ring.ring_mask + ring_mask;
        
        clear('RingX');
        clear('RingY');
        clear('ComparisonArrayX');
        clear('ComparisonArrayY');
        clear('ring_mask');
        
        imshow(background);
        hold on;
        plot(Ring.RingX, Ring.RingY,'.r','markersize',1);
        for(t=1:length(Ring.arena_name))
            text(Ring.arena_center(t,1), Ring.arena_center(t,2), fix_title_string(Ring.arena_name{t}), 'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center','color','r');
        end
        
        more_arenas_answer = questdlg('Manually define more arenas?', 'Manually define more arenas?', 'Yes', 'No', 'Yes');
        ss=ss+1;
    end
    
    are_we_done_answer = questdlg('Arenas defined properly?', 'Arenas defined properly?', 'Yes', 'No', 'Yes');
    
end

close all;

return;
end
