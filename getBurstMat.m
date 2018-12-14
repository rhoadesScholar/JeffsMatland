function [burstsMat] = getBurstMat (burstsVect, span)

burstsMat = zeros(floor(length(burstsVect)/span),span);
k=0;
for (i=1:floor(length(burstsVect)/span))
    for (j=1:span)
        burstsMat(i,j) = burstsVect(k+j);
    end
    k = k + span;
end