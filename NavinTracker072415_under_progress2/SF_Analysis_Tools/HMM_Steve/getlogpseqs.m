function logpseqs = getlogpseqs(TracksFile,estTRfile,estEfile)

    statemap = getStateAuto(TracksFile,30);

    statesHMM = [];
    for (i=1:length(TracksFile))
        
        newseq(i).states = statemap(i).state(2:(length(statemap(i).state)));
        if(~isnan(statemap(i).state(2)))
        else
            indexhere = isnan(newseq(i).states);
            replace = find(indexhere==1);
            display(max(replace))
            changeto = newseq(i).states(max(replace)+1);
            newseq(i).states(replace) = changeto;
            
        end
    end
    seqs = struct2cell(newseq);
    
    
    
    
    for (i = 1:length(statemap))
        [PSTATES,logpseq,FORWARD,BACKWARD,S] = hmmdecode(statemap(i).states,estTRfile,estEfile);
        logpseqs(i) = logpseq;
    end
end
