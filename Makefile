
## Get global settings; TRACKS (e22...,) REV (v0), REL (0), SITE (mpifr), EXPROOT (/Exps)
include Makefile.inc

## Derived set of v2d,vex in both conventional zoom setup and outputband setup
DIFX_TARGETS_ZOOM := $(addsuffix _b1,$(TRACKS)) $(addsuffix _b2,$(TRACKS)) $(addsuffix _b3,$(TRACKS)) $(addsuffix _b4,$(TRACKS))
DIFX_TARGETS_OUTPUTBAND := $(addsuffix _ob,$(DIFX_TARGETS_ZOOM))
DIFX_TARGETS := $(DIFX_TARGETS_ZOOM) $(DIFX_TARGETS_OUTPUTBAND)

.NOTPARALLEL:  # note: quite slow build, commented out again; but be careful to do 'make all' and then 'make install' as separate steps, not 'make all install'

default: all

## Target 'prerequisites' for the first run only:
##  - split observed VEX into shared file fragments common to all bands and setups
##  - produce common EOP for all bands and setups
##  - create blank clock files (later refined/overwritten by actual results from manual fringe searches)
##  - create initial clock files for SMA from their spreadsheet data files for each day
##  - create NOEMA phase ref $SITE coordinates for each track (to avoid shadowing they often switch ref antenna on different days)
##  - create standard ALMA and NOEMA freq setup VEX chan_def's
prerequisites:
	mkdir -p out
	mkdir -p out/conventional/
	mkdir -p out/outputbands/
	. scripts/extract_vex_portions.sh
	. scripts/create_vex_EOPs.sh
	. scripts/make_initial_clocks.sh
	. scripts/make_initial_notes.sh
	## NOEMA Array Reference Positions
	for exptname in $(TRACKS); do \
		./scripts/vlbimonitordb/vlbimon-get-noemaPosition.py $${exptname} > ./templates/common_sections/sites_NOEMA_$${exptname}.vex ; \
	done
	# ./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 1,2 > templates/230G/band2/freqs_NOEMA.vex # commented out after decision 5/2021 to ignore the 4x64 MHz overlap of b2 into recorder1
	# ./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 3,4 > templates/230G/band3/freqs_NOEMA.vex
	## 230G
	./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 1   > templates/230G/band1/freqs_NOEMA.vex
	./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 2   > templates/230G/band2/freqs_NOEMA.vex
	./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 4   > templates/230G/band3/freqs_NOEMA.vex
	./scripts/noema-vex-defs.py --lo1 221.100 --lo2 7.744 -r 3   > templates/230G/band4/freqs_NOEMA.vex
	./scripts/alma-vex-defs.py --lo1 221.100 -r 1 > templates/230G/band1/freqs_ALMA.vex
	./scripts/alma-vex-defs.py --lo1 221.100 -r 2 > templates/230G/band2/freqs_ALMA.vex
	./scripts/alma-vex-defs.py --lo1 221.100 -r 3 > templates/230G/band3/freqs_ALMA.vex
	./scripts/alma-vex-defs.py --lo1 221.100 -r 4 > templates/230G/band4/freqs_ALMA.vex
	## Note: DiFX $ehtc/alma-vex-defs.py would be more direct, but its chan_defs are not useable as-is,
	##       vs own ./scripts/alma-vex-defs.py usable for that but is not 4-8/5-9 aware plus b2 offset trickyness
	## SMA a priori clock CSV files
	./scripts/vexdelay.py -f ./priors/sma-delays.rx230.sbLSB.quad1.b1.csv -c 0.5126 --rate=-0.090e-12 -s Sw -g 0.0 2022y076d21h44m00s 2022y086d12h25m00s > templates/230G/band1/clocks_SMA.vex
	./scripts/vexdelay.py -f ./priors/sma-delays.rx230.sbLSB.quad0.b2.csv -c 0.5126 --rate=-0.090e-12 -s Sw -g 0.0 2022y076d21h44m00s 2022y086d12h25m00s > templates/230G/band2/clocks_SMA.vex
	./scripts/vexdelay.py -f ./priors/sma-delays.rx230.sbUSB.quad1.b3.csv -c 0.5126 --rate=-0.090e-12 -s Sw -g 0.0 2022y076d21h44m00s 2022y086d12h25m00s > templates/230G/band3/clocks_SMA.vex
	./scripts/vexdelay.py -f ./priors/sma-delays.rx230.sbUSB.quad2.b4.csv -c 0.5126 --rate=-0.090e-12 -s Sw -g 0.0 2022y076d21h44m00s 2022y086d12h25m00s > templates/230G/band4/clocks_SMA.vex

datadirsDR2022:
	for exptname in $(TRACKS); do \
		mkdatadir $${exptname} ; \
		for station in Aa Pv Lm Gl Sw; do \
			mkdatadir $${exptname}/$${station} ; \
			mkdatadir $${exptname}/$${station}/12 ; \
			mkdatadir $${exptname}/$${station}/34 ; \
		done ; \
		mkdatadir $${exptname}/Nn ; \
		mkdatadir $${exptname}/Nn/1 ; \
		mkdatadir $${exptname}/Nn/2 ; \
		mkdatadir $${exptname}/Nn/3 ; \
		mkdatadir $${exptname}/Nn/4 ; \
	done


####################################################################################
## Build and install full correlation v2d vex config sets
####################################################################################

all: $(DIFX_TARGETS)

install: b1_install b2_install b3_install b4_install

diff: b1_diff b2_diff b3_diff b4_diff

%_install:
	for exptname in $(TRACKS); do \
		mkdir -p $(EXPROOT)/$${exptname}/$(REV)/$*/ ; \
		mkdir -p $(EXPROOT)/$${exptname}/$(REV)/$*_outputbands/ ; \
		cp -av out/conventional/$${exptname}-${REL}-$*.{v2d,vex.obs} $(EXPROOT)/$${exptname}/$(REV)/$*/ ; \
		cp -av out/outputbands/$${exptname}-${REL}-$*.{v2d,vex.obs} $(EXPROOT)/$${exptname}/$(REV)/$*_outputbands/ ; \
	done

%_diff:
	for exptname in $(TRACKS); do \
		diff -u $(EXPROOT)/$${exptname}/$(REV)/$*_outputbands/$${exptname}-$(REL)-$*.vex.obs out/outputbands/$${exptname}-$(REL)-$*.vex.obs && true ; \
	done ; \
	for exptname in $(TRACKS); do \
		diff -u $(EXPROOT)/$${exptname}/$(REV)/$*_outputbands/$${exptname}-$(REL)-$*.v2d out/outputbands/$${exptname}-$(REL)-$*.v2d && true ; \
	done ; exit 0

####################################################################################
## EHT 2022 -- Band 1
####################################################################################

# Generic band 1 build patterns
%_b1:
	@ ./tvex2vex.py -I./templates/230G/band1/ -I./templates/common_sections/ templates/$*.vext out/conventional/$*-$(REL)-b1.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band1/ -I./templates/common_sections/ templates/$*.v2dt out/conventional/$*-$(REL)-b1.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b1.vex.obs/g" out/conventional/$*-$(REL)-b1.v2d
	#
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.114 # LMT extra offsets/g" out/conventional/e22g18-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.355 # LMT extra offsets/g" out/conventional/e22b19-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.359 # LMT extra offsets/g" out/conventional/e22c20-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.36967 # LMT extra offsets/g" out/conventional/e22f27-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.33384 # LMT extra offsets/g" out/conventional/e22e22-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.32628 # LMT extra offsets/g" out/conventional/e22d23-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.35019 # LMT extra offsets/g" out/conventional/e22a26-$(REL)-b1.v2d
	#
	#done:
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.557 # SMA extra offsets/g" out/conventional/e22g18-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.264 # SMA extra offsets/g" out/conventional/e22b19-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.256 # SMA extra offsets/g" out/conventional/e22c20-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2013 # SMA extra offsets/g" out/conventional/e22f27-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2668 # SMA extra offsets/g" out/conventional/e22e22-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2497 # SMA extra offsets/g" out/conventional/e22d23-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2232 # SMA extra offsets/g" out/conventional/e22a26-$(REL)-b1.v2d

%_b1_ob:
	@ ./tvex2vex.py -I./templates/230G/band1/ -I./templates/common_sections/ templates/$*.vext out/outputbands/$*-$(REL)-b1.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band1/ -I./templates/common_sections/ templates/$*_outputbands.v2dt out/outputbands/$*-$(REL)-b1.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b1.vex.obs/g" out/outputbands/$*-$(REL)-b1.v2d
	#
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.114 # LMT extra offsets/g" out/outputbands/e22g18-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.355 # LMT extra offsets/g" out/outputbands/e22b19-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.359 # LMT extra offsets/g" out/outputbands/e22c20-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.36967 # LMT extra offsets/g" out/outputbands/e22f27-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.33384 # LMT extra offsets/g" out/outputbands/e22e22-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.32628 # LMT extra offsets/g" out/outputbands/e22d23-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.35019 # LMT extra offsets/g" out/outputbands/e22a26-$(REL)-b1.v2d
	#
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.557 # SMA extra offsets/g" out/outputbands/e22g18-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.264 # SMA extra offsets/g" out/outputbands/e22b19-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.256 # SMA extra offsets/g" out/outputbands/e22c20-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2013 # SMA extra offsets/g" out/outputbands/e22f27-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2668 # SMA extra offsets/g" out/outputbands/e22e22-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2497 # SMA extra offsets/g" out/outputbands/e22d23-$(REL)-b1.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.2232 # SMA extra offsets/g" out/outputbands/e22a26-$(REL)-b1.v2d

# Custom-fiddled band 1 builds
# (none)

####################################################################################
## EHT 2022 -- Band 2
####################################################################################

# Generic band 2 build patterns
%_b2:
	@ ./tvex2vex.py -I./templates/230G/band2/ -I./templates/common_sections/ templates/$*.vext out/conventional/$*-$(REL)-b2.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band2/ -I./templates/common_sections/ templates/$*.v2dt out/conventional/$*-$(REL)-b2.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b2.vex.obs/g" out/conventional/$*-$(REL)-b2.v2d

%_b2_ob:
	@ ./tvex2vex.py -I./templates/230G/band2/ -I./templates/common_sections/ templates/$*.vext out/outputbands/$*-$(REL)-b2.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band2/ -I./templates/common_sections/ templates/$*_outputbands.v2dt out/outputbands/$*-$(REL)-b2.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b2.vex.obs/g" out/outputbands/$*-$(REL)-b2.v2d

# Custom-fiddled band 2 builds
# (none)

####################################################################################
## EHT 2022 -- Band 3
####################################################################################

# Generic band 3 build patterns
%_b3:
	@ ./tvex2vex.py -I./templates/230G/band3/ -I./templates/common_sections/ templates/$*.vext out/conventional/$*-$(REL)-b3.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band3/ -I./templates/common_sections/ templates/$*.v2dt out/conventional/$*-$(REL)-b3.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b3.vex.obs/g" out/conventional/$*-$(REL)-b3.v2d

%_b3_ob:
	@ ./tvex2vex.py -I./templates/230G/band3/ -I./templates/common_sections/ templates/$*.vext out/outputbands/$*-$(REL)-b3.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band3/ -I./templates/common_sections/ templates/$*_outputbands.v2dt out/outputbands/$*-$(REL)-b3.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b3.vex.obs/g" out/outputbands/$*-$(REL)-b3.v2d

# Custom-fiddled band 3 builds
# (none)

####################################################################################
## EHT 2022 -- Band 4
####################################################################################

# Generic band 4 build patterns
%_b4:
	@ ./tvex2vex.py -I./templates/230G/band4/ -I./templates/common_sections/ templates/$*.vext out/conventional/$*-$(REL)-b4.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band4/ -I./templates/common_sections/ templates/$*.v2dt out/conventional/$*-$(REL)-b4.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b4.vex.obs/g" out/conventional/$*-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.168 # LMT extra offsets/g" out/conventional/e22g18-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.424 # LMT extra offsets/g" out/conventional/e22c20-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.409 # LMT extra offsets/g" out/conventional/e22e22-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.410 # LMT extra offsets/g" out/conventional/e22d23-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.445 # LMT extra offsets/g" out/conventional/e22a26-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.445 # LMT extra offsets/g" out/conventional/e22f27-$(REL)-b4.v2d
	#
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.462 # SMA extra offsets/g" out/conventional/e22g18-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/conventional/e22b19-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/conventional/e22c20-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/conventional/e22e22-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/conventional/e22d23-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.18 # SMA extra offsets/g" out/conventional/e22a26-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.12 # SMA extra offsets/g" out/conventional/e22f27-$(REL)-b4.v2d

%_b4_ob:
	@ ./tvex2vex.py -I./templates/230G/band4/ -I./templates/common_sections/ templates/$*.vext out/outputbands/$*-$(REL)-b4.vex.obs
	@ ./tvex2vex.py -I./templates/230G/band4/ -I./templates/common_sections/ templates/$*_outputbands.v2dt out/outputbands/$*-$(REL)-b4.v2d
	@ sed -i "s/vexfilename/$*-${REL}-b4.vex.obs/g" out/outputbands/$*-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.168 # LMT extra offsets/g" out/outputbands/e22g18-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.424 # LMT extra offsets/g" out/outputbands/e22c20-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.409 # LMT extra offsets/g" out/outputbands/e22e22-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.410 # LMT extra offsets/g" out/outputbands/e22d23-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.445 # LMT extra offsets/g" out/outputbands/e22a26-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # LMT extra offsets/deltaClock = 0.445 # LMT extra offsets/g" out/outputbands/e22f27-$(REL)-b4.v2d
	#
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.462 # SMA extra offsets/g" out/outputbands/e22g18-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/outputbands/e22b19-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/outputbands/e22c20-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/outputbands/e22e22-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.19 # SMA extra offsets/g" out/outputbands/e22d23-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.18 # SMA extra offsets/g" out/outputbands/e22a26-$(REL)-b4.v2d
	sed -i "s/deltaClock = 0 # SMA extra offsets/deltaClock = -105.12 # SMA extra offsets/g" out/outputbands/e22f27-$(REL)-b4.v2d

# Custom-fiddled band 3 builds
# (none)

####################################################################################

