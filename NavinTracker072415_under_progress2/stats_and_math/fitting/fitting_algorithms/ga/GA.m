% function [m, bestscore] = GA(funfcn, m_limits, tol, display_flag)
% usage [m, bestscore] = GA(@(m) myfunction(m), m_limits, display_flag);

function [m, bestscore] = GA(varargin)

global GA_prefs;
GA_prefs=[];

[funfcn, GA_prefs.tol, display_flag, m_limits, GA_prefs.m_length, m1, bitsize, bit_signs, GA_prefs.bin_vec_length] = parse_inputs_binary_optimization(varargin);

t=[];
for(i=1:20)
    m = [];
    for(j=1:GA_prefs.m_length)
        m = [m bracketed_rand(m_limits(j,:))];
    end
    tic;
    funfcn(m);
    t = [t toc];
end
time_per_eval = nanmean(t);


GA_prefs.mutfreq = max(0.005,(1/GA_prefs.bin_vec_length)/2);
GA_prefs.basal_mutfreq = GA_prefs.mutfreq;

GA_prefs.popsize = min(500,10*GA_prefs.bin_vec_length); % GA_prefs.bin_vec_length*10;
GA_prefs.conv_cycles = max(50, GA_prefs.bin_vec_length); % GA_prefs.bin_vec_length;

% GA_prefs.popsize=GA_prefs.m_length;
% GA_prefs.conv_cycles=GA_prefs.m_length;

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
    
    chr(i).bin_vec = [];
    for(j=1:GA_prefs.m_length)
        chr(i).m(j) = bracketed_rand(m_limits(j,:));
    end
    % chr(i).m = custom_round(chr(i).m,GA_prefs.tol);
    chr(i).bin_vec = decimal_to_binary(chr(i).m, bitsize);
    
    chr(i).score = funfcn(chr(i).m);
end
if(~isempty(m1))
    chr(1).m = m1;
    chr(1).bin_vec = decimal_to_binary(chr(1).m, bitsize);
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


all_unique_flag=0;
while(all_unique_flag==0)
    all_unique_flag=1;
    for(i=1:2*GA_prefs.popsize)
        dd = find(abs(chr(i).score-score_vector)<1e-5);
        dd(dd==i)=[];
        while(~isempty(dd))
            
            t_idx = dd(end);
            
            all_unique_flag=0;
            while(abs(score_vector(t_idx) - chr(t_idx).score)<1e-5)
                chr(t_idx) = mutate(chr(t_idx), bit_signs, bitsize);
                chr(t_idx).score = funfcn(chr(t_idx).m);
            end
            score_vector(t_idx) = chr(t_idx).score;
            dd(end)=[];
            
        end
    end
    [s, idx] = sort(score_vector);
    score_vector = score_vector(idx);
    chr = chr(idx);
end

numGen=0;
num_conv_cycles=0;
prev_score=chr(1).score;
while(num_conv_cycles <= GA_prefs.conv_cycles)
    numGen = numGen+1;
    
%     % randomize the bottom half of the population
%     for(i=(ceil(0.5*GA_prefs.popsize)):GA_prefs.popsize)
%         chr(i).bin_vec = [];
%         for(j=1:GA_prefs.m_length)
%             chr(i).m(j) = bracketed_rand(m_limits(j,:));
%         end
%         % chr(i).m = custom_round(chr(i).m,GA_prefs.tol);
%         chr(i).bin_vec = decimal_to_binary(chr(i).m, bitsize);
%         chr(i).score = funfcn(chr(i).m);
%     end
    
    % mating and mutating
    for(i=(GA_prefs.popsize+1):(2*GA_prefs.popsize))
        parentA_idx = roll_loaded_dice(mating_probab);
        parentB_idx = roll_loaded_dice(mating_probab);
        while(parentB_idx == parentA_idx)
            parentB_idx = roll_loaded_dice(mating_probab);
        end
        chr(i) =  mate(chr(parentA_idx), chr(parentB_idx), funfcn, bit_signs, bitsize);
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
    while(all_unique_flag==0)
        all_unique_flag=1;
        for(i=1:2*GA_prefs.popsize)
            dd = find(abs(chr(i).score-score_vector)<1e-5);
            dd(dd==i)=[];
            while(~isempty(dd))
                t_idx = dd(end);
                
                all_unique_flag=0;
                while(abs(score_vector(t_idx) - chr(t_idx).score)<1e-5)
                    chr(t_idx) = mutate(chr(t_idx), bit_signs, bitsize);
                    chr(t_idx).score = funfcn(chr(t_idx).m);
                end
                score_vector(t_idx) = chr(t_idx).score;
                dd(end)=[];
            end
        end
        [s, idx] = sort(score_vector);
        score_vector = score_vector(idx);
        chr = chr(idx);
    end
    
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

% local min for final solution
fminsearchoptions = optimset('Display','off');
[m, bestscore] = fminsearch(@(m) funfcn(m), m,fminsearchoptions);

return;
end


function new_chr = mate(chrA, chrB, funfcn, bit_signs, bitsize)

global GA_prefs;


new_chr = chrA;
for(i=1:GA_prefs.bin_vec_length)
    if(rand<0.5)
        new_chr.bin_vec(i) = chrB.bin_vec(i);
    end
end
new_chr = mutate(new_chr, bit_signs, bitsize);
new_chr.score = funfcn(new_chr.m);

return;
end

function mutated_chr = mutate(chr, bit_signs, bitsize)

global GA_prefs;

mutated_chr = chr;
mutated_chr.m = binary_to_decimal(mutated_chr.bin_vec, bitsize);

mut_vec = rand(1,GA_prefs.bin_vec_length);
idx = find(mut_vec < GA_prefs.mutfreq); % positions to mutate

if(~isempty(idx))
    
    for(j=1:length(idx))
        i = idx(j);
        
        % if the current value is 1, mutate to 0 or -1
        % if the current value is -1, mutate to 0 or 1
        % if the current value is 0, mutate to 1 or -1
        
        if(mutated_chr.bin_vec(i) == 1)
            mutated_chr.bin_vec(i)=0;
            if(bit_signs(i)<=0) % this bit can be negative
                if(rand>0.5)
                    mutated_chr.bin_vec(i)=-1;
                end
            end
        else
            if(mutated_chr.bin_vec(i) == -1)
                mutated_chr.bin_vec(i)=0;
                if(bit_signs(i)>=0) % this bit can be positive
                    if(rand>0.5)
                        mutated_chr.bin_vec(i)=1;
                    end
                end
            else % 0
                mutated_chr.bin_vec(i)=1;
                if(bit_signs(i)<=0) % this bit can be negative
                    if(rand<=0.5)
                        mutated_chr.bin_vec(i)=-1;
                    end
                end
            end
        end
        
    end
    mutated_chr.m = binary_to_decimal(mutated_chr.bin_vec, bitsize);
    % mutated_chr.m = custom_round(mutated_chr.m, GA_prefs.tol);
    mutated_chr.bin_vec = decimal_to_binary(mutated_chr.m, bitsize);
end

% % adjust out-of-range values
% idx=[];
% for(i=1:GA_prefs.m_length)
%     if(mutated_chr.m(i)<m_limits(i,1) ||  mutated_chr.m(i)>m_limits(i,2))
%         idx = [idx i];
%     end
% end
% if(~isempty(idx))
%     for(j=1:length(idx))
%         i=idx(j);
%         mutated_chr.m(i) = bracketed_rand(m_limits(i,:));
%     end
%     mutated_chr.bin_vec = decimal_to_binary(mutated_chr.m, bitsize);
%     mutated_chr.m = binary_to_decimal(mutated_chr.bin_vec, bitsize);
% end

return;
end


