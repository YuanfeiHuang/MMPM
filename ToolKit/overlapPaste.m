% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function img = overlapPaste(patch, xgrid, ygrid)
    dim = size(patch, 1);
    patch_size = sqrt(dim);
    
    sz_x = xgrid(end) + patch_size - 1;
    sz_y = ygrid(end) + patch_size - 1;
    
    img  = zeros(sz_x, sz_y);
    over_count = zeros(sz_x, sz_y);
    
    xl = length(xgrid);
    yl = length(ygrid);
    
    k = 1;
    for x = 1 : xl
        for y = 1 : yl
            xs = xgrid(x);
            xe = xgrid(x) + patch_size - 1;
            ys = ygrid(y);
            ye = ygrid(y) + patch_size - 1;
            pat = reshape(patch(:, k), patch_size, patch_size);
            img(xs:xe, ys:ye) = img(xs:xe, ys:ye) + pat;
            over_count(xs:xe, ys:ye) = over_count(xs:xe, ys:ye) + 1;
            k = k + 1;
        end
    end
    img = img ./ over_count;
end