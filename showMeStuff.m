function showMeStuff(tracks)

angSp = [tracks.AngSpeed];%abs()?
headErr = [tracks.headingError];
lawnD = [tracks.lawnDist];

angSp = angSp(~isnan(headErr) && ~isnan(angSp) && ~isnan(lawnD));
headErr = headErr(~isnan(headErr) && ~isnan(angSp) && ~isnan(lawnD));
lawnD = lawnD(~isnan(headErr) && ~isnan(angSp) && ~isnan(lawnD));

% [X, Y, Z] = meshgrid(headErr, angSp, lawnD);

x = 0;

figure; hold on;
xlabel('Lawn Distance');
ylabel('Speed');
zlabel('Heading Error');
for w = 1:length(tracks)
    fin = tracks(w).refeedIndex;
    scatter3(tracks(w).lawnDist(1:fin), tracks(w).Speed(1:fin), tracks(w).headingError(1:fin), '.', 'MarkerEdgeColor', 'b');
    pause;
end

end

[X, Y, Z] = prepareSurfaceData([newPool.N2.lawnDist], [newPool.N2.Speed], [newPool.N2.headingError]);
f = fit([X, Y], Z, 'poly35');%, 'Normalize', 'on');
figure; hold on;
title(sprintf('N2, n = %i', length(pool.N2)));
xlabel('Lawn Distance');
zlabel('Heading Error');
ylabel('Speed');
plot(f)
colormap jet
colorbar

%%%%%

figure;
title(sprintf('N2, n = %i', length(pool.N2)));
xlabel('Lawn Distance');
ylabel('Heading Error');
zlabel('Speed');
[xs, ys] = meshgrid(1:360, 1:)
insie = interp2(, xs, ys, 'cubic')
surf(insie)

%%%%%%%%
for w = 1:length(pool.N2)
    newPool.N2(w).lawnDist = pool.N2(w).lawnDist(1:pool.N2(w).refeedIndex);
    newPool.N2(w).headingError = pool.N2(w).headingError(1:pool.N2(w).refeedIndex);
    newPool.N2(w).Speed = pool.N2(w).Speed(1:pool.N2(w).refeedIndex);
end