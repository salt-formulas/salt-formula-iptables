{% from "iptables/map.jinja" import defaults,schema,service with context %}

  {%- if service.v6.enabled %}

iptables_packages_v6:
  pkg.installed:
  - names: {{ service.v6.pkgs }}

iptables_modules_v6_load:
  kmod.present:
  - persist: true
  - mods: {{ service.v6.modules }}
  - require:
    - pkg: iptables_packages_v6

{{ service.v6.persistent_config }}:
  file.managed:
  - user: root
  - group: root
  - mode: 640
  - source: salt://iptables/v{{ schema.epoch }}/files/v6_rules
  - template: jinja
  - require:
    - pkg: iptables_packages_v6

    {% if grains['os'] == 'Ubuntu' %}

iptables_services_v6_start:
  cmd.run:
  - name: find /usr/share/netfilter-persistent/plugins.d/[0-9]*-ip6tables -exec {} start \;
  - onlyif: test $(ip6tables-save | wc -l) -eq 0
  - require:
    - file: {{ service.v6.persistent_config }}
    - kmod: iptables_modules_v6_load

    {%- endif %}

{{ service.v6.service }}:
  service.running:
  - enable: true
  - require:
    - file: {{ service.v6.persistent_config }}
    - kmod: iptables_modules_v6_load
  - watch:
    - file: {{ service.v6.persistent_config }}

iptables_tables_cleanup_v6:
  module.wait:
  - name: iptables_extra.remove_stale_tables
  - config_file: {{ service.v6.persistent_config }}
  - family: ipv6
  - require:
    - file: {{ service.v6.persistent_config }}
  - watch:
    - file: {{ service.v6.persistent_config }}
  {%- else %}

    {% if grains['os'] == 'Ubuntu' %}

iptables_services_v6_stop:
  cmd.run:
  - name: find /usr/share/netfilter-persistent/plugins.d/[0-9]*-ip6tables -exec {} flush \;
  - onlyif: test $(which ip6tables-save) -eq 0 && test $(ip6tables-save | wc -l) -ne 0

{{ service.v6.persistent_config }}:
  file.absent:
  - require:
    - cmd: iptables_services_v6_stop

iptables_tables_flush_v6:
  module.wait:
  - name: iptables_extra.flush_all
  - family: ipv6
  - watch:
    - file: {{ service.v6.persistent_config }}

    {%- endif %}

{%- endif %}
