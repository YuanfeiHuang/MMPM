% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% EM for Student-t Mixture Models
function model_out = SMM_EM(X, model_in, conf)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 
options = optimset('Display','off');
model_out.llh(1) = -Inf;

weights = model_in.weights;
means = model_in.means;
covs = model_in.covs;
df = model_in.df;

K = size(weights, 2); % number of components
[d, N] = size(X);
R = zeros(N, K);
U = zeros(N, K);

fprintf('\t StMM runing: 1.')
 
for iter = 2 : conf.iter_em
    
    [~,label(1,:)] = max(R,[],2);
    R = R(:,unique(label));   % remove empty clusters
    [~,labelU(1,:)] = max(U,[],2);
    U = U(:,unique(labelU));   % remove empty clusters
    fprintf('%d.', iter);
    
    % E-Step: Update R and U
    for k = 1 : K
        [R(:, k), Var(:, k)] = logstudentpdf(X, df(k), means(:, k), covs(:,:,k));
        N1 = df(k) + d;
        N2 = df(k) + Var(:, k);
        U(:, k) = N1 ./ N2;
    end
    R = bsxfun(@plus, R, log(weights));
    T = logsumexp(R, 2);
    R = exp(bsxfun(@minus, R, T)); % responsibility
    
    % M-Step: Update Weights, Means, Covs and Degree of freedom
    df_old = df;
    Temp = bsxfun(@times, R, U);
    Tk = sum(Temp, 1);
    Nk = sum(R, 1);
    
    weights = Nk / N;
    means = bsxfun(@times, X*Temp, 1./Tk);
    Temp_1 = bsxfun(@times, R, log(U)-U);
    Tk_1 = sum(Temp_1, 1);
        
    r = sqrt(Temp);
    for k = 1 : K
        Xo = bsxfun(@minus, X, means(:, k));
        Xo = bsxfun(@times, Xo, r(:,k)');
        newcovs = Xo * Xo' ./ Nk(k) + eye(d)*eps;
        [~, p] = chol(newcovs);
        if p == 0
        	covs(:, :, k) = newcovs;
        end
        fun_f = @(f) (-psi(max(realmin,f/2)) + log(max(realmin,f/2)) + 1 + Tk_1(k)/Nk(k) + psi((df_old(k)+d)/2) - log((df_old(k)+d)/2));
        df(k) = fzero(fun_f, df_old(k), options);
        clear newcovs;
    end
    
    % Loglikelihood with MDL
	llh = sum(T); % loglikelihood
%     mdl = (K-1 + K*(d+d*(d+1)/2+1))*log(N)/2;
% 	model_out.llh(iter) = -(mdl - llh)/N;
    model_out.llh(iter) = llh/N;
    if abs(model_out.llh(iter)-model_out.llh(iter-1)) < conf.tol*abs(model_out.llh(iter)); break; end;
    
end
fprintf('\n');
model_out.weights = weights;
model_out.means = means;
model_out.covs = covs;
model_out.df = df;
end