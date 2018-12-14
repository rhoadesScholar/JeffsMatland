function y = double_sigmoid_function(t, y0, ymaxResp, yfinal, alpha1, tau1, alpha2, tau2)

y = (1/ymaxResp).*sigmoid(t, y0, ymaxResp, alpha1, tau1).*sigmoid(t, ymaxResp, yfinal, alpha2, tau2);

return;
end

function y = sigmoid(t, startval, endval, alpha, tau)

y = startval + (endval - startval)./(1 + exp((-(t-alpha)*4*(tau))/(endval - startval)));

return;
end
