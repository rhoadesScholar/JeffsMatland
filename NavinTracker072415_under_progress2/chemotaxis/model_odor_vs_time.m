function model_odor_vs_time

global Prefs;
Prefs = define_preferences(Prefs);

% location of odor spot
x0 = 10; % in mm
y0 = Prefs.circular_chemotaxis_plate_diameter/2;
dz = Prefs.chemotaxis_lid_height;
D = Prefs.model_diffusion_const;

spatial_stepsize = 1;

dimen = spatial_stepsize:spatial_stepsize:Prefs.circular_chemotaxis_plate_diameter;

t0 = 60;
tstep = 60;
tend = 30*60;

mask = zeros(length(dimen),length(dimen))+1e10;
for(i=1:size(mask,1))
    for(j=1:size(mask,2))
        if( (i-Prefs.circular_chemotaxis_plate_diameter/2)^2 + (j-Prefs.circular_chemotaxis_plate_diameter/2)^2 < (Prefs.circular_chemotaxis_plate_diameter/2)^2 )
            mask(i,j)=1;
        end
    end
end

max_origin_conc = model_odor_conc(Prefs.circular_chemotaxis_plate_diameter/2-x0, tend);

max_origin_conc


tempfilename = sprintf('%s.avi',tempname);
tempfilename
aviobj = VideoWriter(tempfilename);
aviobj.Quality = 100;
open(aviobj);

maxes = []; means=[]; origin_conc = [];
for(t=t0:tstep:tend)
    C = zeros(length(dimen),length(dimen));
    for(i = 1:length(dimen))
        for(j = 1:length(dimen))
            x = dimen(i);
            y = dimen(j);
            r = sqrt((x0 - x)^2 + (y0 - y)^2 ); % + dz^2 if odor on lid
            C(i,j) = model_odor_conc(r, t);
        end
    end
    if(t==t0)
        maxC = max(max(C));
    end
    maxes = [maxes max(max(C))];
    means = [means mean(matrix_to_vector(C))];
    origin_conc = [origin_conc model_odor_conc(Prefs.circular_chemotaxis_plate_diameter/2-x0, t)];
    figure(1);
    subplot(1,2,1);
        image(255.*mask.*(C./maxC)); 
        hold on
        plot(length(dimen)/2, length(dimen)/2, 'ow');
        plot(y0, x0, 'xw');
        colormap hot
        hold off
        axis off
        axis square
        set(gcf,'color','w');
    title(sprintf('%.1f min %f',t/60, origin_conc(end)));
    subplot(1,2,2);
    plot([t0:tstep:t]./60,origin_conc,'o');
    xlim([0 tend/60]); ylim([0 custom_round(max_origin_conc, 0.005)])
    xlabel('Time (min)');
    ylabel('Relative odor conc');
    box off
    axis square
    % pause(0.01)
    
    F = getframe(gcf);
    writeVideo(aviobj,F);
    
    close(1);
end

close(aviobj);

figure(2);
subplot(1,2,1); plot([t0:tstep:tend]./60,maxes,'o');
subplot(1,2,2); plot([t0:tstep:tend]./60,origin_conc,'o');

return;
end
