function pixel_density_in_target = CI_vs_time(moviename, t)

global Prefs; 
Prefs = []; Prefs = define_preferences(Prefs);

prefix = moviename(1:(end-4));
bkgnd = double(calculate_background(moviename));
fn = sprintf('%s.chemotaxis_regions.mat',prefix);
load(fn);
Ring = find_ring(moviename);
Prefs = CalcPixelSizeDependencies(Prefs,Ring.PixelSize);
[x,y] = coords_from_circle_params(2.5/Ring.PixelSize, [target_point(1) target_point(2)]);
mask = double(poly2mask(x, y, size(bkgnd,1), size(bkgnd,2)));

vols = [];
for(i=1:length(t))
    f = t(i)*3;
    Mov = aviread_to_gray(moviename,f);
    Movsubtract = mask.*max((bkgnd - double(Mov.cdata))./255, 0);
    
    vols = [vols sum(sum(Movsubtract))];
    
%     imagesc(Movsubtract);
%     hold on; 
%     plot(x,y,'k');
    
%     plot(t(i),vols(end),'-or');
%     xlim([0 t(end)]);
%     hold on;
end

pixel_density_in_target = (vols)/mean(vols);

plot(t/60, pixel_density_in_target, 'o-r');

return;
end
