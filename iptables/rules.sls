{% from "iptables/map.jinja" import service with context %}
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

{%- set chains = service.get('chain', {}).keys() %}
{%- for chain_name, chain in service.get('chain', {}).iteritems() %}

{%- set tables = [] %}
{%- for rule in chain.get('rules', []) %}
{%-   set table = rule.get('table', 'filter') %}
{%-   if table not in tables %}
{%-     do tables.append(table) %}
{%-   endif %}
{%- endfor %}
{%- if chain.policy is defined %}
{%-   if chain.policy is string %}
{%-     if 'filter' not in tables %}
{%-       do tables.append('filter') %}
{%-     endif %}
{%-   else %}
{%-     for policy in chain.policy %}
{%-       if policy.table not in tables %}
{%-         do tables.append(policy.table) %}
{%-       endif %}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- for table in tables %}
iptables_{{ table }}_{{ chain_name }}:
  iptables.chain_present:
    - family: ipv4
    - name: {{ chain_name }}
    - table: {{ table }}
    - require:
      - pkg: iptables_packages

{%-   if grains.ipv6|default(False) and service.ipv6|default(True) %}
iptables_{{ table }}_{{ chain_name }}_ipv6:
  iptables.chain_present:
    - family: ipv6
    - name: {{ chain_name }}
    - table: {{ table }}
    - require:
      - pkg: iptables_packages
{%-     if chain.policy is defined %}
{%-       if chain.policy is string %}
    - require_in:
      - iptables: iptables_filter_{{ chain_name }}_ipv6_policy
{%-       else %}
{%-         if table in chain.policy %}
    - require_in:
      - iptables: iptables_filter_{{ chain_name }}_ipv6_policy
{%-         endif  %}
{%-       endif  %}
{%-     endif  %}
{%-   endif %}
{%- endfor %}

{%- if chain.policy is defined %}

{%-   if chain.policy is string %}
{%-     set map = [{'table':'filter', 'policy':chain.policy}] %}
{%-   else %}
{%-     set map = chain.policy %}
{%-   endif %}

{%-   for policy in map %}
iptables_{{ policy.table }}_{{ chain_name }}_policy:
  iptables.set_policy:
    - family: ipv4
    - chain: {{ chain_name }}
    - policy: {{ policy.policy }}
    - table: {{ policy.table }}
    - require:
      - iptables: iptables_{{ policy.table }}_{{ chain_name }}

{%-     if grains.ipv6|default(False) and service.ipv6|default(True) %}
iptables_{{ policy.table }}_{{ chain_name }}_ipv6_policy:
  iptables.set_policy:
    - family: ipv6
    - chain: {{ chain_name }}
    - policy: {{ policy.policy }}
    - table: {{ policy.table }}
    - require:
      - iptables: iptables_{{ policy.table }}_{{ chain_name }}_ipv6
{%-     endif %}
{%-   endfor %}
{%- endif %}

{%- for service_name, service in pillar.items() %}
{%- if service is mapping %}
{%- if service.get('_support', {}).get('iptables', {}).get('enabled', False) %}

{%- set grains_fragment_file = service_name+'/meta/iptables.yml' %}
{%- macro load_grains_file() %}{% include grains_fragment_file %}{% endmacro %}
{%- set grains_yaml = load_grains_file()|load_yaml %}

{%- if grains_yaml is iterable %}
{%-   if grains_yaml.get('iptables',{}).rules is defined %}
{%-     for rule in grains_yaml.iptables.rules %}
{%-       set rule_name = service_name+'_'+loop.index|string %}
{% include "iptables/_rule.sls" %}
{%-     endfor %}
{%-   endif %}
{%- endif %}

{%- endif %}
{%- endif %}
{%- endfor %}

{%- for rule in chain.get('rules', []) %}
{%- set rule_name = loop.index %}
{% include "iptables/_rule.sls" %}
{%- endfor %}

{%- endfor %}
{%- endif %}
