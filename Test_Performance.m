% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.

%% Testing for Multiple Mixture Prior Models.
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 
clc, clear, close all

p = pwd;addpath([p, filesep, 'ToolKit']);
addpath(genpath([p, filesep, 'IFC']));

upscale = 2;
testdir = 'Set5';
modeldir = 'BSDS200';
FLAG = 'SMM';
path2ori = [p, filesep, 'Data/Results', filesep, modeldir, filesep, FLAG,...
    filesep, 'x', num2str(upscale), filesep, testdir, filesep, 'Original'];
path2int = [p, filesep, 'Data/Results', filesep, modeldir, filesep, FLAG,...
    filesep, 'x', num2str(upscale), filesep, testdir, filesep, 'Interpolated'];
path2rec = [p, filesep, 'Data/Results', filesep, modeldir, filesep, FLAG,...
    filesep, 'x', num2str(upscale), filesep, testdir, filesep, 'Reconstructed'];
% path2rec = [p, filesep, 'Data/results/state of the art/SRCNN', filesep, testdir,...
%     filesep, 'x', num2str(upscale)];

orifile=dir([path2ori filesep '*.png']);
intfile=dir([path2int filesep '*.png']);
recfile=dir([path2rec filesep '*.png']);
Prop = zeros(numel(orifile), 3);
Bicubic = zeros(numel(orifile), 3);
for img_idx = 1:numel(orifile)
    imHR = imread([path2ori filesep orifile(img_idx).name]);
    im_h = imread([path2rec filesep recfile(img_idx).name]);
    im_b = imread([path2int filesep intfile(img_idx).name]);
    disp(['Evaluating performance: [' recfile(img_idx).name ']']);
    if size(im_h,3) == 3
        imHR = double(rgb2ycbcr(imHR));
        im_h = double(rgb2ycbcr(im_h));
        im_b = double(rgb2ycbcr(im_b));
        imHR_y = double(imHR(:,:,1));
        im_b_y = double(im_b(:,:,1));
        im_h_y = double(im_h(:,:,1));
     
        [Prop(img_idx,1),~] = csnr(im_h_y,imHR_y,0,0);
        [Bicubic(img_idx,1),~] = csnr(im_b_y,imHR_y,0,0);
        Prop(img_idx,2) = cal_ssim(im_h_y,imHR_y,0,0);
        Bicubic(img_idx,2) = cal_ssim(im_b_y,imHR_y,0,0);
%         Prop(img_idx,3) = FeatureSIM(imHR_y,im_h_y);
%         Bicubic(img_idx,3) = FeatureSIM(imHR_y,im_b_y);
        Prop(img_idx,3) = ifcvec(imHR_y,im_h_y);
        Bicubic(img_idx,3) = ifcvec(imHR_y,im_b_y);

    else
        imHR_y = double(imHR);
        im_h_y = double(im_h);
        im_b_y = double(im_b);

        [Prop(img_idx,1),~] = csnr(im_h_y,imHR_y,0,0);
        [Bicubic(img_idx,1),~] = csnr(im_b_y,imHR_y,0,0);
        Prop(img_idx,2) = cal_ssim(im_h_y,imHR_y,0,0);
        Bicubic(img_idx,2) = cal_ssim(im_b_y,imHR_y,0,0);
%         Prop(img_idx,3) = FeatureSIM(imHR_y,im_h_y);
%         Bicubic(img_idx,3) = FeatureSIM(imHR_y,im_b_y);
        Prop(img_idx,3) = ifcvec(imHR_y,im_h_y);
        Bicubic(img_idx,3) = ifcvec(imHR_y,im_b_y);
        
    end
	clear imHR im_b im_h
end
result_mean = mean(Prop);
bicubic_mean = mean(Bicubic);
