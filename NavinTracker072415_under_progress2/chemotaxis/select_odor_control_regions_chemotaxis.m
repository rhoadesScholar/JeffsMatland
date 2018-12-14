function [target_verticies, target_point, control_verticies, control_point] = select_odor_control_regions_chemotaxis(background, target_only_flag)

if(nargin<2)
    target_only_flag=0;
end

target_verticies=[]; target_point=[]; control_verticies=[]; control_point=[];

questdlg(sprintf('%s\n%s','Select polygon verticies around target region','Doubleclick for single point'), ...
    'Select target region', 'OK', 'OK');

all_good_flag = 'N';

while(all_good_flag(1) == 'N')
    
    region_selected_flag='Re-select';
    ctr=0;
    while(region_selected_flag(1)=='R')
        if(mod(ctr,2)==0)
            [BW, x,y] = roipoly(background); % roipoly(adapthisteq(background,'Distribution','exponential'));
        else
            [BW, x,y] = roipoly(adapthisteq(background,'Distribution','exponential'));
        end
        target_verticies = [x y];
        if(length(x)==1)
            target_point = target_verticies;
        else
            target_point = nanmean(target_verticies);
        end
        
        imshow(background);
        hold on;
        plot(target_point(1), target_point(2),'og');
        hold on;
        if(~isempty(target_verticies))
            plot(target_verticies(:,1), target_verticies(:,2),'g');
        end
        
        region_selected_flag = questdlg('Is the target region selected correctly?', ...
            'Select target region', 'Re-select', 'OK', 'OK');
        ctr = ctr+1;
    end
    
    
    if(target_only_flag==0)
        
        answer = questdlg(sprintf('%s\n%s\n','Select polygon verticies around control region','Doubleclick for single point','Click "None" if there is no control region'), ...
            'Select control region', 'OK', 'None', 'OK');
        
        if(answer(1) == 'O')
            
            region_selected_flag='Re-select';
            ctr=0;
            while(region_selected_flag(1)=='R')
                if(mod(ctr,2)==0)
                    [BW, x,y] = roipoly(background); % roipoly(adapthisteq(background,'Distribution','exponential'));
                else
                    [BW, x,y] = roipoly(adapthisteq(background,'Distribution','exponential'));
                end
                control_verticies = [x y];
                if(length(x)==1)
                    control_point = control_verticies;
                else
                    control_point = nanmean(control_verticies);
                end
                
                imshow(background);
                hold on;
                plot(control_point(1), control_point(2),'or');
                hold on;
                if(~isempty(control_verticies))
                    plot(control_verticies(:,1), control_verticies(:,2),'r');
                end
                
                region_selected_flag = questdlg('Is the control region selected correctly?', ...
                    'Select control region', 'Re-select', 'OK', 'OK');
                ctr = ctr+1;
            end
            
            
            
        end
    end
    
    close all
    imshow(background);
    hold on;
    plot(target_point(1), target_point(2),'og');
    hold on;
    if(~isempty(target_verticies))
        plot(target_verticies(:,1), target_verticies(:,2),'g');
    end
    hold on;
    if(~isempty(control_verticies))
        plot(control_point(1), control_point(2),'or');
        hold on;
        plot(control_verticies(:,1), control_verticies(:,2),'r');
    end
    
    all_good_flag = questdlg('Are the regions selected correctly?', ...
        'Select regions', 'No', 'OK', 'OK');
    
end

clear('BW');
clear('x'); clear('y');

return;
end
