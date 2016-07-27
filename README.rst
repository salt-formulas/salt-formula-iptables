
================
iptables formula
================

Iptables is used to set up, maintain, and inspect the tables of IPv4 packet
filter rules in the Linux kernel. Several different tables may be defined.
Each table contains a number of built-in chains and may also contain
user-defined chains.  Each chain is a list of rules which can match a set of
packets. Each rule specifies what to do with a packet that matches. This is
called a `target`, which may be a jump to a user-defined chain in the same
table.

Sample pillars
==============

Most common rules - allow traffic on localhost, accept related,established and
ping

.. code-block:: yaml

    parametetrs:
      iptables:
        service:
          chain:
            INPUT:
              rules:
                - in_interface: lo
                  jump: ACCEPT
                - connection_state: RELATED,ESTABLISHED
                  match: state
                  jump: ACCEPT
                - protocol: icmp
                  jump: ACCEPT

Accept connections on port 22

.. code-block:: yaml

    parametetrs:
      iptables:
        service:
          chain:
            INPUT:
              rules:
                - destination_port: 22
                  protocol: tcp
                  jump: ACCEPT

Set drop policy on INPUT chain:

.. code-block:: yaml

    parametetrs:
      iptables:
        service:
          chain:
            INPUT:
              policy: DROP

Redirect privileged port 443 to 8081

.. code-block:: yaml

    parameters:
      iptables:
        service:
          chain:
            PREROUTING:
              filter: nat
              destination_port: 443
              to_port: 8081
              protocol: tcp
              jump: REDIRECT

Allow access from local network

.. code-block:: yaml

    parameters:
      iptables:
        service:
          chain:
            INPUT:
              rules:
                - protocol: tcp
                  destination_port: 22
                  source_network: 192.168.1.0/24
                  jump: ACCEPT

Read more
=========

* http://docs.saltstack.com/en/latest/ref/states/all/salt.states.iptables.html
* https://help.ubuntu.com/community/IptablesHowTo
* http://wiki.centos.org/HowTos/Network/IPTables
