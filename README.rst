
================
iptables formula
================

iptables is a user-space application program that allows a system administrator to configure the tables provided by the Linux kernel firewall and the chains and rules it stores.

Sample pillars
==============

Simple INPUT chain httpd ACCEPT rule on position 1

.. code-block:: yaml

    iptables:
      service:
        enabled: false
          chain:
            INPUT:
              enabled: true
              rule:
                httpd:
                  position: 1
                  table: filter
                  jump: ACCEPT
                  family: ipv6
                  match: state
                  connection_state: NEW
                  protocol: tcp
                  source_port: 1025:65535
                  destination_port: 80

Read more
=========

* http://docs.saltstack.com/en/latest/ref/states/all/salt.states.iptables.html
* https://help.ubuntu.com/community/IptablesHowTo
* http://wiki.centos.org/HowTos/Network/IPTables

.. code-block:: yaml

  chain:
    PREROUTING:
      enabled: true
      rule:
        dnat_ssh_185:
          table: filter
          jump: DNAT
          match: tcp
          protocol: tcp
          destination_network: 185.22.97.132/32
          destination_port: 20022
          to_destination:
            host: 10.0.110.38
            port: 22
          comment: Premapovani ssh zvenku na standardni port
        dnat_ssh_10:
          table: filter
          jump: DNAT
          match: tcp
          protocol: tcp
          destination_network: 10.0.110.38/32
          destination_port: 20022
          to_destination:
            host: 10.0.110.38
            port: 22
          comment: Premapovani ssh 20022-22
        redirect_vpn_185:
          table: filter
          jump: REDIRECT
          match: udp
          protocol: udp
          destination_network: 185.22.97.132/32
          destination_port: 3690
          to_port:
            port: 1194
          comment: Presmerovani VPN portu 3690 > 1194
    POSTROUTING:
      enabled: true
      rule:
        snat_vpn_185:
          table: filter
          jump: SNAT
          match: udp
          protocol: udp
          source_network: 10.8.0.0/24
          out_interface: eth1
          to_source:
            host: 185.22.97.132
          comment: NAT pro klienty administratorske VPNky
    INPUT:
      enabled: true
      rule:
        allow_conn_established:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: RELATED,ESTABLISHED
          comment: Vsechen provoz souvisejici s povolenymi pravidly pustit
        allow_proto_icmp:
          table: filter
          jump: ACCEPT
          protocol: icmp
          comment: ICMP nechceme filtrovat
        allow_iface_lo:
          table: filter
          jump: ACCEPT
          in_interface: lo
          comment: Lokalni smycka muze vsechno
        allow_ssh_10.0.110.38:
          table: filter
          jump: ACCEPT
          match: tcp
          protocol: tcp
          destination_network: 10.0.110.38/32
          destination_port: 22
          comment: SSH z lokalni site
        allow_ssh_10.8.0.1:
          table: filter
          jump: ACCEPT
          match: tcp
          protocol: tcp
          destination_network: 10.8.0.1/32
          destination_port: 22
          comment: SSH z VPN site
        allow_ssh_private_10:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: NEW
          source_network: 10.0.0.0/8
          destination_network: 185.22.97.132/32
          destination_port: 22
          comment: ssh z vnitrni site 10.0.0.0/8 povolit na obvykly protokol
        allow_ssh_private_192:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: NEW
          source_network: 192.0.0.0/8
          destination_network: 185.22.97.132/32
          destination_port: 22
          comment: ssh z vnitrni site 192.0.0.0/8 povolit na obvykly protokol
        allow_ssh_private_172:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: NEW
          source_network: 172.16.162.0/24
          destination_network: 185.22.97.132/32
          destination_port: 22
          comment: ssh z vnitrni site 10.0.0.0/8 povolit na obvykly protokol
        allow_ssh_private_185:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: NEW
          source_network: 185.22.97.0/24
          destination_network: 185.22.97.132/32
          destination_port: 22
          comment: ssh z vnitrni site 192.0.0.0/8 povolit na obvykly protokol
        deny_ssh_public:
          table: filter
          jump: DROP
          match: tpc
          protocol: tcp
          destination_network: 185.22.97.132/32
          destination_port: 22
          comment: ssh z vnejsi site na obvykly port ZAKAZAT, budeme ho presmerovavat
        allow_ssh_public_redirect:
          table: filter
          jump: ACCEPT
          match: tpc
          protocol: tcp
          destination_port: 22022
          comment: nahradni ssh port bude presmerovan na 22 pokud se prijde z vnejsi site
        allow_zabbix_server:
          table: filter
          jump: ACCEPT
          match: tpc
          protocol: tcp
          source_network: 10.0.110.36/32
          destination_port: 10050
          comment: zabbix monitoring
        allow_tsmc_web_10:
          table: filter
          jump: ACCEPT
          match: tpc
          protocol: tcp
          source_network: 10.0.0.0/8
          destination_port: 1581
          comment: tsm client web gui
        allow_tsmc_37010_10:
          table: filter
          jump: ACCEPT
          match: state
          protocol: tcp
          source_network: 10.0.0.0/8
          destination_port: 37010
          comment: tsmc web
        allow_tsmc_39876_10:
          table: filter
          jump: ACCEPT
          match: state
          protocol: tcp
          source_network: 10.0.0.0/8
          destination_port: 39876
          comment: tsmc web
        allow_tsm_web_172:
          table: filter
          jump: ACCEPT
          match: tpc
          protocol: tcp
          source_network: 172.16.162.0/24
          destination_port: 1581
          comment: tsm client web gui
        allow_tsmc_37010_172:
          table: filter
          jump: ACCEPT
          match: state
          protocol: tcp
          source_network: 172.16.162.0/24
          destination_port: 37010
          comment: tsmc web
        allow_tsmc_39876_172:
          table: filter
          jump: ACCEPT
          match: state
          protocol: tcp
          source_network: 172.16.162.0/24
          destination_port: 39876
          comment: tsmc web
        allow_vpn_public:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: NEW
          destination_port: 1194
          comment: Povolime VPN odkudkoli
        reject_rest:
          table: filter
          jump: REJECT
          comment: Zdvorile odmitame ostatni komunikaci; --reject-with icmp-host-prohibited neni
    FORWARD:
      enabled: true
      rule:
        allow_conn_established:
          table: filter
          jump: ACCEPT
          match: state
          connection_state: RELATED,ESTABLISHED
          comment: Vsechen provoz souvisejici s povolenymi pravidly pustit
        snat_vpn_185:
          table: filter
          jump: SNAT
          match: udp
          protocol: udp
          source_network: 10.8.0.0/24
          out_interface: eth1
          to_source:
            host: 185.22.97.132
          comment: NAT pro klienty administratorske VPNky
        accept_net_10.0.110.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.0.110.0/24
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace management
        accept_net_10.10.0.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.10.0.0/16
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace management
        accept_net_10.0.101.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.0.101.0/24
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace VLAN1501
        accept_net_10.0.102.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.0.102.0/24
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace VLAN1502
        accept_net_10.0.103.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.0.103.0/24
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace VLAN1503
        accept_net_10.0.106.0_vpn:
          table: filter
          jump: ACCEPT
          source_network: 10.0.106.0/24
          destionation_network: 10.8.0.0/24
          comment: vnitrni komunikace VLAN1506
        accept_net_10.0.110.0:
          table: filter
          jump: ACCEPT
          source_network: 10.0.110.0/24
          comment: Vse ze site 10.0.110.0
        accept_net_10.8.0.0:
          table: filter
          jump: ACCEPT
          source_network: 10.8.0.0/24
          comment: Z teto VPN se smi skoro vsechno
