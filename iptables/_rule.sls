iptables_{{ chain_name }}_{{ rule_name }}:
  {%- if rule.position is defined %}
  iptables.insert:
  - position: {{ rule.position }}
  {%- else %}
  iptables.append:
  {%- if loop.index != 1 %}
  - require:
    - iptables: iptables_{{ chain_name }}_{% if service_name is defined %}{{ service_name }}_{% endif %}{{ loop.index - 1 }}
  {%- endif %}
  {%- endif %}
  - table: {{ rule.get('table', 'filter') }}
  - chain: {{ chain_name }}
  {%- if rule.family is defined %}
  - family: {{ rule.family }}
  {%- endif %}
  {%- if rule.jump is defined %}
  - jump: {{ rule.jump }}
  {%- endif %}
  {%- if rule.match is defined %}
  - match: {{ rule.match }}
  {%- endif %}
  {%- if rule.connection_state is defined %}
  - connstate: {{ rule.connection_state }}
  {%- endif %}
  {%- if rule.protocol is defined %}
  - proto: {{ rule.protocol }}
  {%- endif %}
  {%- if rule.destination_port is defined %}
  - dport: {{ rule.destination_port }}
  {%- endif %}
  {%- if rule.source_port is defined %}
  - sport: {{ rule.source_port }}
  {%- endif %}
  {%- if rule.in_interface is defined %}
  - in-interface: {{ rule.in_interface }}
  {%- endif %}
  {%- if rule.out_interface is defined %}
  - out-interface: {{ rule.out_interface }}
  {%- endif %}
  {%- if rule.to_destination is defined %}
  - to-destination: {{ rule.to_destination }}
  {%- endif %}
  {%- if rule.to_port is defined %}
  - to-port: {{ rule.to_port }}
  {%- endif %}
  {%- if rule.to_source is defined %}
  - to-source: {{ rule.to_source }}
  {%- endif %}
  {%-  if rule.source_network is defined %}
  - source: {{ rule.source_network }}
  {%- endif %}
  {%-  if rule.destination_network is defined %}
  - destination: {{ rule.destination_network }}
  {%- endif %}
  {%- if chain.policy is defined %}
  - require_in:
    - iptables: iptables_{{ chain_name }}_policy
  {%- endif %}
  {%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}
  - require:
    - iptables: iptables_{{ chain_name }}{% if rule.family is defined %}_{{ rule.family }}{% endif %}
  {%- endif %}
  - save: True
