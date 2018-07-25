% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
%% SR Functions for Multiple Mixture Pior Models-Student's-t
function [RecImage] = SRFunc_MMPM_S(imgs, conf, mix_match)
% Author: Yuanfei Huang; 
%         yfhuang95@gmail.com
%         yf_huang@stu.xidian.edu.cn 

patch_size = conf.scale * 3;
imgs = imgs/255;
midres   = double(imresize(imgs, conf.scale, conf.interpolate_kernel));
fea_lr = extract(conf, midres, conf.scale, conf.curv_filters);
RecPatches_1 = zeros(patch_size^2, size(fea_lr,2));

[fea_curv1, fea_curv2] = fea_curv_extract(fea_lr, patch_size^2);
C = abs(abs(fea_curv1) - abs(fea_curv2));
v = median(C, 1);

for ii = 1 : length(conf.maxK)
    
    [fea_lr_spp, idx_high] = SPPTest(fea_lr, v, conf.SPPthres{ii});
    ModelMeans = conf.model{ii}.means;
    ModelCovs = conf.model{ii}.covs;
    ModelWeights = conf.model{ii}.weights;
    ModelDf = conf.model{ii}.df;

    Patches = conf.V_pca{ii}' * fea_lr_spp;
    Respons = zeros(size(ModelMeans,2),size(fea_lr_spp,2));

    for k = 1:size(ModelMeans,2)
        Means_LR = ModelMeans((patch_size^2 + 1):size(ModelMeans,1),k);
        Covs_LR = ModelCovs((patch_size^2 + 1):size(ModelCovs, 1), (patch_size^2 + 1):size(ModelCovs,1), k); 
        Respons(k,:) = log(ModelWeights(k)) + logstudentpdf(Patches, ModelDf(k), Means_LR, Covs_LR);   
    end
    T = logsumexp(Respons, 1);
    Respons = exp(bsxfun(@minus,Respons,T));
    [~, idx] = sort(Respons);
    max_Respons = idx((size(idx,1)-mix_match(ii)+1 : size(idx,1)),:);
    for i = 1: size(Patches,2)
        for j = 1:mix_match(ii)
            Respons_1(j, i) = Respons(max_Respons(j, i),i);
        end
    end
    clear Respons
    Respons_mean = sum(Respons_1, 1);
    Respons_1 = Respons_1./ Respons_mean;
    RecPatches = zeros(patch_size^2, size(Patches,2));
    Cond_means = zeros(patch_size^2,size(Patches,2));

    for j = 1 : mix_match(ii)
        for k = 1:size(ModelMeans,2)
            Indx = find(max_Respons(j,:) == k);
            Patches_1 = Patches(:,Indx);
            Patches_diff = Patches_1 - repmat(ModelMeans((patch_size^2 + 1):size(ModelMeans,1),k),1,size(Patches_1,2));
            WienFilter = ModelCovs(1:patch_size^2,(patch_size^2 + 1):size(ModelCovs,1),k)/(ModelCovs((patch_size^2 + 1):size(ModelCovs,1),...
                (patch_size^2 + 1):size(ModelCovs,2),k));
            Cond_means(:, Indx) = WienFilter * Patches_diff + repmat(ModelMeans(1:patch_size^2,k),1,size(Patches_1,2));
        end
        Recon = Cond_means .* Respons_1(j, :);
        RecPatches = RecPatches + Recon;
    end
    clear Recon Respons_1
    RecPatches_1(:, idx_high) = RecPatches;
end
imHR_size = size(imgs) * conf.scale;
grid = sampling_grid(imHR_size, conf.window, conf.overlap, conf.border, conf.scale);
RecImg = overlap_add(RecPatches_1, imHR_size, grid);
RecImage = RecImg + midres;

return
