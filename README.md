"# FITS Matlab version" 

You have to download matlab code in your local machine/server. For execution you have to pass filename of read-counts csv as a input file. Read-count csv file does not contain header and genomic location i.e. it consist of only data on which imputation is going to perform. Row represents sites and column reprent samples/cells in csv file.

```matlab
FITSPhase1 input='<csv file name>'
e.g.
FITSPhase1 input='sce5_raw.csv'
```
'sce5_raw.csv' consist of epignome data corresponding to five cell type.

Other optional input parameter you can pass in phase1 

```matlab
FITSPhase1 input='<csv file name>' output='<name to save imputed file>' maxLevel =<Depth upto which tree will grow>
```

By default maxLevel set to 4 and output set to 'FITSOutput'.
You can run FITSPhase1 parallely in background using  

```bash
nohup matlab -nodisplay -nosplash -r "try FITSPhase1 input='<csv file name>'; catch; end; quit" > <name>.txt &
```
You can create n number of imputed matrix generated through phase1. Each run will generate imputed matrix.

Once Phase1 is over then run Phase2 to generate final imputed matrix based on matrix received as output from Phase1.

```matlab
FITSPhase2 input='<csv file name>'
e.g.
FITSPhase2 input='sce5_raw.csv'
```
You have to pass same input file as you passed in Phase1. Don't worry Phase2 takes only one minute to generate final output :)

Other optional input parameter you can pass in phase2 

```matlab
FITSPhase2 input='<csv file name>' output='<name to save imputed file same as Phase1>' k =<topk correlated matrix feature/sample value use for final imputation> feature=<1/0 takes values either 1 or 0> 
```
Default value for feature is zero. At value 0 phase2 will compute correlation among samples/cell (preffered) while value 1 will compute correlation features/sites wise.
