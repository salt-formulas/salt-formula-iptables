{% from "iptables/map.jinja" import service with context %}

{%- if pillar.iptables.service.enabled %}

iptables_packages:
  pkg.installed:
  - names: {{ service.pkgs }}

iptables_services:
  service.dead:
  - enable: true
  - name: {{ service.service }}
  - sig: test -e /etc/iptables/rules.v4
  - require:
    - pkg: iptables_packages

{%- for chain_name, chain in service.get('chain', {}).iteritems() %}
 
{%- for rule_name, rule in chain.get('rule', {}).iteritems() %}

iptables_{{ chain_name }}_{{ rule_name }}:
  iptables.insert:
  {%- if rule.position is defined %}
  - position: {{ rule.position }}
  {%- endif %}
  {%- if rule.table is defined %}
  - table: {{ rule.table }}
  {%- endif %}
  - chain: {{ chain_name }}
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
  {%-  if rule.source_network is defined %}
  - source: {{ rule.source_network }}
  {%- endif %}
  {%-  if rule.destination_network is defined %}
  - destination: {{ rule.destination_network }}
  {%- endif %}

  - save: True

{%- endfor %}

{%- endfor %}

{%- else %}

iptables_services:
  service.dead:
  - enable: false
  - name: {{ service.service }}

{%- endif %}
