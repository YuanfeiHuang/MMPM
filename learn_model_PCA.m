% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function learn_model_PCA(ohires, conf)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

% Learn the Training Model of Multiple Linear Mappings.
% input:
%   configuration file: conf
%   high-resolution images, stored in cells: hires
% output:
%   configuration file: conf
delta = ceil(conf.delta(1:3)*100);
fea_data_smooth = ['Data/training/' conf.training '_x' num2str(conf.scale) '_fea_data_smooth_delta_' num2str(delta) '.mat'];
fea_data_middle = ['Data/training/' conf.training '_x' num2str(conf.scale) '_fea_data_middle_delta_' num2str(delta) '.mat'];
fea_data_detail = ['Data/training/' conf.training '_x' num2str(conf.scale) '_fea_data_detail_delta_' num2str(delta) '.mat'];
fea_data_spp  = ['Data/training/' conf.training '_x' num2str(conf.scale) '_fea_data_SPP_delta_' num2str(delta) '.mat'];
if exist(fea_data_smooth, 'file') && exist(fea_data_middle, 'file') && exist(fea_data_detail, 'file') && exist(fea_data_spp, 'file')
    disp('Training features already in files');
    load(fea_data_smooth);
    load(fea_data_middle);
    load(fea_data_detail);
    load(fea_data_spp);
else
    fea_lr = [];
    fea_hr = [];
    sfactor = 0.98 .^ [0 1 2 3 4 5];
    for scale = 1 : length(sfactor)
        chires = resize(ohires, sfactor(scale), 'bicubic'); % augment training set with down-scaling HR with sfactor
        hires = modcrop(chires, conf.scale);
        clear chires
        % scale down hires
        lores = resize(hires, 1/conf.scale, conf.interpolate_kernel);
        % scale up lores to the same size with hires
        midres = resize(lores, conf.scale, conf.interpolate_kernel);
        clear lores
        % collect patches from hires and midres
        patch_int = collect(conf, midres, conf.scale, {});
        patch_hr = collect(conf, hires, conf.scale, {});
        fea_hr = [fea_hr patch_hr - patch_int];
        clear hires patch_int patch_hr;
        % collect gradient features from lores
        fea_lr = [fea_lr collect(conf, midres, conf.scale, conf.curv_filters)];
        clear midres
        n = size(fea_lr, 2);
        len = 5000; % num of training patches
        if n > len
            idx = randperm(n, len);
            fea_hr = fea_hr(:, idx);
            fea_lr = fea_lr(:, idx);
            break;
        end
    end
    
    %% Selective Patch Processing
    patch_size = size(fea_hr, 1);
    [fea_curv1, fea_curv2] = fea_curv_extract(fea_lr, patch_size);
    C = abs(abs(fea_curv1) - abs(fea_curv2));
    v = median(C, 1);
    [fea_spp_pca_smooth, V_pca_smooth, Idx_smooth, Thres_smooth] = SPP_PCA(fea_lr, v, conf.delta(1), conf.delta(2));
    [fea_spp_pca_middle, V_pca_middle, Idx_middle, Thres_middle] = SPP_PCA(fea_lr, v, conf.delta(2), conf.delta(3));
    [fea_spp_pca_detail, V_pca_detail, Idx_detail, Thres_detail] = SPP_PCA(fea_lr, v, conf.delta(3), conf.delta(4));
    
    spp.V_pca{1} = V_pca_smooth;
    spp.V_pca{2} = V_pca_middle;
    spp.V_pca{3} = V_pca_detail;
    
    spp.SPPthres{1} = [Thres_smooth, length(Idx_smooth)];
    spp.SPPthres{2} = [Thres_middle, length(Idx_middle)];
    spp.SPPthres{3} = [Thres_detail, length(Idx_detail)];
    
    fea_hr_smooth = fea_hr(:, Idx_smooth);
    fea_hr_middle = fea_hr(:, Idx_middle);
    fea_hr_detail = fea_hr(:, Idx_detail);
    
    fea_joint_smooth = [fea_hr_smooth; fea_spp_pca_smooth];
    fea_joint_middle = [fea_hr_middle; fea_spp_pca_middle];
    fea_joint_detail = [fea_hr_detail; fea_spp_pca_detail];
    save(fea_data_smooth, 'fea_joint_smooth');
    save(fea_data_middle, 'fea_joint_middle');
    save(fea_data_detail, 'fea_joint_detail');
    save(fea_data_spp, 'spp');
end

%% Training MMPM with EM algorithm
fea_joint{1} = fea_joint_smooth;
fea_joint{2} = fea_joint_middle;
fea_joint{3} = fea_joint_detail;
conf.V_pca = spp.V_pca;
conf.SPPthres = spp.SPPthres;
clearvars -except fea_joint conf

if conf.FLAG == 'SMM'
    fprintf('Training for EM SMM \n');
    for i = 1: length(conf.maxK)
        t1 = clock;
        model_in = Initialization(fea_joint{i}, conf.maxK(i), conf);
        if conf.maxK(i) > 3
            conf.model{i} = SMM_EM(fea_joint{i}, model_in, conf);
        else
            conf.model{i} = model_in;
        end
        clear model_in
        conf.trainingtime{i} = etime(clock, t1);
        fprintf('\t Saving General EM Student-t Mixture Models ... \n');
        save(conf.mat_file_EM, 'conf');
    end
    
elseif conf.FLAG == 'GMM'
    fprintf('Training for EM GMM \n');
    for i = 1: length(conf.maxK)
        t1 = clock;
        model_in = Initialization(fea_joint{i}, conf.maxK(i), conf);
        if conf.maxK(i) > 3
            conf.model{i} = GMM_EM(fea_joint{i}, model_in, conf);
        else
            conf.model{i} = model_in;
        end
        clear model_in
        conf.trainingtime{i} = etime(clock, t1);
        fprintf('\t Saving General EM Gaussian Mixture Models ... \n');
        save(conf.mat_file_EM, 'conf');
    end    
else
    fprintf('Must choose SMM or GMM!');
end