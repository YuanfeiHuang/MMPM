% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function [features] = collect(conf, imgs, scale, filters, verbose)
% Extract features of high-resolution or low-resolution images.
% input:
%   configuration file: conf
%   images to be extracted, stored in cells: imgs 
%   the factor to scale up in the model: scale
%   the used interpolation kernel: filters
%   whether to print the information or not, 0 for not, others for true: verbose
% output:
%   features to be extracted: features

if nargin < 5
    verbose = 0;
end

num_of_imgs = numel(imgs);
feature_cell = cell(num_of_imgs, 1); % contains images' features
num_of_features = 0;

if verbose
    fprintf('Collecting features from %d image(s) ', num_of_imgs)
end
feature_size = [];

for i = 1:num_of_imgs
    sz = size(imgs{i});
    if verbose
        fprintf(' [%d x %d]', sz(1), sz(2));
    end
    % extract features here
    F = extract(conf, imgs{i}, scale, filters);
    num_of_features = num_of_features + size(F, 2);
    feature_cell{i} = F;
    assert(isempty(feature_size) || feature_size == size(F, 1), ...
        'Inconsistent feature size!')
    feature_size = size(F, 1);
end
if verbose
    fprintf('\nExtracted %d features (size: %d)\n', num_of_features, feature_size);
end
clear imgs;
features = zeros([feature_size num_of_features], 'single');
offset = 0;
for i = 1:num_of_imgs
    F = feature_cell{i};
    N = size(F, 2); % number of features in current cell
    features(:, (1:N) + offset) = F;
    offset = offset + N;
end