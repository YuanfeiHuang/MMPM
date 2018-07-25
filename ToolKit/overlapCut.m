% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function [patch, xgrid, ygrid] = overlapCut(img, patchSize, overlap)
if patchSize <= overlap
    error('error! patch size must large than overlap!');
end
[m, n] = size(img);
if (m < patchSize) || (n < patchSize)
    error('patch size is too large to cut image!');
end

xgrid = 1 : patchSize - overlap : m - patchSize;
xgrid = [xgrid m - patchSize + 1];
ygrid = 1 : patchSize - overlap : n - patchSize;
ygrid = [ygrid n - patchSize + 1];

xl = length(xgrid);
yl = length(ygrid);

patch = zeros(patchSize * patchSize, xl * yl);
k = 1;
for x = 1 : xl
    for y = 1 : yl
        pat = img(xgrid(x) : xgrid(x) + patchSize - 1, ygrid(y) : ygrid(y) + patchSize - 1);
        patch(:, k) = pat(:);
        k = k + 1;
    end
end;    

    