
function result = hist2_normalised(vx, vy, dx, dy)

xmax = max(vx); ymax = max(vy);
nx = ceil((xmax) / dx); ny = ceil((ymax) / dy);

result = zeros(nx,ny);
binx = ceil(vx ./ dx); biny = ceil(vy ./ dy);

binx(find(binx==0))=1;
biny(find(biny==0))=1;

n = min(length(vx),length(vy));

for i = 1:n
    if ~isnan(binx(i)*biny(i))
        result(binx(i),biny(i)) = result(binx(i),biny(i))+1;
    end
end

result = normalise(result);

if nargout == 0
    imagesc((1:size(result,2))*dy,(1:size(result,1))*dx,result);
    cmap = [1 1 1; jet(254)];
    colormap(cmap);
    axis xy;
    
    result = [];
end