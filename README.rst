=====================
iptables salt formula
=====================

Iptables is used to set up, maintain, and inspect the tables of IPv4 packet
filter rules in the Linux kernel. Several different tables may be defined.
Each table contains a number of built-in chains and may also contain
user-defined chains.  Each chain is a list of rules which can match a set of
packets. Each rule specifies what to do with a packet that matches. This is
called a `target`, which may be a jump to a user-defined chain in the same
table.

This version of a formula guarantees that manually added rules or rules which
has been added in runtime would be removed.

In order to ensure architecture, proper epoch value should be specified.
Refer to an example.

Sample pillars
==============

.. code-block:: yaml

    parameters:
      iptables:
        schema:
          epoch: 1
        service:
          v4:
            enabled: true
            persistent_config: /etc/iptables.v4
            modules:
            - nf_conntrack_ftp
            - nf_conntrack_pptp
          v6:
            enabled: false
            persistent_config: /etc/iptables.v6
            modules:
            - nf_conntrack_ipv6
        defaults:
          v4:
            metadata_rules: false
            policy: ACCEPT
            ruleset:
              action: ACCEPT
              params: ""
              rule: ""
          v6:
            metadata_rules: false
            policy: DROP
            ruleset:
              action: ACCEPT
              params: ""
              rule: ""
        tables:
          v4:
            filter:
              chains:
                INPUT:
                  ruleset:
                    5:
                      action: log_drop
                    10:
                      rule: -s 192.168.0.0/24 -p tcp
                log_drop:
                  policy: DROP
                  ruleset:
                    10:
                      action: LOG
                      comment: "Log my packets"
            nat:
              chains:
                OUTPUT:
                PREROUTING:
                POSTROUTING:
                  policy: ACCEPT
                  ruleset:
                    10:
                      rule: -s 192.168.0.0/24 -p tcp -o lo
                      action: SNAT
                      params: --to-source=127.0.0.1


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


Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

    https://github.com/salt-formulas/salt-formula-iptables

