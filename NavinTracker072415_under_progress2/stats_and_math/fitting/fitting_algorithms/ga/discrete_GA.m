function [m, bestscore] = discrete_GA(varargin)
% function [m, bestscore] = discrete_GA(funfcn, m_choice, tol, display_flag)
% usage [m, bestscore] = discrete_GA(@(m) myfunction(m), m_choice, display_flag);
% m0 for each variable must list the permitted values for that variable

global GA_prefs;
GA_prefs=[];

[funfcn, GA_prefs.tol, display_flag, m_choice, GA_prefs.m_length, m1] = parse_inputs_discrete_optimization(varargin);

GA_prefs.popsize = 100;
GA_prefs.mutfreq = 0.05;

t=[];
for(i=1:20)
    m = [];
    for(j=1:GA_prefs.m_length)
        m = [m  m_choice{j}(randint(length(m_choice{j})))];
    end
    tic;
    funfcn(m);
    t = [t toc];
end
time_per_eval = nanmean(t);


GA_prefs.mutfreq = max(GA_prefs.mutfreq,(1/GA_prefs.m_length)/2);
GA_prefs.basal_mutfreq = GA_prefs.mutfreq;

GA_prefs.popsize = min(GA_prefs.popsize,10*GA_prefs.m_length);
GA_prefs.conv_cycles = max(50, GA_prefs.m_length);



% rank-based mating freq
matfreq_vector=[];
for(i=1:GA_prefs.popsize)
    matfreq_vector = [matfreq_vector (GA_prefs.popsize-i+1)];
end
matfreq_denom = sum(matfreq_vector);
for(i=1:GA_prefs.popsize)
    matfreq_vector(i) = matfreq_vector(i)/matfreq_denom;
end

mating_probab(1) = matfreq_vector(1);
for(i=2:GA_prefs.popsize)
    mating_probab(i) = matfreq_vector(i) + mating_probab(i-1);
end

% initialize population
for(i=1:2*GA_prefs.popsize)
    
    for(j=1:GA_prefs.m_length)
        chr(i).m(j) = m_choice{j}(randint(length(m_choice{j})));
    end
    chr(i).score = funfcn(chr(i).m);
end
if(~isempty(m1))
    chr(1).m = m1;
    chr(1).score = funfcn(chr(1).m);
end

% sort initial population
score_vector=[];
for(i=1:2*GA_prefs.popsize)
    score_vector = [score_vector chr(i).score];
end
[s, idx] = sort(score_vector);
score_vector = score_vector(idx);
chr = chr(idx);

% ensure that each member of the population is unique
all_unique_flag=0;
GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
while(all_unique_flag==0)
    all_unique_flag=1;
    for(i=1:2*GA_prefs.popsize)
        dd = find(abs(chr(i).score-score_vector)<1e-5);
        dd(dd==i)=[];
        while(~isempty(dd))
            
            t_idx = dd(end);
            
            all_unique_flag=0;
            GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
            while(abs(score_vector(t_idx) - chr(t_idx).score)<1e-5)
                chr(t_idx) = mutate(chr(t_idx), m_choice);
                chr(t_idx).score = funfcn(chr(t_idx).m);
                GA_prefs.mutfreq = 10*GA_prefs.mutfreq;
            end
            
            score_vector(t_idx) = chr(t_idx).score;
            dd(end)=[];
            
        end
    end
    [s, idx] = sort(score_vector);
    score_vector = score_vector(idx);
    chr = chr(idx);
end
GA_prefs.mutfreq = GA_prefs.basal_mutfreq;


numGen=0;
num_conv_cycles=0;
prev_score=chr(1).score;
while(num_conv_cycles <= GA_prefs.conv_cycles)
    numGen = numGen+1;
    
    % disp([num2str(numGen),' ', num2str(chr(1).score),' ', timeString(),' ',num2str(chr(1).m)]);
    
    % mating and mutating
    for(i=(GA_prefs.popsize+1):(2*GA_prefs.popsize))
        parentA_idx = roll_loaded_dice(mating_probab);
        parentB_idx = roll_loaded_dice(mating_probab);
        while(parentB_idx == parentA_idx)
            parentB_idx = roll_loaded_dice(mating_probab);
        end
        chr(i) =  mate(chr(parentA_idx), chr(parentB_idx), funfcn, m_choice);
    end
    
    
    % sort chr
    score_vector=[];
    for(i=1:2*GA_prefs.popsize)
        score_vector = [score_vector chr(i).score];
    end
    [s, idx] = sort(score_vector);
    score_vector = score_vector(idx);
    chr = chr(idx);
    
    % check for uniqueness
    all_unique_flag=0;
    GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
    while(all_unique_flag==0)
        all_unique_flag=1;
        for(i=1:2*GA_prefs.popsize)
            dd = find(abs(chr(i).score-score_vector)<1e-5);
            dd(dd==i)=[];
            while(~isempty(dd))
                t_idx = dd(end);
                
                all_unique_flag=0;
                GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
                while(abs(score_vector(t_idx) - chr(t_idx).score)<1e-5)
                    chr(t_idx) = mutate(chr(t_idx), m_choice);
                    chr(t_idx).score = funfcn(chr(t_idx).m);
                    GA_prefs.mutfreq = 10*GA_prefs.mutfreq;
                end
                
                score_vector(t_idx) = chr(t_idx).score;
                dd(end)=[];
            end
        end
        [s, idx] = sort(score_vector);
        score_vector = score_vector(idx);
        chr = chr(idx);
    end
    GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
    
    % convergence check
    if(~are_these_equal(prev_score,chr(1).score,1e-5))
        num_conv_cycles=0;
        GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
        if(display_flag==1)
            disp([num2str(numGen),' ', num2str(chr(1).score),' ', timeString(),' ',num2str(chr(1).m)]);
        end
    else
        num_conv_cycles=num_conv_cycles+1; % increase mutation freq
    end
    
    prev_score = chr(1).score;
    
end

m = chr(1).m;
bestscore = funfcn(chr(1).m);

binary_flag=1;
for(i=1:length(m_choice))
    for(j=1:length(m_choice{i}))
        if(m_choice{i}(j) ~= 0)
            if(m_choice{i}(j) ~= 1)
                if(m_choice{i}(j) ~= -1)
                    binary_flag = 0;
                    break;
                end
            end
        end
    end
end


[m, bestscore] = discrete_HQM(@(m) funfcn(m), m, m_choice);

if(binary_flag == 0)
    [m, bestscore] = discrete_HQM(@(m) funfcn(m), m);
    % local min for final solution
    fminsearchoptions = optimset('Display','off');
    [m, bestscore] = fminsearch(@(m) funfcn(m), m,fminsearchoptions);
end

return;
end


function new_chr = mate(chrA, chrB, funfcn, m_choice)

global GA_prefs;


new_chr = chrA;
for(i=1:GA_prefs.m_length)
    if(rand<0.5)
        new_chr.m(i) = chrB.m(i);
    end
end
new_chr = mutate(new_chr, m_choice);
new_chr.score = funfcn(new_chr.m);

return;
end

function mutated_chr = mutate(chr, m_choice)

global GA_prefs;

mutated_chr = chr;

mut_vec = rand(1,GA_prefs.m_length);
idx = find(mut_vec < GA_prefs.mutfreq); % positions to mutate

if(~isempty(idx))
    
    for(j=1:length(idx))
        i = idx(j);
        
        mutated_chr.m(i) = m_choice{i}(randint(length(m_choice{i})));
        
    end
end


return;
end


