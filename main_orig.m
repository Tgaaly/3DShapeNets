clear, close all
dbstop if error

setup_paths
% reset(gpuDevice(1))
run_pretrain_orig();


load('pretrained_model_orig.mat'); %_synthetic_100acc_largenet');

rec_train(model);


%%
% reading the box category
% reading the cylinderical category
% reading the flat category
% reading the spherical category
% reading the torso category
label=1
[samples1] = sample_test_classification(model,label);
show_1_sample(samples1(20,:,:,:))

label=2
[samples2] = sample_test_classification(model,label);
show_1_sample(samples2(20,:,:,:))



%% 
label=1
for i=1:size(samples1,1)
    rec_test_1_obj(model, samples1(i,:,:,:),label);
end
label=2
for i=1:size(samples2,1)
    rec_test_1_obj(model, samples2(i,:,:,:),label);
end


% %%
% rand_sample = zeros(21,21,21);
% prob = rand(21,21,21);
% rand_sample(prob>0.5)=1;
% voxels(1,:,:,:)=rand_sample;
% show_1_sample(voxels(1,:,:,:));
% rec_test_1_obj(model,voxels(1,:,:,:),0);

%%

run_finetuning(model);

load('finetuned_model.mat');

rec_train(model);