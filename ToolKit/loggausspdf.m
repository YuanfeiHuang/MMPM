function [y, var] = loggausspdf(X, means, covs)
d = size(X,1);
X = bsxfun(@minus,X,means);
% [temp,p]= chol(Sigma);
% nugget = 1e-6; % If Cholesky decomposition fails, try again with nugget
% while p
% 	Sigma = Sigma + diag(nugget*max(Sigma(:))*ones(1,d));
%     [temp,p] = chol(Sigma);
%     nugget = 2*nugget;
% end
% U = temp;
[temp,p] = chol(covs);
if p ~= 0
% 	covs = covs + eye(d)*(1e-8);
%     [temp, ~] = chol(covs);
    error('ERROR: Sigma is not PD.');
end
U = temp;

Q = U'\X;
var = dot(Q,Q,1);  % quadratic term (M distance)
var = var';
c = d*log(2*pi)+2*sum(log(diag(U)));   % normalization constant
y = -(c+var)/2;