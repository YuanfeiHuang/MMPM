% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function  [center, cls_idx, s_idx, seg, cls_num] = clustering(X, cls_num)
% Adjusted K-Means Algorithm
% input:
%   features for clustering: X
%   initial number of clusters, usually defined by people: cls_num
% output:
%   the cluster centers: center
%   the belonging cluster index for every feature: cls_idx
%   index tables for sorting: s_idx
%   segment marks for features of different clusters: seg
%   the numbers of the clusters adjusted to the input data: cls_num

b2     =  size(X, 1);     % length of features
L      =  size(X, 2);     % # of features
itn    =  20;             % num of iteration
m_num  =  300;            % threshold adjusted experimentally!
P      =  randperm(L);   
P2     =  P(1:cls_num);
vec    =  X(:, P2(1:end));% initalization of cluster center

for i = 1 : itn
    mse       =  0;
    cent      =  zeros(b2, cls_num);
    cnt       =  zeros(1, cls_num);
    cls_idx   =  zeros(L, 1);
    for j = 1 : L
        v     =  X(:, j);
        cb    =  repmat(v, 1, cls_num);
        dis   =  sum((vec-cb).^2);
        [val, ind]   =   min(dis);
        cent(:, ind) =   cent(:, ind) + v;
        cnt(ind)     =   cnt(ind) + 1;
        cls_idx(j)   =   ind;
        mse          =   mse + val;
    end
    if (i == itn - 3)
        [val, ind] = min(cnt);
        while val < m_num            
%           fprintf('Min cls num  = %d\n', val);
            vec(:,ind)    =  [];
            cent(:,ind)   =  [];
            cls_num       =  cls_num - 1;
            cnt(ind)      =  [];
            [val, ind]    =  min(cnt);
        end                
    end
    cnt   =  cnt + eps;
    wei   =  repmat(cnt, b2, 1);
    vec   =  cent./wei;    
%   mse   =  mse/L/b2;
%   fprintf('clustering %d th loop, mse = %f', i, mse);
end
% finally obtain the cluster centers
center = vec;
% obtain the segment indices for fast index computation
[s_idx, seg] = proc_cls_idx(cls_idx);