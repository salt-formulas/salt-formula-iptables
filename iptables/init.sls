{%- from "iptables/map.jinja" import schema with context %}

{%- set include_allowed = true %}
{%- if grains.get('virtual_subtype', None) in ['Docker', 'LXC'] %}
{%- set include_allowed = false %}
echo_usupported_environment:
  cmd.run:
  - name: echo "You are trying to use iptables inside of docker or lxc. Kernel modules loading are not supported here"
{%- endif %}

{%- if pillar.iptables.service.enabled is defined %}
{%- set include_allowed = false %}
echo_usupported_pillars_schema:
  cmd.run:
  - name: echo "You are trying to use old style pillars schema. Please update pillars according to the current schema"
{%- endif %}

{%- if include_allowed %}
include:
- iptables.v{{ schema.epoch }}
{%- endif %}
