function [predicted_label] = rec_test_1_obj(model, instance, gt_label)
% Given the full 3D shape, recognition test for a generative model.
% After the model is (generatively) trained, this function test the
% recognition ability(discriminative) of the model using a seperate test
% data.
% The classification method is free-energy.

debug = 0;
if ~isfield(model.layers{2},'uw')
    model = merge_model(model);
end
global kConv_forward2 kConv_forward_c;

num_layer = length(model.layers);

% test_list = read_data_list(model.data_path, model.classnames, ...
%     model.volume_size + 2 * model.pad_size, 'train', debug);

% label = [];
% new_list = repmat(struct('filename', '', 'label', 0), 1, 1);
% now = 1;
% for i = 1 : model.classes
%     cnt = length(test_list{i});
%     label(now:now+cnt-1,1) = i;
%     new_list(now:now+cnt-1,1) = test_list{i};
%     now = now + cnt;
% end
% n = length(label);
label = gt_label;
n=1;
batch_size = 1;
batch_num = 1;%ceil(n / batch_size);
predicted_label = zeros(1, model.classes); % prediction results.
for b = 1 : batch_num
    batch_end = min(n, b * batch_size);
	batch_index = (b-1)*batch_size + 1 : batch_end;
    %batch_data = read_batch(model, new_list(batch_index), false);
    this_size = 1;%size(batch_data, 1);
	
    batch_data = instance;
    
    % propagate/inference bottum up using recognition weight. 
    for l = 2 : num_layer - 1
        if l == 2
            stride = model.layers{l}.stride;
            hidden_presigmoid = myConvolve2(kConv_forward2, batch_data, model.layers{l}.uw, stride, 'forward');
            hidden_presigmoid = bsxfun(@plus, hidden_presigmoid, permute(model.layers{l}.c, [2,3,4,5,1]));
        elseif strcmp(model.layers{l}.type, 'convolution')
            stride = model.layers{l}.stride;
            hidden_presigmoid = myConvolve(kConv_forward_c, batch_data, model.layers{l}.uw, stride, 'forward');
            hidden_presigmoid = bsxfun(@plus, hidden_presigmoid, permute(model.layers{l}.c, [2,3,4,5,1]));
        else
            batch_data = reshape(batch_data, size(batch_data,1), []);
            hidden_presigmoid = bsxfun(@plus, ...
                batch_data * model.layers{l}.uw, model.layers{l}.c);
        end
        batch_data = 1 ./ ( 1 + exp(-hidden_presigmoid) );
    end
	
    batch_data = reshape(batch_data, this_size, []);
    % calculate the free energy for each label hypothesis
    for c = 1 : model.classes
        try_label = zeros(this_size, model.classes);
        try_label(:, c) = 1;
        predicted_label((b-1) * batch_size+1: batch_end, c) = free_energy(model, [try_label, batch_data], num_layer);
    end
    
end

% predicted_label
predicted_label_norm = bsxfun(@rdivide, predicted_label, sum(predicted_label, 2));
[~, predicted_label] = max(predicted_label_norm, [], 2);
% predicted_label_norm
%[label predicted_label]
% predicted_label
% conf_mat = confusionmat(label, predicted_label)
% % confusion_matrix(label, predicted_label,model.classnames);gt\
gt_label_vect = zeros(1,length(predicted_label_norm));
gt_label_vect(gt_label) = 1;
prob_correct = mnpdf(gt_label_vect,predicted_label_norm);
% disp(['probability correct: ',num2str(prob_correct)])
% conf_mat=fliplr(conf_mat);
% imagesc(confusionmat(label, predicted_label))
%HeatMap(conf_mat', 'RowLabels', model.classnames, 'ColumnLabels', flip(model.classnames));%, 1,'Colormap','red','ShowAllTicks',1,'UseLogColorMap',true,'Colorbar',true);
%plotconfusion(label, predicted_label, model.classnames);
acc = sum(predicted_label == label) / n;
fprintf('acc is : %f\n', acc * 100);
