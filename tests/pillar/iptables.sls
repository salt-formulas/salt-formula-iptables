iptables:
  schema:
    epoch: 1
  service:
    v4:
      enabled: true
      modules:
      - nf_conntrack_ftp
      - nf_conntrack_pptp
    v6:
      enabled: false
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
                rule: ""
                action: LOG
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
                config: v4
    v6:
      filter:
        chains:
          INPUT:
            ruleset:
              5:
                action: log_drop
              10:
                rule: -s 200A:0:200C::1/64 -p tcp
          log_drop:
            policy: DROP
            ruleset:
              10:
                rule: ""
                action: LOG
