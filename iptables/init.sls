include:
{%- if pillar.iptables.service is defined %}
- iptables.service
{%- endif %}