function sfplotdistr(vect)
    minimumdur = ceil(min(vect));
    maximumdur = floor(max(vect));
    
    numObserv = length(vect);
    alldata = [];
    xaxis = minimumdur:1:maximumdur;
    a=1;
    for (i = xaxis)
        alldata(a) = length(find(vect>=i));
        a=a+1;
    end
    scatter(xaxis,alldata)
end
