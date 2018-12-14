function [m, bestscore] = GA(funfcn, m_limits)
% usage [m, bestscore] = GA(@(m) myfunction(m), m_limits);

global GA_prefs;
GA_prefs.word_length = 36;
GA_prefs.popsize = 20;
GA_prefs.conv_cycles = 10;
GA_prefs.mutfreq = 0.005;
GA_prefs.basal_mutfreq = 0.005;


tol = 1e-5;
pos_only_flag=0;
display_cycle=1;

% number of variables .. but no limits or guesses given
if(length(m_limits)==1)
    x = m_limits;
    m_limits = [];
    for(i=1:x)
        m_limits(i,:) = [-10 10];
    end
end

% gave initial guess instead of limits
if(isvector(m_limits))
    x = m_limits;
    m_limits = [];
    for(i=1:length(x))
        if(x(i)~=0)
            m_limits(i,:) = [x(i)/100 x(i)*100];
        else
            m_limits(i,:) = [-10 10];
        end
    end
end

funfcn = fcnchk(funfcn,2);


m_length = size(m_limits,1);
GA_prefs.bintxt_length = m_length*GA_prefs.word_length;
GA_prefs.popsize = 5*GA_prefs.bintxt_length;
GA_prefs.max_popsize = 10*GA_prefs.bintxt_length; % 3*GA_prefs.popsize;
GA_prefs.conv_cycles = GA_prefs.bintxt_length;
GA_prefs.mutfreq = max(GA_prefs.mutfreq,(1/GA_prefs.bintxt_length)/2);
GA_prefs.basal_mutfreq = GA_prefs.mutfreq;

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
for(i=1:GA_prefs.max_popsize)
    chr(i).bintxt = '';
    for(j=1:m_length)
        chr(i).bintxt = sprintf('%s%s', chr(i).bintxt, random_binary_number(m_limits(j,1), m_limits(j,2)));
    end
    chr(i).m = bintxt_to_m(chr(i).bintxt);
    chr(i).score = 1e10;
    chr(i) = score_chr(funfcn, chr(i));

end

% sort initial population
score_vector=[];
for(i=1:GA_prefs.max_popsize)
    score_vector = [score_vector chr(i).score];
end
[s, idx] = sort(score_vector);
score_vector = score_vector(idx);
chr = chr(idx);


all_unique_flag=0;
while(all_unique_flag==0)
    all_unique_flag=1;
    for(i=1:2*GA_prefs.popsize)
        dd = find(abs(chr(i).score-score_vector)<tol);
        while(length(dd)>1)
            all_unique_flag=0;
            t_idx = dd(end);
            while(abs(score_vector(t_idx) - chr(t_idx).score)<tol)
                chr(t_idx) = mutate(chr(t_idx), m_limits, pos_only_flag);
                chr(t_idx) = score_chr(funfcn, chr(t_idx));
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
conv_score = abs(chr(1).score - chr(GA_prefs.popsize).score);
while(num_conv_cycles <= GA_prefs.conv_cycles)
    numGen = numGen+1;
    
    % mating and mutating

        for(i=(GA_prefs.popsize+1):(2*GA_prefs.popsize))
            parentA_idx = roll_loaded_dice(mating_probab);
            parentB_idx = roll_loaded_dice(mating_probab);
            while(parentB_idx == parentA_idx)
                parentB_idx = roll_loaded_dice(mating_probab);
            end
            chr(i) =  mate(chr(parentA_idx), chr(parentB_idx), funfcn, m_limits, pos_only_flag);
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
                dd = find(abs(chr(i).score-score_vector)<tol);
                while(length(dd)>1)
                    all_unique_flag=0;
                    t_idx = dd(end);
                    while(abs(score_vector(t_idx) - chr(t_idx).score)<tol)
                        chr(t_idx) = mutate(chr(t_idx), m_limits, pos_only_flag);
                        chr(t_idx) = score_chr(funfcn, chr(t_idx));
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
    if(~are_these_equal(prev_score,chr(1).score,tol))
        num_conv_cycles=0;
        GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
        
        disp([num2str(numGen),' ', num2str(num_conv_cycles),' ', num2str(chr(1).score),' ',  num2str(conv_score),' ',num2str(GA_prefs.mutfreq),' ', timeString(),' ',num2str(chr(1).m)]);

%         m = chr(1).m;
%         [weight_matrix, bias_vector] = m_to_weights_bias(m);
%         nH = [1 5 2.5 2.5]; K = [0.5 5 1 1]; y0 = [0.65 0.2 0.65 0.2]; yf = [0.3 1 0.7 0];
%         figure(1); plot_toy_network_fit(weight_matrix, bias_vector, y0, yf, K, nH);figure(1); pause(1);
    else
        num_conv_cycles=num_conv_cycles+1; % increase mutation freq
%         GA_prefs.mutfreq = GA_prefs.mutfreq+GA_prefs.basal_mutfreq;
%         if(GA_prefs.mutfreq >=0.1)
%             GA_prefs.mutfreq = GA_prefs.basal_mutfreq;
%         end
    end
    
    conv_score = abs(chr(1).score - chr(GA_prefs.popsize).score);
        
%     if(mod(numGen,display_cycle)==0)
%         disp([num2str(numGen),' ', num2str(num_conv_cycles),' ', num2str(chr(1).score),' ',  num2str(conv_score),' ',num2str(GA_prefs.mutfreq),' ', timeString(),' ',num2str(chr(1).m)]);
%     end
    
    prev_score = chr(1).score;
    

end

m = chr(1).m;

% local min for final solution
[m, bestscore] = fminsearch(@(m) funfcn(m), m);

return;
end


function new_chr = mate(chrA, chrB, funfcn, m_limits, pos_only_flag)

global GA_prefs;

new_chr.bintxt = chrA.bintxt;
for(i=1:GA_prefs.bintxt_length)
    if(rand<0.5)
        new_chr.bintxt(i) = chrB.bintxt(i);
    end
end

new_chr = mutate(new_chr, m_limits, pos_only_flag);

new_chr = score_chr(funfcn, new_chr);

return;
end

function mutated_chr = mutate(chr, m_limits, pos_only_flag)

global GA_prefs;

mutated_chr = chr;
for(i=1:GA_prefs.bintxt_length)
    if(rand < GA_prefs.mutfreq)
        if(mutated_chr.bintxt(i) == '1')
            mutated_chr.bintxt(i) = '0';
        else
            if(mutated_chr.bintxt(i) == '0')
                mutated_chr.bintxt(i) = '1';
            else
                if(pos_only_flag==0)
                    if(mutated_chr.bintxt(i) == '+')
                        mutated_chr.bintxt(i) = '-';
                    else
                        if(mutated_chr.bintxt(i) == '-')
                            mutated_chr.bintxt(i) = '+';
                        end
                    end
                end
            end
        end
    end
end


mutated_chr.m = bintxt_to_m(mutated_chr.bintxt);

i=1;
for(j=1:length(mutated_chr.m))
    if(mutated_chr.m(j)<m_limits(j,1) ||  mutated_chr.m(j)>m_limits(j,2))
        mutated_chr.bintxt(i:i+GA_prefs.word_length-1) = random_binary_number(m_limits(j,1), m_limits(j,2));
    end
    i=i+GA_prefs.word_length;
end
mutated_chr.m = bintxt_to_m(mutated_chr.bintxt);

return;
end

function chr = score_chr(funfcn, chr)

chr.score = funfcn(chr.m);

% if(nargin<3)
%     min_flag=0;
% end
% if(min_flag==1)
%     %     m_bef = chr.m;
%     %     bef = funfcn(chr.m);
%     
%     fminsearchoptions = optimset('MaxIter',5,'Display','off');
%     m = chr.m;
%     m1 = fminsearch(@(m) funfcn(m), m, fminsearchoptions);
%     chr.m = m1;
%     m_length = length(chr.m);
%     chr.bintxt = '';
%     for(j=1:m_length)
%         chr.bintxt = sprintf('%s%s', chr.bintxt, number_to_binary(m1(j)));
%     end
%     chr.m = bintxt_to_m(chr.bintxt);
%     
%     %     chr.score = funfcn(chr.m);
%     %     disp([bef chr.score bef-chr.score ])
% end


return;
end



