function n = roll_loaded_dice(mating_probab)
% n = roll_loaded_dice(mating_probab)

doh = rand;
n=1;

if(doh <= mating_probab(1))
    return;
end

for(n=2:length(mating_probab))
    if(doh <= mating_probab(n) && doh > mating_probab(n-1))
        return;
    end
end

return;
end
