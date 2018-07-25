function [Y, var] = logstudentpdf(X, freedom, means, covs)
% y: output student-t distribution;
% var: (X - means)'covs^(-1)(X - means);
d = size(X, 1);
X = bsxfun(@minus, X, means);
[temp,p] = chol(covs);
if p ~= 0
% 	covs = covs + eye(d)*(1e-8);
%     [temp, ~] = chol(covs);
    error('ERROR: Sigma is not PD.');
end
U = temp;
Q = U' \ X;
var = dot(Q, Q, 1);  % quadratic term (M distance)
var = var';
N0 = -((freedom + d) / 2) * log(1 + var / freedom);
N1 = gammaln((freedom + d) / 2) - gammaln(freedom / 2);
N2 = -(d / 2) * log(pi * freedom);
N3 = -sum(log(diag(U)));   % normalization constant
Y = N0 + N1 + N2 + N3;
end