{% from "iptables/map.jinja" import service with context %}
{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

{%- if grains.os_family == 'Debian' and service.get('provider') == "iptables-restore" %}
/etc/iptables/rules.v4.tmp:
  file.managed:
    - source: salt://iptables/files/rules.v4
    - template: jinja
    - makedirs: True
    - defaults:
        chains: {{ service.get('chain', {}) }}
    - require:
      - pkg: iptables_packages
      - file: /usr/share/netfilter-persistent/plugins.d/15-ip4tables
iptables-restore --test /etc/iptables/rules.v4.tmp:
  cmd.run:
    - onchanges:
      - file: /etc/iptables/rules.v4.tmp
cp -a /etc/iptables/rules.v4.tmp /etc/iptables/rules.v4:
  cmd.run:
    - onchanges:
      - cmd: "iptables-restore --test /etc/iptables/rules.v4.tmp"
    - watch_in:
      - service: iptables_services
cp -a /etc/iptables/rules.v4 /etc/iptables/rules.v4.tmp:
  cmd.run:
    - onfail:
      - cmd: "iptables-restore --test /etc/iptables/rules.v4.tmp"

{%- if grains.ipv6|default(False) and service.ipv6|default(True) %}
/etc/iptables/rules.v6.tmp:
  file.managed:
    - source: salt://iptables/files/rules.v6
    - template: jinja
    - makedirs: True
    - defaults:
        chains: {{ service.get('chain', {}) }}
    - require:
      - pkg: iptables_packages
      - file: /usr/share/netfilter-persistent/plugins.d/25-ip6tables
    - watch_in:
      - service: iptables_services
ip6tables-restore --test /etc/iptables/rules.v6.tmp:
  cmd.run:
    - onchanges:
      - file: /etc/iptables/rules.v6.tmp
cp -a /etc/iptables/rules.v6.tmp /etc/iptables/rules.v6:
  cmd.run:
    - onchanges:
      - cmd: "ip6tables-restore --test /etc/iptables/rules.v6.tmp"
    - watch_in:
      - service: iptables_services
cp -a /etc/iptables/rules.v6 /etc/iptables/rules.v6.tmp:
  cmd.run:
    - onfail:
      - cmd: "ip6tables-restore --test /etc/iptables/rules.v6.tmp"
{%- endif %}
{%- else %}

{%- for chain_name, chain in service.get('chain', {}).iteritems() %}

iptables_{{ chain_name }}:
  iptables.chain_present:
    - family: ipv4
    - name: {{ chain_name }}
    - table: filter
    - require:
      - pkg: iptables_packages

{%-   if grains.ipv6|default(False) and service.ipv6|default(True) %}
iptables_{{ chain_name }}_ipv6:
  iptables.chain_present:
    - family: ipv6
    - name: {{ chain_name }}
    - table: filter
    - require:
      - pkg: iptables_packages
{%-     if chain.policy is defined %}
    - require_in:
      - iptables: iptables_{{ chain_name }}_ipv6_policy
{%-     endif  %}
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
{%- endif %}
{%- endif %}
