{% from "iptables/map.jinja" import service with context %}

{%- for chain_name, chain in service.get('chain', {}).iteritems() %}

iptables_{{ chain_name }}:
  iptables.chain_present:
    - family: ipv4
    - name: {{ chain_name }}
    - table: filter

{%-   if grains.ipv6|default(False) and service.ipv6|default(True) %}
iptables_{{ chain_name }}_ipv6:
  iptables.chain_present:
    - family: ipv6
    - name: {{ chain_name }}
    - table: filter
    - require_in:
      - iptables: iptables_{{ chain_name }}_ipv6_policy
{%-   endif %}

{%- if chain.policy is defined %}
iptables_{{ chain_name }}_policy:
  iptables.set_policy:
    - family: ipv4
    - chain: {{ chain_name }}
    - policy: {{ chain.policy }}
    - table: filter
    - require:
      - iptables: iptables_{{ chain_name }}

{%-   if grains.ipv6|default(False) and service.ipv6|default(True) %}
iptables_{{ chain_name }}_ipv6_policy:
  iptables.set_policy:
    - family: ipv6
    - chain: {{ chain_name }}
    - policy: {{ chain.policy }}
    - table: filter
    - require:
      - iptables: iptables_{{ chain_name }}_ipv6
{%-   endif %}
{%- endif %}

{%- for service_name, service in pillar.items() %}
{%- if service.get('_support', {}).get('iptables', {}).get('enabled', False) %}

{%- set grains_fragment_file = service_name+'/meta/iptables.yml' %}
{%- macro load_grains_file() %}{% include grains_fragment_file %}{% endmacro %}
{%- set grains_yaml = load_grains_file()|load_yaml %}

{%- for rule in grains_yaml.iptables.rules %}
{%- set rule_name = service_name+'_'+loop.index|string %}
{% include "iptables/_rule.sls" %}
{%- endfor %}

{%- endif %}
{%- endfor %}

{%- for rule in chain.get('rules', []) %}
{%- set rule_name = loop.index %}
{% include "iptables/_rule.sls" %}
{%- endfor %}

{%- endfor %}
