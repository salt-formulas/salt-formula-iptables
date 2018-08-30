{%- from "iptables/map.jinja" import schema with context %}
{%- if pillar.iptables.service.enabled is not defined %}
include:
  - iptables.v{{ schema.epoch }}.v4_service
  - iptables.v{{ schema.epoch }}.v6_service
{%- endif %}
