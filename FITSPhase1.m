function FITSPhase1( varargin ) 

    cargs = varargin ;
    optargin = size(varargin,2);

    passarge ;

    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    runID = ceil(100000*rand(1,1) ) + feature('getpid')  
    aRFSR =[60,100];
    maxClusters = 8 ;
    msc = 11 ;
    maxAllowedLevel 
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
    %toc
    FITSPhase1Start(dataX,maxClusters,msc,aRFSR,maxAllowedLevel,name2save,runID);
end
