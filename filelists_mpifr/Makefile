
M6DIRS := /cluster/difx/directories/

all:
	@echo "Options:  'make bonn'  or  'make hays'"

mk6dir2filelist = grep "^e22" $(M6DIRS)/$(3).filelist | sort -k 2 | sed -e 's/^/\/$(1)_fuse\/$(2)\//' | cut -d' ' -f 1,2,3 > $(4)

bonn: aa_b1 aa_b4 ax_b1 ax_b4 gl_b1 gl_b4 mm_b1 mm_b4 mg_b1 mg_b4 \
	kt_b1 kt_b4 lm_b1 lm_b4 nn_b1 nn_b4 pv_b1 pv_b4 sw_b1 sw_b4 \
	sz_b1 sz_b4

hays: pv_b2 pv_b3

## ALMA

aa_b1:
	$(call mk6dir2filelist,mark6-02,12,EHT%1231,ALMA_b1.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,EHT%1233,ALMA_b1.34.filelist)

aa_b4:
	$(call mk6dir2filelist,mark6-02,12,EHT%1259,ALMA_b4.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,EHT%1261,ALMA_b4.34.filelist)

## APEX

ax_b1:
	$(call mk6dir2filelist,mark6-02,12,EHT%1248,APEX_b1.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,EHT%1249,APEX_b1.34.filelist)

ax_b4:
	$(call mk6dir2filelist,mark6-02,12,MPI%6400,APEX_b4.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,EHT%1246,APEX_b4.34.filelist)

## GLT

gl_b1:
	$(call mk6dir2filelist,mark6-11,12,BHC%0114,GLT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,BHC%0116,GLT_b1.34.filelist)

gl_b4:
	$(call mk6dir2filelist,mark6-11,12,BHC%0122,GLT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,BHC%0130,GLT_b4.34.filelist)

## JCMT

mm_b1:
	$(call mk6dir2filelist,mark6-11,12,BHC%0072,JCMT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,BHC%0080,JCMT_b1.34.filelist)

mm_b4:
	$(call mk6dir2filelist,mark6-11,12,BHC%0079,JCMT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,BHC%0083,JCMT_b4.34.filelist)

## Kitt Peak

kt_b1:
	$(call mk6dir2filelist,mark6-10,12,EHT%1201,KT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-10,34,EHT%1203,KT_b1.34.filelist)

kt_b4:
	$(call mk6dir2filelist,mark6-10,12,EHT%1218,KT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-10,34,EHT%1220,KT_b4.34.filelist)

## LMT

lm_b1:
	$(call mk6dir2filelist,mark6-02,12,BHC%0144,LMT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,BHC%0146,LMT_b1.34.filelist)

lm_b4:
	$(call mk6dir2filelist,mark6-02,12,ALMA%025,LMT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-02,34,ALMA%027,LMT_b4.34.filelist)

## NOEMA
	
nn_b1:
	$(call mk6dir2filelist,mark6-04,1,MPI%8010,NOEMA-b1.1.filelist)
	$(call mk6dir2filelist,mark6-04,2,MPI%8035,NOEMA-b1.2.filelist)
	$(call mk6dir2filelist,mark6-04,3,MPI%8057,NOEMA-b1.3.filelist)
	$(call mk6dir2filelist,mark6-04,4,MPI%8058,NOEMA-b1.4.filelist)

nn_b4:
	$(call mk6dir2filelist,mark6-04,1,IRAM%005,NOEMA-b4.1.filelist)
	$(call mk6dir2filelist,mark6-04,2,IRAM%006,NOEMA-b4.2.filelist)
	$(call mk6dir2filelist,mark6-04,3,IRAM%007,NOEMA-b4.3.filelist)
	$(call mk6dir2filelist,mark6-04,4,IRAM%008,NOEMA-b4.4.filelist)

## Pico

pv_b1:
	$(call mk6dir2filelist,mark6-09,12,EHT%0076,Pico_b1.12.filelist)
	$(call mk6dir2filelist,mark6-09,34,EHT%0082,Pico_b1.34.filelist)

pv_b4:
	$(call mk6dir2filelist,mark6-10,12,EHT%0092,Pico_b4.12.filelist)
	$(call mk6dir2filelist,mark6-10,34,EHT%0098,Pico_b4.34.filelist)

## SMA APHIDS

sw_b1: # todo, not shipped yet (as of 03/2023)
	$(call mk6dir2filelist,mark6-11,12,GLT%0017,SMA_b1.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,GLT%0019,SMA_b1.34.filelist)

sw_b4: # todo, not shipped yet (as of 03/2023)
	$(call mk6dir2filelist,mark6-11,12,PERI%039,SMA_b4.12.filelist)
	$(call mk6dir2filelist,mark6-11,34,PERI%041,SMA_b4.34.filelist)

## SMT

mg_b1:
	$(call mk6dir2filelist,mark6-09,12,EHT%1101,SMT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-09,34,EHT%1212,SMT_b1.34.filelist)

mg_b4:
	$(call mk6dir2filelist,mark6-09,12,EHT%1101,SMT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-09,34,EHT%1212,SMT_b4.34.filelist)

## SPT

sz_b1:
	$(call mk6dir2filelist,mark6-09,12,EHT%0078,SPT_b1.12.filelist)
	$(call mk6dir2filelist,mark6-09,34,EHT%0080,SPT_b1.34.filelist)

sz_b4:
	$(call mk6dir2filelist,mark6-09,12,SHAO%016,SPT_b4.12.filelist)
	$(call mk6dir2filelist,mark6-09,34,SHAO%049,SPT_b4.34.filelist)

## CHECKING

buglist:
	# All scans that have unexpected time stamps
	grep -v " 59" *.filelist
