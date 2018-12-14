function chemotaxis_multiple_plates(picture_filename, plate_type)

if(nargin<2)
    plate_type = 'round';
end

if(nargin == 0) % running in interactive mode... no arguments given.... ask the user for the MovieName
    cd(pwd);
    
    [picture_filename, pathname] = uigetfile(...
        {'*.tif;*.tiff;*.png;*.jpeg;*.jpg', 'image Files (*.tif;*.tiff;*.png;*.jpeg;*.jpg)'; '*.*',  'All Files (*.*)' }, ...
        'Select scanned image file for analysis');
    
    if(isempty(picture_filename))
        errordlg('No image file was selected for analysis');
        return;
    end
    
    picture_filename = sprintf('%s%s%s',pathname,picture_filename);
end

input_background = imread(picture_filename);

are_we_done_answer(1)='N';
while(are_we_done_answer(1)=='N')
    
    ss=1;
    more_arenas_answer(1)='Y';
    while(more_arenas_answer(1)=='Y')
        
        answer(1) = 'N';
        while answer(1) == 'N'
            
            hold off;
            imshow(input_background);
            hold on;
            for(v=1:ss-1)
               text(arena_center{v}(1), arena_center{v}(2), arena_name{v},'color','g');
            end
            F = getframe(gcf);
            background = frame2im(F);
            close all
            
            [arena{ss}, arena_rect{ss}] = imcrop(background);
            arena_center{ss} = [(arena_rect{ss}(2) + arena_rect{ss}(4)/2) (arena_rect{ss}(1) + arena_rect{ss}(3)/2)];
            arena_center{ss} 

            hold on;
            rectangle('position',arena_rect{ss},'edgecolor','w');
            
            pause
            
            answer = questdlg('Is the arena properly defined?', 'Is the arena properly defined?', 'Yes', 'No', 'Yes');
            
        end
        
        arena_name{ss} = char(inputdlg('What is the plate name?'));
        
        
        more_arenas_answer = questdlg('Manually define more arenas?', 'Manually define more arenas?', 'Yes', 'No', 'Yes');
        ss=ss+1;
    end
    
    are_we_done_answer = questdlg('Arenas defined properly?', 'Arenas defined properly?', 'Yes', 'No', 'Yes');
    
end

close all;


for(i=1:length(arena))
    chemtax.CI(i) = chemotaxis({arena{i}, arena_name{i}}, plate_type);
    chemtax.name = arena_name{i};
end

return;
end
