function mseq_pulse_seq(baseVal, powerVal, stepsize)

ms = mseq(baseVal,powerVal);

% -1 = off
%  1 = on

FilePrefix = sprintf('mseq.%d.%d.%.2f.pulse',baseVal,powerVal,stepsize);

stimulusfile = sprintf('%s.txt',FilePrefix);
fp = fopen(stimulusfile,'w');

fprintf(fp,'off\t100\tsec\t1\n');

i=1;
while(i<=length(ms))
    
    q = ms(i); 
    j=1;
    while(q == ms(i))
        i=i+1;
        if(i>length(ms))
            break;
        end
        if(q==ms(i))
            j=j+1;
        end    
    end
    
    if(q<=-1)
        on_off = sprintf('off');
    else
        on_off = sprintf('on');
    end
    
    fprintf(fp,'%s\t%.2f\tsec\t1\n',on_off, stepsize*abs(j));
    
end

fprintf(fp,'off\t100\tsec\t1\n');

fclose(fp);


stimulus = txt_to_stim(stimulusfile);



return;

