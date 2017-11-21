iptables:
  service:
    enabled: true
    chain:
      INPUT:
        rules:
          - position: 1
            table: filter
            protocol: tcp
            destination_port: 8088
            source_network: 127.0.0.1
            jump: ACCEPT
            comment: Blah
