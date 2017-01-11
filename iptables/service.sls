{% from "iptables/map.jinja" import service with context %}

{%- if service.enabled %}

include:
  - iptables.rules

iptables_packages:
  pkg.installed:
  - names: {{ service.pkgs }}

iptables_services:
{%- if grains.init == 'systemd' %}
  service.running:
{%- else %}
  service.dead:
{%- endif %}
  - enable: true
  - name: {{ service.service }}
  - sig: test -e /etc/iptables/rules.v4
  - require:
    - pkg: iptables_packages

{%- else %}

iptables_services:
  service.dead:
  - enable: false
  - name: {{ service.service }}

{%- for chain_name in ['INPUT', 'OUTPUT', 'FORWARD'] %}
iptables_{{ chain_name }}_policy:
  iptables.set_policy:
    - chain: {{ chain_name }}
    - policy: ACCEPT
    - table: filter
    - require_in:
      - iptables: iptables_flush
{%- endfor %}

iptables_flush:
  iptables.flush

{%- endif %}
