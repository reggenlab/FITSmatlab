function FITSPhase2(varargin)
    
    cargs = varargin ;
    optargin = size(varargin,2);

    passarge2 ;
    files = dir(strcat(name2save,'_*.mat'));
    dataX = csvread(dataName) ;
    M = mean(dataX);
    dataX = dataX./(M + 0.00000001);
    dataX = dataX';
    dataX=log(dataX+1.01);
    trees=struct;
    start=1;
    for t = 1:size(files,1)
        try
           obj = load(files(t).name);
           trees(start).val = obj.final_imputed;
           %size(trees(start).val);
           start = start+1;
        catch
           %numOfTrees = numOfTrees-1;
           disp(files(t).name);
           disp('This is either corrupted or not exist');
        end
    end
    [row, col] = size(dataX);
    if (topk > start-1)
       topk = start-1;
    end
    maxCorrelated(dataX,trees,start-1,topk,colWise,name2save);
    %save(strcat(name2save,'_.mat'),'final_imputed','-v7.3');
end

function res = maxCorrelated(mOriginal,mtree,count,topk,colWise,name2save)
    if colWise==1
        final_imputed = maxCorrelatedCol(mOriginal,mtree,count,topk);
        %save(strcat(name2save,'.mat'),'final_imputed','-v7.3');
        
    else
        final_imputed = maxCorrelatedRow(mOriginal,mtree,count,topk);
        %save(strcat(name2save,'.mat'),'final_imputed','-v7.3');
    end
    csvwrite(strcat(name2save,'.csv'),final_imputed')
end

% correlation between features
function res = maxCorrelatedCol(mOriginal,mtree,count,topk)
  [row, col] = size(mOriginal);
    res = zeros(row,col);
    for i = 1 : col
        corrAll = [];
        for j = 1 : count
           cor = corr(mtree(j).val(:,i),mOriginal(:,i),'Type','Spearman');
           corrAll = [corrAll; cor];
        end
        [~, c_order] = sort(corrAll,'descend');
        newMatrix = zeros(row,topk);
        for j = 1:topk
            newMatrix(:,j) = mtree(c_order(j)).val(:,i);
        end
        res(:,i) = max(newMatrix')';
    end
end

% %correlation between samples
function res = maxCorrelatedRow(mOriginal,mtree,count,topk)
    [row, col] = size(mOriginal);
    res = zeros(row,col);
    for i = 1 : row
        corrAll = [];
        for j = 1 : count
           cor = corr(mtree(j).val(i,:)',mOriginal(i,:)','Type','Spearman');
           corrAll = [corrAll; cor];
        end
        [~, c_order] = sort(corrAll,'descend');
        newMatrix = zeros(topk,col);
        for j = 1:topk
            newMatrix(j,:) = mtree(c_order(j)).val(i,:);
        end
        res(i,:) = max(newMatrix);
    end
end
