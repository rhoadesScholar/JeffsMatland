function v = matrix_to_vector(m)
% v = matrix_to_vector(m)

if(nargin==0)
   disp('usage:  v = matrix_to_vector(m)');
   return;
end

s = size(m);

v = zeros(1,s(1)*s(2));
j=1;
for(i=1:s(1))
    v(j:(j+s(2)-1)) = m(i,:);
    
    j = j + s(2);
end

return;
end
