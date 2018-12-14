function mutualInfo = mutualInformation(x,y)

% Kraskov et al PRE 2004
mutualInfo = MIxnyn(x,y);



% gaussian-kernel approx for pXY
% % make into column vectors
% if(size(x,1)==1)
%     x = x';
% end
% if(size(y,1)==1)
%     y = y';
% end
% m = [x y];
% v = ksdensity2(m);
% pXY = v.pdf;

% % binned histogram for pXY
% pXY = hist2(x,y);

% pX = sum(pXY,2);
% pY = sum(pXY,1);
% 
% mutualInfo = pXY.*log2(pXY./(pX*pY));
% mutualInfo = nansum(mutualInfo(:));

return;

end


% function v = MI(label, result)
% % Nomalized mutual information
% % Written by Mo Chen (mochen@ie.cuhk.edu.hk). March 2009.
% assert(length(label) == length(result));
% 
% label = label(:);
% result = result(:);
% 
% n = length(label);
% 
% label_unique = unique(label);
% result_unique = unique(result);
% 
% % check the integrity of result
% if length(label_unique) ~= length(result_unique)
%     error('The clustering result is not consistent with label.');
% end;
% 
% c = length(label_unique);
% 
% % distribution of result and label
% Ml = double(repmat(label,1,c) == repmat(label_unique',n,1));
% Mr = double(repmat(result,1,c) == repmat(result_unique',n,1));
% Pl = sum(Ml)/n;
% Pr = sum(Mr)/n;
% 
% % entropy of Pr and Pl
% Hl = -sum( Pl .* log2( Pl + eps ) );
% Hr = -sum( Pr .* log2( Pr + eps ) );
% 
% 
% % joint entropy of Pr and Pl
% % M = zeros(c);
% % for I = 1:c
% % 	for J = 1:c
% % 		M(I,J) = sum(result==result_unique(I)&label==label_unique(J));
% % 	end;
% % end;
% % M = M / n;
% M = Ml'*Mr/n;
% Hlr = -sum( M(:) .* log2( M(:) + eps ) );
% 
% % mutual information
% v = Hl + Hr - Hlr;
% 
% return;
% end


