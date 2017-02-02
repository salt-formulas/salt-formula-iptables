
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

IPv6 is supported as well
		
.. code-block:: yaml

    parameters:
      iptables:
        service:
          chain:
            INPUT:
              rules:
                - protocol: tcp
		  family: ipv6
                  destination_port: 22
                  source_network: 2001:DB8::/32
                  jump: ACCEPT
		  
Read more
=========

* http://docs.saltstack.com/en/latest/ref/states/all/salt.states.iptables.html
* https://help.ubuntu.com/community/IptablesHowTo
* http://wiki.centos.org/HowTos/Network/IPTables

Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use Github issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-iptables/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

You can also join salt-formulas-users team and subscribe to mailing list:

    https://launchpad.net/~salt-formulas-users

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-iptables

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net
