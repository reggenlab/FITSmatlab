function FITSPhase2L(varargin)
    %tic
    cargs = varargin ;
    optargin = size(varargin,2);

    passarge2 ;
    disp('Long can only run sample wise');
    colWise = 0;
    dataX = csvread(dataName) ;
    M = mean(dataX);
    dataX = dataX./(M + 0.00000001);
    dataX = dataX';
    dataX=log(dataX+1.01);
    corrStruct = struct;
    for i = 1:size(dataX,1)
        corrStruct(i).val = [];
        corrStruct(i).tree = [];
        corrStruct(i).isR = [];        
        corrStruct(i).index = [];        
        corrStruct(i).row = struct;            
        corrStruct(i).found = 0;
    end
    index_files = dir(strcat('indexes_',name2save,'_*.mat'));
    file_dict = struct;
    start = 1;
    for t = 1:size(index_files,1)
        %disp('tte');
        %t
        try
           obj = load(index_files(t).name);
           file_dict(start).val = obj.indexes;
           c = strsplit(index_files(t).name,'indexes_');
           c = strsplit(c{2},'.mat');
           file_dict(start).name = c{1};
           file_dict(start).rfile = 0;
           file_dict(start).file = 0;
           try
               mc = strsplit(file_dict(start).name,'_');
               formed_file_name = strcat('fitsL_',file_dict(start).name,'_',mc{size(mc,2)},'.mat');
               obj = load(formed_file_name);
               if(sum(isnan(obj.final_imputed(:)))==0)
                  file_dict(start).file = 1;
                  file_dict(start).fileName = formed_file_name;
                  corrStruct = corrCalc(dataX,obj.final_imputed,file_dict(start).val,corrStruct,topk,start,0);
                  file_dict(start).val = 0;
               end
           catch
               disp(formed_file_name);
               disp('This is either corrupted or not exist');
           end
           for r = 2:6
               try
                   formed_file_name = strcat('fitsL_',file_dict(start).name,'_r_',num2str(r),'.mat');
                   obj = load(formed_file_name);
                   if(sum(isnan(obj.final_imputed(:)))==0)
                       file_dict(start).rfile = r;
                       file_dict(start).rfileName = formed_file_name;
                       corrStruct = corrCalc(dataX,obj.final_imputed,file_dict(start).val,corrStruct,topk,start,1);
                       file_dict(start).val = 0;
                   end
                   break;
               catch
                   disp('');
               end
           end
           start = start+1;
        catch
           disp(index_files(t).name);
           disp('This is either corrupted or not exist');
        end
    end
    total = start-1;
    matrixUsage = struct;
    for i = 1:total
        matrixUsage(i).normal = [];
        matrixUsage(i).r = [];
        matrixUsage(i).normali = [];
        matrixUsage(i).ri = [];
    end
    %disp('start1');
    matrixUsage = fillMatrixUsage(matrixUsage,corrStruct,size(dataX,1));
    %maxCorrelated(dataX,file_dict,total,topk,name2save);
    [m n] = size(dataX);
    clear dataX;
    %disp('start2');
    matrixFormation(m,n,file_dict,matrixUsage,corrStruct,name2save,total);
    %toc
    %save(strcat(name2save,'_.mat'),'final_imputed','-v7.3');
end

function matrixUsage = fillMatrixUsage(matrixUsage,corrStruct,count)
    for i = 1:count
        for j = 1:size(corrStruct(i).val,2)
%corrStruct(i).val
%corrStruct(i).index
%corrStruct(i).tree
%corrStruct(i).isR
            if (corrStruct(i).isR(j) == 0)
                matrixUsage(corrStruct(i).tree(j)).normal = [matrixUsage(corrStruct(i).tree(j)).normal i] ;
                matrixUsage(corrStruct(i).tree(j)).normali = [matrixUsage(corrStruct(i).tree(j)).normali corrStruct(i).index(j)] ;
            else
                matrixUsage(corrStruct(i).tree(j)).r = [matrixUsage(corrStruct(i).tree(j)).r i] ;
                matrixUsage(corrStruct(i).tree(j)).ri = [matrixUsage(corrStruct(i).tree(j)).ri corrStruct(i).index(j)] ;
            end
        end
    end
end

function corrStruct = corrCalc(dataX,Xrec,indexes,corrStruct,topk,num,isR)
    n = size(indexes,2);
    for i = 1:n
        index = indexes(i);
        cor = corr(dataX(index,:)',Xrec(i,:)','Type','Spearman');
        if (size(corrStruct(index).val,2)<topk)
            corrStruct(index).val = [corrStruct(index).val cor];
            corrStruct(index).tree = [corrStruct(index).tree num];
            corrStruct(index).isR = [corrStruct(index).isR isR];
            corrStruct(index).index = [corrStruct(index).index i];
        else
            [v ind] = min(corrStruct(index).val);
            corrStruct(index).val(ind) = cor;
            corrStruct(index).tree(ind) = num;
            corrStruct(index).isR(ind) = isR;            
            corrStruct(index).index(ind) = i;
        end
    end
end


function res = maxCorrelated(mOriginal,mtree,count,topk,name2save)
   disp('started');
        final_imputed = maxCorrelatedRow(mOriginal,mtree,count,topk);
        %save(strcat(name2save,'.mat'),'final_imputed','-v7.3');
    csvwrite(strcat(name2save,'.csv'),final_imputed')
end

function matrixFormation(m,n,mtree,matrixUsage,corrStruct,name2save,total)
    newMatrix = zeros(m,n);
    for i = 1: total
        if(size(matrixUsage(i).normal,2)>0)
            obj = load(mtree(i).fileName);
            for j = 1 : size(matrixUsage(i).normal,2)
                sample = matrixUsage(i).normal(j);
                index = matrixUsage(i).normali(j);
                corrStruct(sample).row(1+corrStruct(sample).found).val = obj.final_imputed(index,:);
                corrStruct(sample).found = corrStruct(sample).found + 1;
                if(corrStruct(sample).found == size(corrStruct(sample).val,2))
                    nm = zeros(corrStruct(sample).found,n);
                    for k = 1: corrStruct(sample).found
                        nm(k,:) = corrStruct(sample).row(k).val;
                        corrStruct(sample).row(k).val = 0; %clear
                    end
                    newMatrix(sample,:) = max(nm);
                    
                end
            end
        end
        
        if(size(matrixUsage(i).r,2)>0)
            obj = load(mtree(i).rfileName);
            for j = 1 : size(matrixUsage(i).r,2)
                sample = matrixUsage(i).r(j);
                index = matrixUsage(i).ri(j);
                corrStruct(sample).row(1+corrStruct(sample).found).val = obj.final_imputed(index,:);
                corrStruct(sample).found = corrStruct(sample).found + 1;
                if(corrStruct(sample).found == size(corrStruct(sample).val,2))
                    nm = zeros(corrStruct(sample).found,n);
                    for k = 1: corrStruct(sample).found
                        nm(k,:) = corrStruct(sample).row(k).val;
                        corrStruct(sample).row(k).val = 0; %clear
                    end
                    newMatrix(sample,:) = max(nm);
                    
                end
            end
        end
    end
    csvwrite(strcat(name2save,'.csv'),newMatrix');
end

% %correlation between samples
function res = maxCorrelatedRow(mOriginal,mtree,count,topk)
    [row, col] = size(mOriginal);
    res = zeros(row,col);
    disp('func')
    for i = 1 : row
        corrAll = [];
        start = 1;
        ntree = struct;
        findk = 0;
        for j = 1 : count
            if (find(mtree(j).val == i)>0)
                findex = find(mtree(j).val == i);
                if(mtree(j).rfile>0)
                    findk = findk+1;
                    obj = load(mtree(j).rfileName);
                    ntree(start).val = obj.final_imputed(findex,:);
                    cor = corr(ntree(start).val',mOriginal(i,:)','Type','Spearman');
                    corrAll = [corrAll; cor];
                    start = start+1;
                end
                if(mtree(j).file>0)
                    findk = findk+1;
                    obj = load(mtree(j).fileName);
                    ntree(start).val = obj.final_imputed(findex,:);
                    cor = corr(ntree(start).val',mOriginal(i,:)','Type','Spearman');
                    corrAll = [corrAll; cor];
                    start = start+1;
                end
            end
        end
        [~, c_order] = sort(corrAll,'descend');
        if findk > topk
            findk = topk;
        end
        newMatrix = zeros(findk,col);
        for j = 1:findk
            newMatrix(j,:) = ntree(c_order(j)).val;
        end
        res(i,:) = max(newMatrix);
    end
end
