function data_list = read_data_list2(base_path, classes, data_size, train_or_test, debug)
% read pre-computed volumetric filenames
% base_path: root data folder
% classes: categories to be fetched
% data_size: the size of the volumetric representation
% train_or_test: select training data or testing data('train', 'test')
% debug: true for debug.

if nargin < 5
    debug = 0;
end

if debug
    maxNum = 10*12;
elseif strcmp(train_or_test, 'train')
    maxNum = 80*12;%8%12;
else
    maxNum = 20*12;
end

num_classes = length(classes);
data_list = cell(num_classes,1);
for c = 1 : num_classes
    fprintf('reading the %s category\n', classes{c});
    category_path = [base_path '/' classes{c} '/' num2str(data_size) '/' train_or_test];
    files = dir(category_path);
    
    if c==1
        maxNum=150;
    elseif c==5
        maxNum = 500-20;
    elseif c==4
        maxNum = 911 - 30;
    else
        maxNum = 80*12 - 20;
    end
        
    
    cat_ind = 0;
    data_list{c} = [];
    for i = 1 : length(files)
        idx = i;
        if strcmp(files(idx).name, '.') || strcmp(files(idx).name, '..') || files(idx).isdir == 1 || ~strcmp(files(idx).name(end-2:end), 'mat')
            continue;
        end
        filename = [category_path '/' files(idx).name];
        
        cat_ind = cat_ind + 1;
        data_list{c}(cat_ind,1).filename = filename;
        data_list{c}(cat_ind,1).label = c;
        if cat_ind == maxNum
          break;
        end
    end
    
    % save extra files for testing
    category_path_test = [base_path '/' classes{c} '/' num2str(data_size) '/' 'test'];
    if length(dir(category_path_test))>2
        continue;
    end
    for j=idx+1:idx+20%length(files)
        filename = [category_path '/' files(j).name];
        %cat_ind = cat_ind + 1;
        movefile(filename, [category_path_test '/' files(j).name]);
        %data_list{c}(cat_ind,1).filename = filename;
        %data_list{c}(cat_ind,1).label = c;
    end
    fprintf('fetched %d number of instances\n', cat_ind);
end

