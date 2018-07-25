% THIS IS THE RESEARCH WORK OF VIPSL-VPC OF XIDIAN UNIVERSITY.
% ALL RIGHTS RESERVED.
function  [s_idx, seg] = proc_cls_idx(cls_idx)
% index tables and segment marks computation
[idx, s_idx] = sort(cls_idx);
idx2 = idx(1:end-1) - idx(2:end);
seq  = find(idx2);
seg  = [0; seq; length(cls_idx)];