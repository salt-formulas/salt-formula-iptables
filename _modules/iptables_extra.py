# -*- coding: utf-8 -*-
from os import chmod,remove
from time import time
from subprocess import Popen,PIPE

def get_tables(family="ipv4"):

    ''' List iptables tables

    :param family: iptables ip family version. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables-save'
    elif family == "ipv6":
        cmd = 'ip6tables-save'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    tables = []
    try:
        tables_list = Popen(cmd, shell=True, stdout=PIPE)
        while True:
            line = tables_list.stdout.readline().decode()
            if line != '':
                if line[0] == "*":
                    tables.append(line.rstrip()[1:])
            else:
                break
    except:
        return "Error getting list of tables"

    return tables

def get_chains(family="ipv4", table="filter"):

    ''' List iptables chains

    :param family: iptables ip family version. type: str
    :param table: Lookup chains for this table. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables-save'
    elif family == "ipv6":
        cmd = 'ip6tables-save'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    cmd += ' -t ' + table

    chains = []
    try:
        chains_list = Popen(cmd, shell=True, stdout=PIPE)
        while True:
            line = chains_list.stdout.readline()
            if line != '':
                if line[0] == ":":
                    chains.append(line.rstrip()[1:].split(' ')[0])
            else:
                break
    except:
        return "Error getting list of chains"

    return chains

def get_structure(family="ipv4"):

    ''' Get structure of all chains in all tables

    :param family: iptables ip family version. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables-save'
    elif family == "ipv6":
        cmd = 'ip6tables-save'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    tables = []
    tables_list = Popen(cmd, shell=True, stdout=PIPE)
    while True:
        line = tables_list.stdout.readline()
        if line != '':
            line = line.rstrip().lstrip()
            if line[0] == "*":
                elem = {}
                table_name = line[1:].split(' ')[0]
                elem[table_name] = []
            if line[0] == ":":
                elem[table_name].append(line[1:].split(' ')[0])
            if line == "COMMIT":
                tables.append(elem)
        else:
            break

    return tables

def run_script(script):

    ''' Execute local script

    :param script: script to be executed, storad localy: str

    '''

    chmod(script, 0o700)
    process = Popen([script],stdout=PIPE,stderr=PIPE)
    process.wait()
    code = process.returncode
    remove(script)
    return code


def flush_all(family="ipv4"):

    ''' Flush all chains in all tables

    :param family: iptables ip family version. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables'
        rmmod = 'iptable_'
    elif family == "ipv6":
        cmd = 'ip6tables'
        rmmod = 'ip6table_'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    tables = get_structure(family)

    f_name = '/tmp/' + cmd + '-flush-' + str(time()).split('.')[0] + '.sh'

    with open(f_name, 'w') as f:
        f.write('#!/bin/sh\n')
        for table in tables:
             for var in enumerate(table):
                 t_name = var[1]
                 for chain in table[t_name]:
                     f.write(cmd + ' -t ' + t_name + " -F " + chain + '\n')
                     if chain not in ['INPUT','FORWARD','OUTPUT','PREROUTING','POSTROUTING']:
                         f.write(cmd + ' -t ' + t_name + " -X " + chain + '\n')
                 f.write('rmmod ' + rmmod + t_name + '\n')

    return run_script(f_name)

def set_policy_all(family="ipv4", policy="ACCEPT"):

    ''' Set policy for all chains in all tables

    :param family: iptables ip family version. type: str
    :param policy: iptables chain policy. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables'
    elif family == "ipv6":
        cmd = 'ip6tables'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    tables = get_structure(family)

    f_name = '/tmp/' + cmd + '-policy-' + str(time()).split('.')[0] + '.sh'

    with open(f_name, 'w') as f:
        f.write('#!/bin/sh\n')
        for table in tables:
             for var in enumerate(table):
                 t_name = var[1]
                 for chain in table[t_name]:
                     f.write(cmd + ' -t ' + t_name + " -P " + chain + ' ' + policy + '\n')

    return run_script(f_name)

def remove_stale_tables(config_file, family="ipv4"):

    ''' Remove tables which are not in config file
        to prevet flushing all the tables

    :param family: iptables ip family version. type: str
    :param config_file: iptables rules persistent config file. type: str

    '''

    if family == "ipv4":
        cmd = 'iptables'
        rmmod = 'iptable_'
    elif family == "ipv6":
        cmd = 'ip6tables'
        rmmod = 'ip6table_'
    else:
        return "Invalid ip family specified. Use either ipv4 or ipv6"

    runtime_tables = get_tables(family)

    config_tables = []
    for line in open(config_file, 'r'):
        if line != '':
            if line[0] == "*":
                config_tables.append(line.rstrip()[1:])

    runtime_tables.sort()
    config_tables.sort()
    diff = list(set(runtime_tables) - set(config_tables))

    if diff != []:
        tables = get_structure(family)
        f_name = '/tmp/' + cmd + '-flush-' + str(time()).split('.')[0] + '.sh'
        with open(f_name, 'w') as f:
            f.write('#!/bin/sh\n')
            for table in tables:
                 for var in enumerate(table):
                     t_name = var[1]
                     if t_name in diff:
                         for chain in table[t_name]:
                             f.write(cmd + ' -t ' + t_name + " -F " + chain + '\n')
                             if chain not in ['INPUT','FORWARD','OUTPUT','PREROUTING','POSTROUTING']:
                                 f.write(cmd + ' -t ' + t_name + " -X " + chain + '\n')
                         f.write('rmmod ' + rmmod + t_name + '\n')

        return run_script(f_name)
    else:
        return
