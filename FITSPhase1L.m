function FITSPhase1L( varargin ) 

    cargs = varargin ;
    optargin = size(varargin,2);

    passarge ;

    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    runID = ceil(100000*rand(1,1) ) + feature('getpid')  
    aRFSR =[60,100];
    maxClusters = 8 ;
    msc = 11 ;
    maxAllowedLevel 
    chunks = makeChunks(dataName);
    for i = 1:chunks.count
        
       %tic
        %disp('read')
        %read csv file row consist of sites and column consists of samples
        dataX = csvread(dataName) ;
        %toc
        %tic
        %disp('norm')
        M = mean(dataX);
        dataX = dataX./(M + 0.00000001);
        dataX = dataX';
        data = dataX(chunks.res(i).val,:);
        clear dataX;
        %toc
        FITSPhase1Start(data,maxClusters,msc,aRFSR,maxAllowedLevel,strcat('fitsL_',name2save,'_',num2str(i),'_',num2str(runID)),runID);
        indexes = chunks.res(i).val;
        save(strcat('indexes_',name2save,'_',num2str(i),'_',num2str(runID),'.mat'),'indexes','-v6');
    end
end

function result = makeChunks(dataName)
    numberOfSamples = size(csvread(dataName),2);
    chunkSize = 1000;
    v = 1:numberOfSamples;
    rv = randsample(v,length(v));
    nonOverlapChunks = ceil(numberOfSamples/chunkSize);
    res = struct;
    start = 1;
    for i = 1 : nonOverlapChunks
        if i ~= nonOverlapChunks
            res(i).val = rv(start:start+chunkSize-1);
            start = start+chunkSize;
        else
            if i == 1
                res(i).val = rv;
                count = 1;
            else
                if length(rv(start:numberOfSamples)) > 500
                    res(i).val = rv(start:numberOfSamples);
                    count = i;
                else
                    count = i-1;
                    res(i-1).val = rv(start-chunkSize:numberOfSamples);
                end
            end
        end
    end
    overlapChunks = count;
    if overlapChunks > 15
        overlapChunks = 15;
    end
    for i =1:overlapChunks
        res(i+count).val = randsample(v,chunkSize);
    end
    count = count + overlapChunks;
    result = struct;
    result.count = count;
    result.res = res;
end
