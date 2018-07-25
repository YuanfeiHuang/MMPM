% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.

%% Extracting difference curvatures
function [fea_curv1, fea_curv2] = fea_curv_extract(fea, patch_size)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

fea_x = fea(1:patch_size, :);
fea_y = fea(patch_size+1:2*patch_size, :);
fea_xx = fea(2*patch_size+1:3*patch_size, :);
fea_yy = fea(3*patch_size+1:4*patch_size, :);
fea_xy = fea(4*patch_size+1:5*patch_size, :);

fea_down = (fea_x .* fea_x + fea_y .* fea_y) + eps;
fea_curv1 = fea_x .* fea_x .* fea_xx + 2*fea_x .* fea_y .* fea_xy + fea_y .* fea_y .* fea_yy;
fea_curv2 = fea_y .* fea_y .* fea_xx - 2*fea_x .* fea_y .* fea_xy + fea_x .* fea_x .* fea_yy;
fea_curv1 = fea_curv1 ./ fea_down;
fea_curv2 = fea_curv2 ./ fea_down;