function T = featureHartleyNormalize( features )
    % compute the Hartley Normalize matrix based on the given features
    % features are 2xN matrix with the format [x; y] for each column
    
    % Get the size
    len = length(features(1,:));
    
    % Expand the input matrix into homogeneous coordinates by adding a row
    % of 1
    m = [features; ones(1,len)];
    
    % Compute the centroid
    centroid = mean(m,2);
    
    % Compute average distance
    dists = sqrt(sum((m - repmat(centroid,1,size(m,2))).^2,1));
    mean_dist = mean(dists);
    
    % Compute T
    T = [sqrt(2)/mean_dist 0 -sqrt(2)/mean_dist*centroid(1);...
         0 sqrt(2)/mean_dist -sqrt(2)/mean_dist*centroid(2);...
         0 0 1];
end

