function [ H ] = estimateHomography( xy1_homo, xy2_homo )
pt_num = size(xy1_homo, 2);

T1 = featureHartleyNormalize( xy1_homo(1:2,:) );
T2 = featureHartleyNormalize( xy2_homo(1:2,:) );

xy1_norm = T1 * xy1_homo;
xy2_norm = T2 * xy2_homo;

A = zeros(pt_num * 2, 9);
for i = 1:pt_num
    A((i-1)*2+1,:) = [xy1_norm(1,i), xy1_norm(2,i), 1, 0, 0, 0,...
        -xy1_norm(1,i)*xy2_norm(1,i), -xy1_norm(2,i)*xy2_norm(1,i),...
        -xy2_norm(1,i)];
    A((i-1)*2+2,:) = [0, 0, 0, xy1_norm(1,i), xy1_norm(2,i), 1,...
        -xy1_norm(1,i)*xy2_norm(2,i), -xy1_norm(2,i)*xy2_norm(2,i),...
        -xy2_norm(2,i)];
end

[~, ~, V] = svd(A);

h = V(:,end)/norm(V);
H_norm = reshape(h, [3,3])';

H = T2 \ H_norm * T1;
H = H ./ H(end,end);
end

