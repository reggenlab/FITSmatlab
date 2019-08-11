dataName = 'xyz' ;
topk = 3 ;
colWise = 0;
name2save = 'FITSOutput';
vartrack = zeros(4 ,1) ;

for i = 1:optargin
    checkt = textscan( cargs{i} , '%s' , 'delimiter' , '=') ;

    if (strcmp( checkt{1}{1} , 'input' ) == 1)
        dataName = checkt{1}{2} ;
        vartrack(1) = 1 ;
    end

    if (strcmp( checkt{1}{1} , 'output' ) == 1)
       name2save = checkt{1}{2} ;
       vartrack(2) = 1 ;
    end

    if (strcmp( checkt{1}{1} , 'k' ) == 1)
        tempd =  textscan(checkt{1}{2} , '%d')  ;
        topk  = tempd{1}    
       vartrack(3) = 1 ;
    end

    if (strcmp( checkt{1}{1} , 'feature' ) == 1)
        tempd =  textscan(checkt{1}{2} , '%d')  ;
        colWise  = tempd{1}
       vartrack(4) = 1 ;
    end

end



disptext = { 
'input=inputCountFile    filename of read-counts csv file, no need to provide genomic location( this file should be same as file used in FITSPhase1)' 
'             '
           
'output=OUPUTfile    filename of imputed matrix to be saved( this file should be same as file name passed in FITSPhase1 if not passed there then not pass here too)'
'            '

'k= topk default 3 if you want to make matrix based on top5 then pass k=5  '  
'        '

'feature= 0/1 default 0 (it compute sample wise correlation<Preffered>) if you want to feature wise correlation then pass one.  '
'        '
} ;




if( (vartrack(1) == 0 ) | (vartrack(2) == 0 ) )
    fprintf('%s\n', disptext{:}) ;
end

if(vartrack(1) == 0 )
   disp('errors : No sample data file given' );
   exit(1) ; 
end

if(vartrack(2) == 0 )
   disp('warning : No output file name given therefore file save with default name FITSOutput.csv');
    
end

