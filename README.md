# DiFX Setup Generator for EHT 2022

Prepares DiFX VEX and v2d files for the EHT 230/345 GHz VLBI obervations 2022.

Usage:

```
git clone https://github.com/mpifr-vlbi/eht2022_difx_templating.git
cd eht2022_difx_templating
git checkout master   # later: checkout of a specific tag rather than 'master'
make prerequisites
make all
make install
```
Detailed notes are on the EHT wiki (https://eht-wiki.haystack.mit.edu/Event_Horizon_Telescope_Home/Observing/2022_April/Correlation and other pages).

Notes:
- ALMA Cycle 7+ used CALC 11, need DIFX_CALC_PROGRAM=difxcalc

