% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% EM for GMM
function model_out = GMM_EM(X, model_in, conf)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 
% Modified from the code provided by Michael Chen (sth4nth@gmail.com).
model_out.llh(1) = -inf;

weights = model_in.weights;
means = model_in.means;
covs = model_in.covs;

K = size(weights, 2); % number of components
[d, N] = size(X);
R = zeros(N, K);
fprintf('\t GMM runing: 1.')

for iter = 2 : conf.iter_em
    
    [~,label(1,:)] = max(R,[],2);
    R = R(:,unique(label));   % remove empty clusters
    fprintf('%d.', iter);
    
    % E-Step
    for k = 1 : K
        [R(:,k), Var(:, k)] = loggausspdf(X, means(:,k), covs(:,:,k));
    end
    R = bsxfun(@plus,R,log(weights));
    T = logsumexp(R,2);
    R = exp(bsxfun(@minus,R,T));
    
    % M-Step
    Nk = sum(R,1);
    weights = Nk/N;
    means = bsxfun(@times, X*R, 1./Nk);

    r = sqrt(R);
    for k = 1:K
        Xo = bsxfun(@minus,X,means(:,k));
        Xo = bsxfun(@times,Xo,r(:,k)');
        newcovs = Xo * Xo' ./ Nk(k) + eye(d)*(1e-8);
        [~, p] = chol(newcovs);
        a2 = all(all(isnan(newcovs)));
        if p == 0 && ~a2
        	covs(:, :, k) = newcovs;
        end
    end
    
    % loglikelihood
    llh = sum(T);
%     mdl = (K-1 + K*(d+d*(d+1)/2))*log(N)/2;
% 	model_out.llh(iter) = -(mdl - llh)/N;
    model_out.llh(iter) = llh/N;
    if abs(model_out.llh(iter)-model_out.llh(iter-1)) < conf.tol*abs(model_out.llh(iter)); break; end;
end
fprintf('\n');
model_out.weights = weights;
model_out.means = means;
model_out.covs = covs;
end