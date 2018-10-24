% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.

%% Training for Multiple Mixture Prior Models.
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 
clc, clear, close all
p = pwd; 
addpath([p, filesep, 'ToolKit']);
%% Parameter Settings
conf.training = 'BSDS200'; % training dataset
conf.scale = 3;            % scale-up factor
conf.window = [3 3];       % low-res. window size
conf.border = [1 1];       % border of the image (to ignore)
conf.maxK = [2 2 5];        % # of clusters
conf.delta = [0 0.5 0.8 1]; % proportion of groups 
delta = ceil(conf.delta(1:3)*100);
conf.iter_em = 100; % iteration for EM
conf.tol = 1e-4; % convergence threshold
conf.FLAG = 'SMM'; % SMM for Student-t Mixture Model; GMM for Gaussian Mixture Model
conf.Initialization = 'Random'; % K-Means or Random
% parameters for feature extraction
O = zeros(1, conf.scale - 1);
D_x = [1 O -1];
D_xx = [1 O -2 O 1];
D_xy = diag([1 O 0 O 1]);
D_xy = (D_xy - rot90(D_xy));
conf.curv_filters = {D_x, D_x', D_xx, D_xx', D_xy};
conf.interpolate_kernel = 'bicubic';  % interpolation kernel
conf.overlap = conf.window - conf.border;   % partial overlap (for faster training)
if conf.scale <= 2
    conf.overlap = [2 2];             % partial overlap
end

%% Model Training
path2model = [p, filesep, 'Model', filesep, conf.training]; % path to model 

conf.mat_file_EM = [path2model, filesep, 'conf_MMPM_', conf.FLAG, '_x', ...
    num2str(conf.scale), '_cls_', num2str(conf.maxK), '_delta_', num2str(delta)];
tic
path2train = [p, filesep, 'Data', filesep, 'Training', filesep, conf.training];
patt2train = '*.jpg';      % pattern of training images
hires = load_images(glob(path2train, patt2train));
learn_model_PCA(hires, conf);
toc
