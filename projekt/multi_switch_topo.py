#!/usr/bin/python

# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.link import TCLink

from p4_mininet import P4Switch, P4Host

from subprocess import call

import argparse
from time import sleep
import os


parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--jsons', help='Paths to JSON config files',
                    type=str, nargs='*', action="store", required=True)
parser.add_argument('--topo', help='Path to scenario topology file',
                    type=str, action="store", default="topo.txt")
parser.add_argument('--hmacs', help='Host MAC addresses',
                    type=str, nargs='*', action="store", default=[])
parser.add_argument('--thrift-port', help='Thrift server port for table updates',
                    type=int, action="store", default=9091)



args = parser.parse_args()

class MyTopo(Topo):
    def __init__(self, sw_path, json_paths, thrift_port, nb_hosts, nb_switches, links, **opts):
        # Initialize topology and default options
        Topo.__init__(self, **opts)

        jpath = json_paths[0]

        for i in xrange(nb_switches):
            if len(json_paths) > i:
              jpath = json_paths[i]
            switch = self.addSwitch('s%d' % (i + 1),
                                    sw_path = sw_path,
                                    json_path = jpath,
                                    thrift_port = thrift_port + i,
                                    device_id = i)

        for h in xrange(nb_hosts):
            mac = '00:04:00:00:00:%02x' % (h+1)
            if(len(args.hmacs) > h):
              mac = args.hmacs[h]
            host = self.addHost('h%d' % (h + 1),
                                ip = '10.0.%d.10/24' % (h+1),
                                mac = mac)

        for a, b in links:
            self.addLink(a, b)

#--------------Budowa topologi z topo.txt

def read_topo():
    nb_hosts = 0
    nb_switches = 0
    links = []
    with open(args.topo, "r") as f:
        line = f.readline()[:-1]
        w, nb_switches = line.split()
        assert(w == "switches")
        line = f.readline()[:-1]
        w, nb_hosts = line.split()
        assert(w == "hosts")
        for line in f:
            if not f: break
            a, b = line.split()
            links.append( (a, b) )
    return int(nb_hosts), int(nb_switches), links

#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

def main():
    nb_hosts, nb_switches, links = read_topo()
    topo = MyTopo(args.behavioral_exe,
                  args.jsons,
		  args.thrift_port,
                  nb_hosts, nb_switches, links)

    net = Mininet(topo = topo,
                  host = P4Host,
                  switch = P4Switch,
                  controller = None )
    net.start()

    sw_mac = ["00:04:00:00:00:%02x" % (n+1) for n in xrange(nb_hosts)]
    sw_addr = ["10.0.%d.1" % (n+1) for n in xrange(nb_hosts)]

    for n in xrange(nb_hosts):
        h = net.get('h%d' % (n + 1))
	h.setARP(sw_addr[n], sw_mac[n])
	h.setDefaultRoute("dev eth0 via %s" % sw_addr[n])

    for n in xrange(nb_hosts):
        h = net.get('h%d' % (n + 1))
        h.describe()

    sleep(1)


#------- konfiguracja switchy
    info( "\n\n*** Configuring switches\n" )
    conf = call("./switch_config.sh")
    info( "\n" )

    print "\n\nReady !"

    CLI( net )
    net.stop()

if __name__ == '__main__':
    setLogLevel( 'info' )
    main()

