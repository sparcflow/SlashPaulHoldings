//JOBCOPY JOB
//* Copy VSAM FILE CICSPROD.ACCOUNT to A FLAT FILE
//STEP0100 EXEC PGM=SORT                    
//SYSOUT   DD  SYSOUT=*                                  
//SORTIN   DD  DSN=CICSPROD.ACCOUNT, 
//             DISP=SHR                                  
//SORTOUT  DD  DSN=BARNEY.FLAT.ACCOUNT, 
//             DISP=(NEW,CATLG,DELETE), 
//             UNIT=SYSDA, 
//             SPACE=(CYL,(20,1),RLSE), 
//             DCB=(LRECL=80,RECFM=FB,BLKSIZE=0) 
//SYSIN    DD  *                                        
  SORT FIELDS=COPY 
/*       
