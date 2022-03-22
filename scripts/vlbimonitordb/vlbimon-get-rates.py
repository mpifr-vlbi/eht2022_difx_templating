#!/usr/bin/python3
# -*- coding: utf-8 -*-
'''
Queries the EHT VLBI monitoring database and lists the H-maser rates, if logged.

Usage: vlbimon-get-rates.py [<track>]

With no arguments, all entries in the database for the
currently known EHT VLBI tracks are printed out.

When a specific track is given, such as e21a17, the
maser rates are shown in VEX $CLOCK section format.
'''
from __future__ import print_function
import datetime
import sys

from dbSession import dbSession
from ehtTrackList import ehtTrackList

__author__    = 'Jan Wagner'
__license__   = "LGPL"
__version__   = "1.0.0"
__status__    = "Development"

def list_rates(session, timebracket, trackname, sites, doVex=False):

	# fields = ['maser_driftRate','maser_timeToGpsTick']
	fields = ['maser_driftRate']
	ss = session.fetch_timeseries(timebracket, sites, fields)

	count = 0
	for sitename, val in ss.items():
		states, keyname, uxtime = session.make_state_series(val)
		for (t,values) in zip(uxtime,states):
			# timeToGps, driftrate = values
			tpretty = datetime.datetime.utcfromtimestamp(int(t))
			if doVex:
				pass
				#if count==0:
				#else:
			print('Site %s Track %s : time bracket %s : %s %s' % (sitename,trackname,str(timebracket),str(tpretty),str(values)))
			count += 1


def main():

	dbsession = dbSession()
	ehtTracks = ehtTrackList()
	sites = ['ALMA','NOEMA','SMA','SMTO','JCMT','APEX','GLT','SPT','LMT','PICO','KP']

	tracks = ehtTracks.listTracks()
	doVex = False

	if len(sys.argv) >= 2:

		usertracks = []
		for track in sys.argv[1:]:
			if track not in tracks:
				print('Error: Requested track %s unknown by Class ehtTrackList (currently known: %s). ' % (track,' '.join(tracks)))
				sys.exit(1)
			usertracks += [track]
		tracks = usertracks
		doVex = True

	for track in tracks:
		print(track)
		timebracket = ehtTracks.getTrackTimerange(track)
		list_rates(dbsession, timebracket, track, sites, doVex)

if __name__ == '__main__':
    main()

# vim: foldmethod=indent
