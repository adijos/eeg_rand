function [pre_ictal_vector, inter_ictal_vector] = eeg_ri(node_no, cluster_sz)

if ~exist('node_no','var'),
    fprintf('selecting default nodes: all\n')
    node_no = [1:16];
end

if ~exist('cluster_sz','var'),
    fprintf('selecting default cluster size:\n')
    cluster_sz = 1 %1
end

N = 100;
k = 50;
num_preictal_segments = 30;
num_interictal_segments = 30;

idx = node_no
RI_nodes = zeros(N,length(idx));
k_idx = randi(N,1,2*k);

RI_nodes(k_idx(1:end/2)) = 1;
%RI_nodes(k_idx(end/2:end)) = -1;

% pre ictal data
pre_ictal_vector = zeros(N,1);
for i=1:num_preictal_segments;
    fprintf(['pre:',int2str(i),'\n'])
    pre_data_base = ['./dog_2/Dog_2_preictal_segment_00'];
    if i <= 9,
        pre_data = load([pre_data_base,'0',int2str(i),'.mat']);
    else
        pre_data = load([pre_data_base,int2str(i),'.mat']);
    end
    pre_data = getfield(pre_data,['preictal_segment_',int2str(i)]);
    pre_data = pre_data.data;
    
    pre_ictal_vector = pre_ictal_vector + make_vector(pre_data, N, idx, cluster_sz, RI_nodes);
    
end
fprintf('done with pre\n')
%%
%inter ictal data
inter_ictal_vector = zeros(N,1);
for i=1:num_interictal_segments;
    inter_data_base = ['./dog_2/Dog_2_interictal_segment_0'];
    fprintf(['inter:',int2str(i),'\n'])
    if i <= 9,
        inter_data = load([inter_data_base,'00',int2str(i),'.mat']);
    elseif i > 9 && i < 100,
        inter_data = load([inter_data_base, '0', int2str(i),'.mat']);
    else,
        inter_data = load([inter_data_base,int2str(i),'.mat']);
    end
    inter_data = getfield(inter_data,['interictal_segment_',int2str(i)]);
    inter_data = inter_data.data;
    inter_ictal_vector = inter_ictal_vector + make_vector(pre_data, N, idx, cluster_sz, RI_nodes);
    
    
end
fprintf('done with inter\n')

%sprintf('printing cosine between one pre ictal and interictal vector')
size(pre_ictal_vector);
size(inter_ictal_vector);
pre_ictal_vector_n = pre_ictal_vector/norm(pre_ictal_vector);
inter_ictal_vector_n = inter_ictal_vector/norm(inter_ictal_vector);
dotty = pre_ictal_vector_n'* inter_ictal_vector_n;
fprintf(['dotty: ', num2str(dotty), '\n'])
if (1 - dotty) < 1e-8
    sprintf('pre_ictal and post ictal are the same')
    return
end


%% testing preictal

% load test data
total_test = 12;
correct = 0;
for i=num_preictal_segments+1:num_preictal_segments+total_test;
    pre_data_base = ['./dog_2/Dog_2_preictal_segment_00'];
    if i <= 9,
        test_data = load([pre_data_base,'0',int2str(i),'.mat']);
    else
        test_data = load([pre_data_base,int2str(i),'.mat']);
    end
    test_data = getfield(test_data,['preictal_segment_',int2str(i)]);
    test_data = test_data.data;
    test_vector = make_vector(test_data, N, idx, cluster_sz, RI_nodes);
    
    test_vector_n = test_vector/norm(test_vector);

    % compare with trained pre and inter vectors
    cosangles = zeros(2,1);
    cosangles(1) = pre_ictal_vector_n'*test_vector_n;
    cosangles(2) = inter_ictal_vector_n'*test_vector_n;

    if max(cosangles) == cosangles(1)
        %sprintf('preictal data')
        correct = correct + 1;
    else
        %sprintf('inter ictal data')
    end
    fprintf([int2str(i),'; ', num2str(cosangles(1)),'; ', num2str(cosangles(2)),'\n'])
end
percent = correct/total_test;
sprintf(['percentage of preictal test data correct: ',num2str(percent*100)])

%% testing ictal

% load test data
total_test = 12;
correct = 0;
for i=num_interictal_segments+1:num_interictal_segments+total_test;
    inter_data_base = ['./dog_2/Dog_2_interictal_segment_0'];
    if i <= 9,
        test_data = load([inter_data_base,'00',int2str(i),'.mat']);
    elseif i > 9 && i < 100,
        test_data = load([inter_data_base, '0', int2str(i),'.mat']);
    else,
        test_data = load([inter_data_base,int2str(i),'.mat']);
    end
    test_data = getfield(test_data,['interictal_segment_',int2str(i)]);
    test_data = test_data.data;
    test_vector = make_vec(test_data, N, idx, cluster_sz, RI_nodes);
    
    test_vector_n = test_vector/norm(test_vector);
%     for t=1:size(test_data,2);
%         test_vector = test_vector + RI_nodes*test_data(idx,t);
%         %test_vector = circshift(test_vector,1);
%     end
%     test_vector_n = test_vector/norm(test_vector);

    % compare with trained pre and inter vectors
    cosangles = zeros(2,1);
    cosangles(1) = pre_ictal_vector_n'*test_vector_n;
    cosangles(2) = inter_ictal_vector_n'*test_vector_n;

    if max(cosangles) == cosangles(2)
        %sprintf('preictal data')
        correct = correct + 1;
    else
        %sprintf('inter ictal data')
    end
end
percent = correct/total_test;
sprintf(['percentage of interictal test data correct: ',num2str(percent*100)])
end
