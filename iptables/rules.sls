{% from "iptables/map.jinja" import service with context %}

{%- for chain_name, chain in service.get('chain', {}).iteritems() %}

{%- if chain.policy is defined %}
iptables_{{ chain_name }}_policy:
  iptables.set_policy:
    - chain: {{ chain_name }}
    - policy: {{ chain.policy }}
    - table: filter
{%- endif %}

{%- for rule in chain.get('rules', []) %}
{%- set rule_name = loop.index %}
{% include "iptables/_rule.sls" %}
{%- endfor %}

{%- for rule_name, rule in chain.get('rule', {}).iteritems() %}
{% include "iptables/_rule.sls" %}
{%- endfor %}

{%- endfor %}
