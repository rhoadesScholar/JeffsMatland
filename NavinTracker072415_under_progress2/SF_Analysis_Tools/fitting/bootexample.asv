
bootstrapnum = 100;

experiments = size(data,2);

values = zeros(bootstrapnum,1);

for m=1:bootstrapnum
    randnum = ceil(experiments*rand(1,experiments));
    newmatrix = data(:,randnum);
    vector = newmatrix(:);
    values(m) = yourfunction(vector);
end

meanvalues = mean(values);
sdvalues = std(values);


%columns = expt
%