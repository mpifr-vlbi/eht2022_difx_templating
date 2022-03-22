#!/usr/bin/python3
from __future__ import print_function
import requests
import datetime
import sys

from dbSession import dbSession
from ehtTrackList import ehtTrackList


def make_groupTimelines(states, ks, xs, ix_dirty):
    if len(ix_dirty) > 0: ix_dirty_ = ix_dirty + [len(xs)-1]
    index = {}
    indexc = {}
    groupRecorder = {}
    for ir in range(1, 5):
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}ModuleIDs'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: continue
            groupRecorder[k] = ir
            #-- if Chainlabel doesn't exist, we also drop ModuleIDs
            kc = 'recorder_{:}_group{:}Chainlabel'.format(ir, ig)
            try:
                indexc[k] = ks.index(kc)
            except ValueError:
                indexc[k] = None

    groupTracks = {}
    for k, i in index.items():
        prev = None
        for iix, ix in enumerate(ix_dirty):
            modIDs = states[ix][i]
            if modIDs == None: continue

            try:
                chainlabel = states[ix][indexc[k]]
            except TypeError: chainlabel = 'undefined'
            if chainlabel == '': chainlabel = 'undefined'

            #-- continue previous track if no changes
            if modIDs == prev  and  groupTracks[modIDs][-1]['chainlabel'] == chainlabel:
                lastTrack = groupTracks[modIDs][-1]
                lastTrack['time'][1] = xs[ix_dirty_[iix+1]]
                continue
            prev = modIDs

            if not modIDs in groupTracks: groupTracks[modIDs] = []

            nextTrack = {
                'recorder': groupRecorder[k],
                'chainlabel': chainlabel,
                'time': [xs[ix], xs[ix_dirty_[iix+1]]],
                }
            groupTracks[modIDs].append(nextTrack)

    return groupTracks


def make_modules_timeline(states, ks):
    '''Create timeline of module state changes'''
    index = {}
    #-- loop recorders
    for ir in range(1, 5):
        #-- loop groups
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}Chainlabel'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: continue
    for ir in range(1, 5):
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}ModuleIDs'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: continue

    #-- find x coordinates where state changes
    state = len(index) * [None]
    ix_dirty = []
    for ix, st in enumerate(states):
        dirty = False
        for j, (k, i) in enumerate(index.items()):
            if state[j] == st[i]: continue
            #print(k, i, j, state[j], st[i])
            state[j] = st[i]
            dirty = True
        if dirty: ix_dirty.append(ix)

    return ix_dirty


def make_scans_timeline(states, ks):
    '''Create timeline of module state changes'''
    index = {}
    #-- loop recorders
    for ir in range(1, 5):
        #-- loop groups
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}Chainlabel'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: pass
            k = 'recorder_{:}_group{:}Spooling'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: pass
    for ir in range(1, 5):
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}ModuleIDs'.format(ir, ig)
            try:
                index[k] = ks.index(k)
            except ValueError: pass

    #-- find x coordinates where state changes
    state = len(index) * [None]
    ix_dirty = []
    for ix, st in enumerate(states):
        dirty = False
        for j, (k, i) in enumerate(index.items()):
            if state[j] == st[i]: continue
            #print(k, i, j, state[j], st[i])
            state[j] = st[i]
            dirty = True
        if dirty: ix_dirty.append(ix)

    return ix_dirty


def extend_with_groupModuleIDs(states_in, ks_in):
    '''Print table for one site'''
    index = {}
    #-- loop recorders
    for ir in range(1, 5):
        #-- loop groups
        for ig in 'abcd':
            k = 'recorder_{:}_group{:}Modules'.format(ir, ig)
            try:
                index[k] = ks_in.index(k)
            except ValueError: pass
        for im in range(1, 5):
            k = 'recorder_{:}_module{:}ID'.format(ir, im)
            try:
                index[k] = ks_in.index(k)
            except ValueError: pass

    ks = list(ks_in)
    for ir in range(1, 5):
        for ig in 'abcd':
            #k = 'recorder_{:}_group{:}Modules'.format(ir, ig)
            #if not k in index: continue
            k = 'recorder_{:}_group{:}ModuleIDs'.format(ir, ig)
            ks.append(k)

    states = []
    for st in states_in:
        state = list(st)
        #-- loop recorders
        for ir in range(1, 5):
            #-- loop groups
            for ig in 'abcd':
                k = 'recorder_{:}_group{:}Modules'.format(ir, ig)
                try:
                    i = index[k]
                except KeyError:
                    state.append(None)
                    continue
                grpMods = st[i]

                if grpMods == '' or grpMods == None:
                    state.append(None)
                    continue

                groupModuleIDs = []
                for m in grpMods.split(','):
                    try:
                        k = 'recorder_{:}_module{:}ID'.format(ir, m)
                        modID = st[index[k]]
                    except KeyError: 
                        modID = 'undefined'  #-- actually better 'incorrect'
                    if modID is None: modID = 'undefined'
                    groupModuleIDs.append(modID)
                state.append(','.join(groupModuleIDs))
        states.append(state)
    return states, ks


def list_modules(session, timebracket, trackname, sites):

    fields = []
    for ir in range(1, 5):
        modID = ['recorder_{:}_status'.format(ir)]
        #-- loop modules
        for im in [1, 2, 3, 4]:
            modID = ['recorder_{:}_module{:}ID'.format(ir, im)]
            fields += modID
    
        #-- loop groups
        for ig in 'abcd':
            fields += ['recorder_{:}_group{:}Modules'.format(ir, ig)]
            fields += ['recorder_{:}_group{:}Chainlabel'.format(ir, ig)]
            fields += ['recorder_{:}_group{:}Spooling'.format(ir, ig)]

    ss = session.fetch_timeseries(timebracket, sites, fields)

    #-- create time series
    tss = {}
    for sitename, val in ss.items():
        states, ks, xs = session.make_state_series(val)
        states, ks = extend_with_groupModuleIDs(states, ks)
        ix_dirty = make_modules_timeline(states, ks)
        groupTracks = make_groupTimelines(states, ks, xs, ix_dirty)
        print()
        print('------------')
        print(sitename, '(%d)'%len(groupTracks))
        print('------------')
        for k, v in groupTracks.items():
            print(k)
            for o in v:
                td = [datetime.datetime.utcfromtimestamp(t).isoformat() for t in o['time']]
                print('\t', '%-11s' % o['chainlabel'], ' [ {:} -- {:} ] '.format(*td), 'recorder%d'%o['recorder'])



def main():

	dbsession = dbSession()
	ehtTracks = ehtTrackList()
	sites = ['ALMA','NOEMA','SMA','SMTO','JCMT','APEX','GLT','SPT','LMT','PICO','KP']

	tracks = ehtTracks.listTracks()

	if len(sys.argv) >= 2:
		usertracks = []
		for track in sys.argv[1:]:
			if track not in tracks:
				print('Error: Requested track %s unknown by Class ehtTrackList (currently known: %s). ' % (track,' '.join(tracks)))
				sys.exit(1)
			usertracks += [track]
		tracks = usertracks
	else:
		tracks = ['e22xxx']

	for track in tracks:
		print(track)
		timebracket = ehtTracks.getTrackTimerange(track)
		list_modules(dbsession, timebracket, track, sites)


if __name__ == '__main__':
    main()

# vim: foldmethod=indent
