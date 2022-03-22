#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# Pull R2DBE-vs-GPS 1PPS data from VLBI Monitor database.
# Fit a rate. Based on the report_clock_model.py script on the eht-wiki.
#
from __future__ import print_function
import requests
import datetime

from dbSession import dbSession

from argparse import ArgumentParser
import numpy as np

from scipy.stats import linregress
import matplotlib.pyplot as plt

if __name__ == '__main__':

    dbsession = dbSession()

    plt.ion()

    default_sites = ['SMTO','JCMT','APEX','GLT','SPT','LMT','PICO','KP']
    default_bands = [1,2,3,4]
    rate_units = ['s/s','ms/s','us/s','ns/s','ps/s','fs/s']
    offset_units = ['s','ms','us','ns','ps','fs']
    ap = ArgumentParser()
    ap.add_argument('--sites', nargs='+', metavar='SITE', help='limit to these sites (default={})'.format(' '.join(default_sites)), default=default_sites)
    ap.add_argument('--bands', nargs='+', metavar='BANDNUM', help='limit to given band numbers (default={})'.format(' '.join(['{}'.format(b) for b in default_bands])), default=default_bands, type=int)
    ap.add_argument('--rate-unit', metavar='UNIT', help='rate in UNIT, one of {} (default=ps/s)'.format(rate_units), default='ps/s', choices=rate_units)
    ap.add_argument('--offset-unit', metavar='UNIT', help='offset in UNIT, one of {} (default=ns)'.format(offset_units), default='ns', choices=offset_units)
    ap.add_argument('--start-time', metavar='START', help='limit to data after START, format %%Yy%%jd%%Hh%%Mm%%Ss (default is last R2DBE configure time)', type=lambda s: datetime.datetime.strptime(s, '%Yy%jd%Hh%Mm%Ss'))
    ap.add_argument('--stop-time', metavar='STOP', help='limit to data before STOP, format %%Yy%%jd%%Hh%%Mm%%Ss (default is now)', type=lambda s: datetime.datetime.strptime(s, '%Yy%jd%Hh%Mm%Ss'))
    args = ap.parse_args()

    # gather arguments
    sites = args.sites
    bands = sorted(args.bands)
    rate_unit = args.rate_unit
    rate_div = dict(zip(rate_units,[10**(-x) for x in [0,3,6,9,12,15]]))[rate_unit]
    offset_unit = args.offset_unit
    offset_div = dict(zip(offset_units,[10**(-x) for x in [0,3,6,9,12,15]]))[offset_unit]
    start_time = args.start_time
    stop_time = args.stop_time

    r2dbes = [1,2,3,4]
    fpga_clk = 256e6
    t0,tnow = [(datetime.datetime.utcnow() - datetime.timedelta(days=d)).timestamp() for d in [60,0]]

    # process separately for each r2dbe for each site
    for site in sites:
        print(site)
        plt.figure(site)
        # count number of datasets per site
        count = 0
        for r2 in r2dbes:
            # get band information
            bandnum = 0
            for ch in [0,1]:
                sideband = 'r2dbe_{}_rxSideband{}'.format(r2,ch)
                bdcband = 'r2dbe_{}_bdcBand{}'.format(r2,ch)
                result = dbsession.fetch_timeseries([t0, tnow], [site], [sideband, bdcband])
                try: bandstr = '_'.join([result[site][x.format(r2,ch)][-1][-1] for x in [sideband, bdcband]])
                except (KeyError,IndexError) as e: continue
                try: bandnum = {'lsb_high':1,'lsb_low':2,'usb_low':3,'usb_high':4}[bandstr]
                except (KeyError) as e: continue
            if bandnum not in bands: continue

            # initialize plots
            ax1 = plt.subplot(2,len(bands),bands.index(bandnum)+1)
            if r2 == 1: plt.ylabel('ToA of GPS 1PPS after R2DBE internal 1PPS [{}]'.format(offset_unit))
            ax2 = plt.subplot(2,len(bands),bands.index(bandnum)+1+len(bands))
            if r2 == 1: plt.ylabel('Residual after fit [{}]'.format(offset_unit))

            # get upSince time first
            upsince = 'r2dbe_{}_upSince'.format(r2)
            result = dbsession.fetch_timeseries([t0, tnow], [site], [upsince])
            try: t1 = result[site][upsince][-1][-1]
            except (KeyError,IndexError) as e: continue

            # now get ppsOffset logged since upSince
            ppsoffset = 'r2dbe_{}_ppsOffset'.format(r2)
            tstart = t1 if start_time is None else start_time.timestamp()
            if tstart < t1:
                print('    (start time limited to last r2dbe{} configure time)'.format(r2))
                tstart = t1
            tstop = tnow if stop_time is None else stop_time.timestamp()
            if tstop > tnow:
                print('    (stop time limited to now)')
                tstop = tnow
            if tstart >= tstop:
                print('    (stop time before start time, reverting to defaults)')
                tstart,tstop = t1,tnow
            result = dbsession.fetch_timeseries([tstart, tstop], [site], [ppsoffset])
            try: t,r = [np.array(x[1:]) for x in zip(*result[site][ppsoffset])]
            except (KeyError,IndexError) as e: continue

            # increment number of datasets for this site
            count += 1

            # linear fit
            delta = r/fpga_clk
            T = [datetime.datetime.fromtimestamp(tt) for tt in t]
            linreg = linregress(t,delta)
            y = np.polyval([linreg.slope,linreg.intercept],t)
            res = y - delta

            # print results
            tstr = datetime.datetime.fromtimestamp(t[0]).strftime('%Yy%jd%Hh%Mm%Ss')
            if rate_div < 1:
	            print('  band {}: rate = {:+.3f} +/- {:.3f} {}, offset = {:+.3f} {} @ {} [{} pts]'.format(bandnum,linreg.slope/rate_div,linreg.stderr/rate_div,rate_unit,y[0]/offset_div,offset_unit,tstr,len(t)))
            else:
	            print('  band {}: rate = {:+.6e} +/- {:.6e} {}, offset = {:+.3f} {} @ {} [{} pts]'.format(bandnum,linreg.slope/rate_div,linreg.stderr/rate_div,rate_unit,y[0]/offset_div,offset_unit,tstr,len(t)))

            # plot data & fit
            plt.sca(ax1)
            plt.plot(T,delta/offset_div,'o',label='data')
            plt.plot(T,y/offset_div,'--',label='linear fit')
            if rate_div < 1:
                plt.title('band {}: rate = {:+.3f} {}'.format(bandnum, linreg.slope/rate_div, rate_unit))
            else:
                plt.title('band {}: rate = {:+.6e} {}'.format(bandnum, linreg.slope/rate_div, rate_unit))
            plt.xlabel('Time')
            plt.xticks(rotation=40)
            #plt.xticks(ticks=[T[0],T[-1]])
            plt.grid()

            # plot residual
            plt.sca(ax2)
            plt.plot(T,res/offset_div)
            plt.xlabel('Time')
            plt.xticks(rotation=40)
            #plt.xticks(ticks=[T[0],T[-1]])
            plt.grid()

        # if no data for site, close the plot
        if count == 0:
            plt.close()
            print('    (no data for site)')

    plt.ioff()
    plt.show()
