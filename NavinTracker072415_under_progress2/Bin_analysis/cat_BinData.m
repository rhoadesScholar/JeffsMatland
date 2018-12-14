% some problems with the propagation of errors by this function

function BinData = cat_BinData(inputA, inputB)

epsilon = 0.0001;

BinData = initialize_BinData;
Q = initialize_BinData;

[instantaneous_fieldnames, freq_fieldnames] = get_BinData_fieldnames(inputA);


if(length(inputA.time) > length(inputB.time))
    A = inputA;
    B = inputB;
else
    A = inputB;
    B = inputA;
end

time = [A.time B.time];
[time, idx] = sort(time);

len_A_time = length(A.time);
len_B_time = length(B.time);
len_time = length(time);

i=1;
k=1;
a=1;
b=1;
while(k<=len_time)
    BinData.time(i) = time(k);

    if(a<len_A_time)
        while(A.time(a)<BinData.time(i))
            a=a+1;
            if(a>=len_A_time)
                a=len_A_time;
                break;
            end
        end
    end
    if(b<len_B_time)
        while(B.time(b)<BinData.time(i))
            b=b+1;
            if(b>=len_B_time)
                b=len_B_time;
                break;
            end
        end
    end

    if(abs(A.time(a) - BinData.time(i))<=epsilon && abs(B.time(b) - BinData.time(i))<=epsilon) % both A and B
        D = A; d=a;
        E = B; e=b;
    else
        if(abs(A.time(a) - BinData.time(i))<=epsilon) % just A
            D = A; d=a;
            E = Q; e=1;
        else % just B
            D = B; d=b;
            E = Q; e=1;
        end
    end

    BinData.n(i) = D.n(d) + E.n(e); % number of animals
    BinData.n_fwd(i) = D.n_fwd(d) + E.n_fwd(e);
    BinData.num(i) = D.num(d); % number of frames is the same
    BinData.n_rev(i) = D.n_rev(d) + E.n_rev(e);
    
    % weighted averages of the same quantity in the same bin
    for(f=1:length(instantaneous_fieldnames))
        BinData = weighted_stats(BinData,i,D,E,d,e,instantaneous_fieldnames{f},D.num(d),E.num(e));
    end
    
    clear('D');
    clear('E');

    while(BinData.time(i) == time(k))
        k=k+1;
        if(k>=len_time)
            break;
        end
    end
    i=i+1;
end

clear('time');


freqtime = [A.freqtime B.freqtime];
[freqtime, idx] = sort(freqtime);

len_A_freqtime = length(A.freqtime);
len_B_freqtime = length(B.freqtime);
len_freqtime = length(freqtime);

i=1;
k=1;
a=1;
b=1;
while(k<=len_freqtime)

    % find indicies where A.time and B.time are == time(k)
    BinData.freqtime(i) = freqtime(k);
    if(a<len_A_freqtime)
        while(A.freqtime(a)<BinData.freqtime(i))
            a=a+1;
            if(a>=len_A_freqtime)
                a=len_A_freqtime;
                break;
            end
        end
    end
    if(b<len_B_freqtime)
        while(B.freqtime(b)<BinData.freqtime(i))
            b=b+1;
            if(b>=len_B_freqtime)
                b=len_B_freqtime;
                break;
            end
        end
    end

    % freqtime bins
    if(abs(A.freqtime(a) - BinData.freqtime(i))<=epsilon && abs(B.freqtime(b) - BinData.freqtime(i))<=epsilon) % both A and B
        D = A; d=a;
        E = B; e=b;
    else
        if(abs(A.freqtime(a) - BinData.freqtime(i))<=epsilon) % just A
            D = A; d=a;
            E = Q; e=1;
        else % just B
            D = B; d=b;
            E = Q; e=1;
        end
    end

    BinData.n_freq(i) = D.n_freq(d) + E.n_freq(e); % number of animals
    BinData.numfreq(i) = D.numfreq(d); % number of frames is the same

    % weighted averages of the same quantity in the same bin
    for(f=1:length(freq_fieldnames))
        BinData = weighted_stats(BinData,i,D,E,d,e,freq_fieldnames{f},D.num(d),E.num(e));
    end
    
    clear('D');
    clear('E');

    while(BinData.freqtime(i) == freqtime(k))
        k=k+1;
        if(k>=len_freqtime)
            break;
        end
    end
    i=i+1;
end

clear('A');
clear('B');
clear('Q');
clear('freqtime');
clear('instantaneous_fieldnames');
clear('freq_fieldnames');

return;
end

% means, std dev, and errors weighted ... this function is probably not
% quite right!!!
function BinData = weighted_stats(BinData,i,D,E,d,e,field,nD,nE)

sigmafield = sprintf('%s_s',field);
errfield = sprintf('%s_err',field);

numD = nD;
numE = nE;

if(isnan(D.(field)(d)))
    numD = 0;
    D.(field)(d)=0;
    D.(sigmafield)(d)=0;
    D.(errfield)(d)=0;
end
if(isnan(E.(field)(e)))
    numE = 0;
    E.(field)(e)=0;
    E.(sigmafield)(e)=0;
    E.(errfield)(e)=0;
end

denom = numD + numE; 

BinData.(field)(i) = NaN;
BinData.(sigmafield)(i) = NaN;
BinData.(errfield)(i) = NaN;

if(denom~=0)
    BinData.(field)(i) = (numD*D.(field)(d) + numE*E.(field)(e))/denom; 
    BinData.(sigmafield)(i) = sqrt((numD*D.(sigmafield)(d))^2 + (numE*E.(sigmafield)(e))^2)/denom;  
    BinData.(errfield)(i) = sqrt((numD*D.(errfield)(d))^2 + (numE*E.(errfield)(e))^2)/denom; 
end

% if(isnan(BinData.(field)(i)))
%     BinData.(field)(i) = 0;
% end
% if(isnan(BinData.(sigmafield)(i)))
%     BinData.(sigmafield)(i)=0;
% end
% if(isnan(BinData.(errfield)(i)))
%     BinData.(errfield)(i)=0;
% end


return;
end