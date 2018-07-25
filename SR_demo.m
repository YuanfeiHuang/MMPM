% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.

%% Testing for Multiple Mixture Prior Models.
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

clc, clear, close all
p = pwd;
addpath([p, filesep, 'ToolKit']);
addpath(genpath([p, filesep, 'IFC']));

training = 'BSDS200';
inputdir = 'Set5';
FLAG = 'SMM';
scale = 2;
delta = [0 50 80];
MaxK = [20 100 500];
mix_match = [1 3 4];
path2model = [p, filesep, 'Model', filesep, training]; 
mat_file = [path2model, filesep, 'conf_MMPM_', FLAG, '_x', num2str(scale), '_cls_', num2str(MaxK), '_delta_', num2str(delta)];

load(mat_file, 'conf');
highdir='Data/Testing';
hfile=dir([highdir filesep inputdir filesep '*.png']);
path2results = [p, filesep, 'Data/Results', filesep, training, filesep, FLAG];

for img_idx= 1:numel(hfile)   
    % read test image
    imHR = imread([highdir filesep inputdir filesep hfile(img_idx).name]);
    imHR = imHR(1:size(imHR,1)-rem(size(imHR,1),conf.scale), 1:size(imHR,2)-rem(size(imHR,2),conf.scale), :);
       
    % change color space, work on illuminance only
    if size(imHR, 3) == 3
        imHR = double(rgb2ycbcr(imHR));
        disp(['SR test input image [' hfile(img_idx).name ']']);
        im_l = imresize(imHR, 1/conf.scale, 'bicubic');
        im_b = imresize(im_l, conf.scale, 'bicubic');
    else
        imHR = double(imHR);
        disp(['SR test input image [' hfile(img_idx).name ']']);
        im_l = imresize(imHR, 1/conf.scale, 'bicubic');
        im_b = imresize(im_l, conf.scale, 'bicubic');
    end
    
    startt = tic;
    [im_h_y] = SRFunc_MMPM_S(im_l(:,:,1), conf, mix_match);
	runtime(img_idx) = toc(startt);    
    im_h_y = 255*im_h_y;  

    im_h = zeros(size(im_h_y,1),size(im_h_y,2),3);
    if size(imHR, 3) == 3
        im_h(:,:,1) = im_h_y;
        im_h(:,:,2) = im_b(:,:,2);
        im_h(:,:,3) = im_b(:,:,3);
        im_h = shave(im_h, conf.border*conf.scale);
        im_b = shave(im_b, conf.border*conf.scale);
        imHR_ycbcr = shave(imHR, conf.border*conf.scale);
        
% save the illuminate channel of images
        im_b_y = uint8(im_b(:,:,1));
        im_h_y = uint8(im_h(:,:,1));
        imHR_y = uint8(imHR_ycbcr(:,:,1));
        flagRGB = [];
        
% save colorful RGB images
%         im_h = uint8(im_h);
%         im_h_y = double(ycbcr2rgb(im_h))/255;   
%         im_b = uint8(im_b);
%         imHR_ycbcr = uint8(imHR_ycbcr);
%         im_b_y = double(ycbcr2rgb(im_b))/255;  
%         imHR_y = double(ycbcr2rgb(imHR_ycbcr))/255;
%         flagRGB = 'RGB/';
    else
        im_h = im_h_y;
        im_h = shave(im_h, conf.border*conf.scale);
        im_b = shave(im_b, conf.border*conf.scale);
        imHR_1 = shave(imHR, conf.border*conf.scale);
               
        im_b_y = uint8(im_b);
        im_h_y = uint8(im_h);
        imHR_y = uint8(imHR_1);
    end
    
	HRimPath = [path2results, filesep, 'x', num2str(conf.scale), filesep, inputdir, filesep, 'Reconstructed'];
    mkdir([HRimPath, filesep, flagRGB]);
    imwrite(im_h_y, [HRimPath, filesep, flagRGB, FLAG, '_x', num2str(conf.scale), '_', hfile(img_idx).name]);
	BIimPath = [path2results, filesep, 'x', num2str(conf.scale), filesep, inputdir, filesep, 'Interpolated'];
    mkdir([BIimPath, filesep, flagRGB]);
	imwrite(im_b_y, [BIimPath, filesep, flagRGB, 'Bicubic_x', num2str(conf.scale), '_', hfile(img_idx).name]);
	ORimPath = [path2results, filesep, 'x', num2str(conf.scale), filesep, inputdir, filesep, 'Original'];  
    mkdir([ORimPath, filesep, flagRGB]);
	imwrite(imHR_y, [ORimPath, filesep, flagRGB, 'Original_', hfile(img_idx).name]);
    clear imHR im_b im_h im_h_y im_l imHR_ycbcr
end
meantime = mean(runtime');