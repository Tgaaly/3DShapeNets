% Layer-wise pretraining.
rng('shuffle');
kernels;

param = [];
param.debug = 0;
param.volume_size = 21;
param.pad_size = 0;
data_size = param.volume_size + 2 * param.pad_size;

%% load data
% param.data_path = '~/Dropbox/3dprior/data_CDBM_semantic_v3_semantic_abstract_da';%data_CDBM_semantic_v3_semantic';%data_CDBM_synthetic';%data_CDBM_semantic';
% load([param.data_path '/classlabels.mat']);
% param.classnames = unique_semantic_labels;%{'good','bad'};
param.data_path = '~/Dropbox/3dprior/data_CDBM_synthetic';%data_CDBM_semantic_v3_semantic';%data_CDBM_synthetic';%data_CDBM_semantic';
param.classnames = {'good', 'bad'};
param.classes = length(param.classnames)
data_list = read_data_list(param.data_path, param.classnames, data_size, 'train', param.debug);

%% 
param.network = {
    struct('type', 'input');
    struct('type', 'convolution', 'outputMaps', 32, 'kernelSize', 11, 'actFun', 'sigmoid', 'stride', 2);
    %struct('type', 'convolution', 'outputMaps', 160, 'kernelSize', 6, 'actFun', 'sigmoid', 'stride', 1);
    %struct('type', 'convolution', 'outputMaps', 512, 'kernelSize', 4, 'actFun', 'sigmoid', 'stride', 1);
    %struct('type', 'fullconnected', 'size', 1200, 'actFun', 'sigmoid');%64, 'actFun', 'sigmoid');
    struct('type', 'fullconnected', 'size', 2000, 'actFun', 'sigmoid');%80, 'actFun', 'sigmoid');
};


% This is to duplicate the labels for the final RBM in order to enforce the
% label training.
param.duplicate = 10;
param.validation = 1;
param.data_size = [data_size, data_size, data_size, 1];

model = initialize_cdbn(param);

fprintf('\nmodel initialzation completed!\n\n');
param = [];
param.layer = 2;
param.epochs = 60;
param.lr = 0.015;
param.weight_decay = 1e-5;
param.momentum = [0.5, 0.9];
param.kPCD = 1;
param.persistant = 0;
param.batch_size = 32;
param.sparse_damping = 0;
param.sparse_target = 0.01;
param.sparse_cost = 0.03;
[model] = crbm2(model, data_list, param);


