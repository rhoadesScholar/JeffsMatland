function createRandomAvi(CompressionMethod, Filename)
Mov.colormap=[];
% Mov.cdata = [checkerboard(100), checkerboard(100), checkerboard(100)];

Obj = avifile(Filename, 'compression', CompressionMethod);
for i = 1:100
    Mov.cdata = [rand([100 100]), rand([100 100]), rand([100 100])]; 
    Obj = addframe(Obj, Mov);
end
Obj = close(Obj);

end