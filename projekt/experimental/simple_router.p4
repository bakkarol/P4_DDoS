/* Copyright 2013-present Barefoot Networks, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//----------------------------------------------------------------------
//----------------------------------------------------------------------

#include "includes/headers.p4"
#include "includes/parser.p4"

//----------------------------------------------------------------------
//----------------------------------------------------------------------

action _drop() {
    drop();
}

action _nop() {
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

header_type routing_metadata_t {
    fields {
        ipv4_srcAddr : 32;
        ipv4_dstAddr : 32;
	latest_dstPort : 16;
        nhop_ipv4 : 32;

    }
}

metadata routing_metadata_t routing_metadata;

//------------------------------------------------------------------------
//------------------------------------------------------------------------

action set_nhop(nhop_ipv4, port) {
    modify_field(routing_metadata.nhop_ipv4, nhop_ipv4);
    modify_field(standard_metadata.egress_spec, port);
    modify_field(ipv4.ttl, ipv4.ttl - 1);
}

table ipv4_lpm {
    reads {
        ipv4.dstAddr : lpm;
    }
    actions {
        set_nhop;
        _drop;
    }
    size: 1024;
}

//------------------------------------------------------------------------

action set_dmac(dmac) {
    modify_field(ethernet.dstAddr, dmac);
}

table forward {
    reads {
        routing_metadata.nhop_ipv4 : exact;
    }
    actions {
        set_dmac;
        _drop;
    }
    size: 512;
}

//------------------------------------------------------------------------

action rewrite_mac(smac) {
    modify_field(ethernet.srcAddr, smac);
}

table send_frame {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        rewrite_mac;
        _drop;
    }
    size: 256;
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

table ingress_drop {
    actions { _nop; _drop; }
}

table egress_drop {
    actions { _nop; _drop; }
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------

header_type blackhole_metadata_t {
	fields {
	     flag: 1;
	}
}

metadata blackhole_metadata_t blackhole_metadata;

action blackholing_action() {
	modify_field(blackhole_metadata.flag, 1);
}

table blackhole_list {
	reads {
		routing_metadata.latest_dstPort: exact;
	}

	actions { _drop; blackholing_action; }
}

control blackhole_list_check {

	apply(blackhole_list);
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------
//------------------------------------------------------------------------

control ingress {

    blackhole_list_check();
    if(blackhole_metadata.flag == 1) {
	apply(ingress_drop);
    } else if (valid(ipv4) and ipv4.ttl > 0) {
        apply(ipv4_lpm);
        apply(forward);

    }
}

//------------------------------------------------------------------------

control egress {

     apply(send_frame);

}

//------------------------------------------------------------------------
//------------------------------------------------------------------------
