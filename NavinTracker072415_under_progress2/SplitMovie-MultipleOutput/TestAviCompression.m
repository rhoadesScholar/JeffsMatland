function TestAviCompression()
pwd
Methods = ['mrle'; 'msvc'; 'uyvy'; 'yuy2'; 'yvyu'; 'iyuv'; 'i420'; 'yvu9'; 'cvid'; 'iv50'; 'iv41'; 'iv31'; 'iv32'];
[w,l] = size(Methods);
for i = 13:13
    display(Methods(i,:));
    Filename = ['tempAvi-', Methods(i,:), '.avi'];
    createRandomAvi(Methods(i,:), Filename);
end
end