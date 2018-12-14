% round up to the nearest a'th, where a<1.
% for example, custom_round(1.235, 0.5) -> 1.5
% for example,  custom_round(1.735, 0.5) -> 2
% for example, custom_round(1.235, 0.2) -> 1.4
% for example,  custom_round(1.735, 0.2) -> 1.8

function r = custom_round(x, a, floor_ceil)

r=[];

% normal rounding
if(nargin==1)
    r = round(x);
    return;
end

if(a==0)
    r = round(x);
    return;
end

round_up_down_flag=0;
if(nargin==3)
   if(strcmpi(floor_ceil,'ceil'))
       round_up_down_flag=1;
   else
       round_up_down_flag=-1;
   end
end

addon = round_up_down_flag*a;

int_part = floor(abs(x));
dec_part = abs(x) - int_part;

bins = 0:a:1;
len_bin = length(bins);

if(len_bin == 0)
    r = round(x);
    return;
end

if(bins(len_bin) < 1)
    bins(len_bin+1) = 1;
end

% x is a vector or matrix
if(~isscalar(x))
    for(i=1:numel(dec_part))
        [new_dec, idx] = find_closest_value_in_array(dec_part(i), bins);
        
        r(i) = int_part(i) + new_dec + addon;
        
        if(x(i)<0)
            r(i) = -r(i);
        end
    end
    r = reshape(r,size(x));
    return;
end

[new_dec, idx] = find_closest_value_in_array(dec_part, bins);

r = int_part + new_dec + addon;

if(x<0)
    r = -r;
end

return;
end
