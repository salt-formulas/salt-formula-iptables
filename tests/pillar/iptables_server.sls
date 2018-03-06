iptables:
  service:
    enabled: true
    chain:
      INPUT:
        policy:
        - table: nat
          policy: ACCEPT
        rules:
          - position: 1
            table: filter
            protocol: tcp
            destination_port: 8088
            source_network: 127.0.0.1
            jump: ACCEPT
            comment: Blah
      OUTPUT:
        policy: ACCEPT
      FORWARD:
        policy:
        - table: mangle
          policy: DROP
      POSTROUTING:
        rules:
        - jump: MASQUERADE
          protocol: icmp
          out_interface: ens3
          table: nat
