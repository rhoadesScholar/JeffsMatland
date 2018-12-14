function stderr = getStdev(speedmatrix)
    for (i=1:30)
        data = speedmatrix(:,i);
        data = data(~isnan(data));
        display(length(data));
        stdev = std(data);
        stderr(i) = stdev/sqrt(length(data));
    end
end
