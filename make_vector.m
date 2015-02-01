function [data_vec] = make_vector(data, N, idx, cluster_sz, RI_nodes),
data_vec = zeros(N,1);
for t=1:size(data,2);
    if t - cluster_sz <= 0,
        continue;
    else,
        prod = ones(N,1);
        for s=t-cluster_sz+1:t,
            nodes = zeros(16,1);
            live_node = find(abs(data(idx,s)) == max(abs(data(idx,s))));
            nodes(live_node) = 1;
            data_strip = nodes.*data(idx,s);
            data_strip = abs(data_strip/norm(data_strip));
            prod = prod.*(RI_nodes*data_strip);
            prod = [prod(end,:); prod(1:end-1,:)];
        end
        data_vec = data_vec + prod;
    end 
end
end