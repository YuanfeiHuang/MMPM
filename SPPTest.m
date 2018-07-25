% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% Partitioning groups with preloaded SPP thresholds
function [fea_spp, idx] = SPPTest(fea, v, thres)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

if thres(1) == -Inf
    [~, idx] =  find( v < thres(2) );
elseif thres(2) == Inf
    [~, idx] =  find( v >= thres(1) );
else
    [~, idx] =  find( v >= thres(1) & v < thres(2) );
end
fea_spp = fea(:,idx);