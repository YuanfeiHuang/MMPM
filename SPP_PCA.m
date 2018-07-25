% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% Selective Patch Processing and PCA dimension reduction for 3 groups
function [fea_spp_pca, V_pca, idx, thres] = SPP_PCA(fea, v, delta_now, delta_next)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

N = size(fea, 2);
v_s = sort(v);
if delta_now == 0
    thres_next = v_s(ceil(N * delta_next));
    [~, idx] =  find( v < thres_next );
    thres = -Inf;
elseif delta_next == 1
    thres = v_s(ceil(N * delta_now));
    [~, idx] =  find( v >= thres );
    thres_next = Inf;
else
    thres = v_s(ceil(N * delta_now));
    thres_next = v_s(ceil(N * delta_next));
    [~, idx] =  find( v >= thres & v < thres_next );
end
thres = [thres thres_next];
fea_spp = fea(:, idx);

% PCA dimensionality reduction for gradient features
C = double(fea_spp * fea_spp');
[V, D] = eig(C);
D = diag(D);
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1);   % ignore 0.1% energy
V_pca = V(:, k:end); % choose the largest eigenvectors' projection
fea_spp_pca = V_pca' * fea_spp;

