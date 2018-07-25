% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% Initialization of mixure prior models %%
function model = Initialization(X, K, conf)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

fprintf('\t Initialization runing... \n')
[d, N] = size(X);
if conf.Initialization == 'KMeans'
    X = X';
    [idx, means] = kmeans(X, K);
    model.means = means';
    model.weights = zeros(1, K);
    for k = 1 : K
        idx_k = find(idx == k);
        model.weights(k) = length(idx_k) / N;
        newcov = cov(X(idx_k, :)) + eye(d)*eps;
        [~,p] = chol(newcov);
        if p == 0
            model.covs(:, :, k) = cov(X(idx_k, :));
        else
            model.covs(:, :, k) = cov(X);
        end
    end
elseif conf.Initialization == 'Random'
    dataCov = cov(X');
    index = randperm(N, K);
    model.weights = 1/K + zeros(1, K);
    model.means = X(:, index);
    model.covs = repmat(dataCov, 1, 1, K);
end
if conf.FLAG == 'SMM'
    model.df = ones(1, K)*d;
end
end