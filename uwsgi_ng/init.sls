{% from "uwsgi_ng/map.jinja" import uwsgi_ng with context %}
{% from "nginx/ng/map.jinja" import nginx with context %}
{% set settings = salt['pillar.get']('uwsgi_ng') %}

# install uwsgi globally
# TODO: optionally install uwsgi in a separate virtualenv
uwsgi-installed:
   pkg.installed:
     - names:
       - uwsgi
       - uwsgi-plugin-python
       - python-virtualenv

{% macro get_app_archive_dir(app) -%}
   {{ settings.apps.managed.get(app).get('archive_dir', 'salt://dist/' ~ app ~ '/master') }}
{%- endmacro %}
{% macro get_app_home_dir(app) -%}
   {{ settings.apps.managed.get(app).get('home', uwsgi_ng.home ~ '/' ~ app) }}
{%- endmacro %}
{% macro get_app_dist_dir(app) -%}
   {{ get_app_home_dir(app) ~ '/.dist' }}
{%- endmacro %}
{% macro get_app_virtualenv(app) -%}
   {{ get_app_home_dir(app) ~ '/virtual_app' }}
{%- endmacro %}
{% macro get_app_package_name(app) -%}
   {{ settings.apps.managed.get(app).get('package_name', app) }}
{%- endmacro %}
{% macro get_app_django_project_name(app) -%}
   {{ settings.apps.managed.get(app).get('django_project_name', get_app_package_name(app).replace('-', '_')) }}
{%- endmacro %}
{% macro get_app_frontend_dir(app) -%}
   {{ settings.apps.managed.get(app).get('frontend_dir', '') }}
{%- endmacro %}
{% macro get_app_wheelhouse(app) -%}
   {{ get_app_dist_dir(app) ~ '/wheelhouse' }}
{%- endmacro %}
{% macro get_app_pip_requirements(app) -%}
{% set pip_requirements = settings.apps.managed.get(app).get('pip_requirements') -%}
   {% if pip_requirements %}{{ get_app_dist_dir(app) ~ '/requirements.txt' }}{% endif %}
{%- endmacro %}
{% macro get_app_frontend_dist_dir(app) -%}
   {% if get_app_frontend_dir(app) %}{{ get_app_dist_dir(app) ~ "/" ~ get_app_frontend_dir(app) }}{% endif %}
{%- endmacro %}
{% macro get_app_uwsgi_config_template(app) -%}
   {{ settings.apps.managed.get(app).get('config_template', 'salt://uwsgi_ng/files/uwsgi.ini.jinja') }}
{%- endmacro %}
{% macro get_app_uwsgi_config(app) -%}
   {{ get_app_home_dir(app) ~ "/uwsgi/uwsgi.ini" }}
{%- endmacro %}
{% macro get_app_uwsgi_control_dir(app) -%}
   {{ get_app_home_dir(app) ~ "/uwsgi/control" }}
{%- endmacro %}
{% macro get_app_uwsgi_master_fifo(app) -%}
   {{ get_app_uwsgi_control_dir(app) ~ "/master.fifo" }}
{%- endmacro %}
{% macro get_app_uwsgi_socket(app) -%}
   {{ settings.apps.managed.get(app).get('uwsgi_socket', get_app_home_dir(app) ~ "/uwsgi.sock") }}
{%- endmacro %}
{% macro get_app_uwsgi_pidfile(app) -%}
   {{ settings.apps.managed.get(app).get('uwsgi_pidfile', get_app_uwsgi_control_dir(app) ~ "/uwsgi.pid") }}
{%- endmacro %}
{% macro get_app_uwsgi_workers(app) -%}
   {{ settings.apps.managed.get(app).get('workers', 4) }}
{%- endmacro %}
{% macro get_app_uwsgi_wsgi_module(app) -%}
   {{ settings.apps.managed.get(app).get('wsgi_module', get_app_django_project_name(app) ~ ".wsgi") }}
{%- endmacro %}
{% macro get_app_uwsgi_upstart_config(app) -%}
   {{ settings.apps.managed.get(app).get('upstart_config', '/etc/init/uwsgi.conf') }}
{%- endmacro %}
{% macro get_app_uwsgi_upstart_template(app) -%}
   {{ settings.apps.managed.get(app).get('upstart_template', 'salt://uwsgi_ng/files/etc_init_uwsgi.conf.jinja') }}
{%- endmacro %}
{% macro get_app_static_dir(app) -%}
   {{ settings.apps.managed.get(app).get('static_dir', get_app_home_dir(app) ~ "/static") }}
{%- endmacro %}
{% macro get_app_data_dir(app) -%}
   {{ settings.apps.managed.get(app).get('data_dir', get_app_home_dir(app) ~ "/data") }}
{%- endmacro %}
{% macro get_app_media_dir(app) -%}
   {{ settings.apps.managed.get(app).get('media_dir', get_app_home_dir(app) ~ "/media") }}
{%- endmacro %}
{% macro get_app_user(app) -%}
   {{ settings.apps.managed.get(app).get('user', app) }}
{%- endmacro %}
{% macro get_django_settings(app) -%}
   {{ settings.apps.managed.get(app).get('django_settings_module', get_app_django_project_name(app) ~ ".settings" ) }}
{%- endmacro %}


{% for app, app_settings in settings.apps.managed.items() %}
{% with %}
   {% set archive_dir = get_app_archive_dir(app) %}
   {% set dist = get_app_dist_dir(app) %}
   {% set virtualenv = get_app_virtualenv(app) %}
   {% set home_dir = get_app_home_dir(app) %}
   {% set package_name = get_app_package_name(app) %}
   {% set wheelhouse = get_app_wheelhouse(app) %}
   {% set uwsgi_config_template = get_app_uwsgi_config_template(app) %}
   {% set uwsgi_config = get_app_uwsgi_config(app) %}
   {% set uwsgi_upstart_template = get_app_uwsgi_upstart_template(app) %}
   {% set uwsgi_upstart_config = get_app_uwsgi_upstart_config(app) %}
   {% set uwsgi_control_dir = get_app_uwsgi_control_dir(app) %}
   {% set uwsgi_socket = get_app_uwsgi_socket(app) %}
   {% set uwsgi_master_fifo = get_app_uwsgi_master_fifo(app) %}
   {% set uwsgi_pidfile = get_app_uwsgi_pidfile(app) %}
   {% set uwsgi_workers = get_app_uwsgi_workers(app) %}
   {% set uwsgi_wsgi_module = get_app_uwsgi_wsgi_module(app) %}
   {% set pip_requirements = get_app_pip_requirements(app) %}
   {% set static_dir = get_app_static_dir(app) %}
   {% set frontend_dist = get_app_frontend_dist_dir(app) %}
   {% set media_dir = get_app_media_dir(app) %}
   {% set data_dir = get_app_data_dir(app) %}
   {% set django_settings = get_django_settings(app) %}
   {% set user = get_app_user(app) %}

{% macro app_env() %}
- DJANGO_HOME_DIR: {{ home_dir }}
- DJANGO_STATIC_ROOT: {{ static_dir }}
- DJANGO_MEDIA_ROOT: {{ media_dir }}
- DJANGO_DATA_ROOT: {{ data_dir }}
{%- for key, val in settings.apps.managed.get(app).get('env', {}).iteritems() %}
- {{ key }}: "{{ val }}" {# TODO: escape double quotes in val #}
{%- endfor %}
{% endmacro %}

app-{{ app }}-dist-extracted:
  file.recurse:
    - name: {{ dist }}
    - source: {{ archive_dir }}

app-{{ app }}-virtualenv:
  virtualenv.managed:
    - name: {{ virtualenv }}
    - use_wheel: True
    - require:
      - pkg: python-virtualenv

# install dependencies
# TODO: declare this in app manifest
app-{{ app }}-libraries:
  pkg.installed:
    - names:
      - libjpeg62

{%- if pip_requirements %}
app-{{ app }}-virtualenv-pip-package:
  pip.installed:
    - name: {{ package_name }}
    - find_links: {{ wheelhouse }}
    - no_index: True
    - use_wheel: True
    - bin_env: {{ virtualenv }}
    - use_vt: True
    - require:
        - virtualenv: app-{{ app }}-virtualenv
        - pkg: uwsgi-installed
        - file: app-{{ app }}-dist-extracted
        - pkg: app-{{ app }}-libraries
{% endif %}

app-{{ app }}-virtualenv-pip:
  pip.installed:
    - name: {{ package_name }}
    {%- if pip_requirements %}
    - requirements: {{ pip_requirements }}
    {%- endif %}
    - find_links: {{ wheelhouse }}
    - no_index: True
    - use_wheel: True
    - bin_env: {{ virtualenv }}
    - use_vt: True
    - require:
        - virtualenv: app-{{ app }}-virtualenv
        - pkg: uwsgi-installed
        - file: app-{{ app }}-dist-extracted
        - pkg: app-{{ app }}-libraries
        {%- if pip_requirements %}
        - pip: app-{{ app }}-virtualenv-pip-package
        {%- endif %}

app-{{ app }}-virtualenv-pip-permissions:
  file.directory:
    - name: {{ virtualenv }}
    - group: {{ user }}
    - mode: 750
    - require:
      - pip: app-{{ app }}-virtualenv-pip

# create uwsgi configuration file
app-{{ app }}-uwsgi-config:
  file.managed:
    - name: {{ uwsgi_config }}
    - source: {{ uwsgi_config_template }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
        - pip: app-{{ app }}-virtualenv-pip
    - defaults:
        uwsgi_socket: {{ uwsgi_socket }}
        uwsgi_pidfile: {{ uwsgi_pidfile }}
        uwsgi_master_fifo: {{ uwsgi_master_fifo }}
        uwsgi_workers: {{ uwsgi_workers }}
        uwsgi_wsgi_module: {{ uwsgi_wsgi_module }}
        virtualenv: {{ virtualenv }}
        uwsgi_user: {{ user }}
        uwsgi_group: {{ nginx.lookup.webuser }}
        django_settings: {{ django_settings }}
        env:
            {{ app_env()|indent(12) }}

# staticfiles
app-{{ app }}-static-dir:
  file.directory:
    - name: {{ static_dir }}
    - group: {{ nginx.lookup.webuser }}

# Puts the frontend near the project root to make collectstatic happy
app-{{ app }}-static-frontend:
  cmd.run:
    - name: {% if frontend_dist %}cp -r {{ frontend_dist }} {{ home_dir }}{% else %} echo no frontend{% endif %}
    - require:
      - file: app-{{ app }}-static-dir
      - file: app-{{ app }}-dist-extracted

# collect assets from django static files
app-{{ app }}-static-django:
  cmd.run:
    - name: {{ virtualenv }}/bin/django-admin.py collectstatic --noinput --settings {{ django_settings }}
    - cwd: {{ home_dir }}
    - env:
      {{ app_env()|indent(6) }}
    - require:
      - cmd: app-{{ app }}-static-frontend
      - pip: app-{{ app }}-virtualenv-pip

# make staticfiles visible to nginx
app-{{ app }}-static-django-permissions:
  file.directory:
    - name: {{ static_dir }}
    - group: {{ nginx.lookup.webuser }}
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - group
      - mode
    - require:
      - cmd: app-{{ app }}-static-django

app-{{ app }}-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - group: {{ user }}
    - user: {{ user }}
    - dir_mode: 750
    - file_mode: 640
    - recurse:
      - user
      - group
      - mode

app-{{ app }}-media-dir:
  file.directory:
    - name: {{ media_dir }}
    - group: {{ nginx.lookup.webuser }}
    - user: {{ user }}
    - dir_mode: 770
    - file_mode: 660
    - recurse:
      - user
      - group
      - mode

app-{{ app }}-home-dir-read:
  file.directory:
    - name: {{ home_dir }}
    - user: {{ user }}
    - group:  {{ nginx.lookup.webuser }}
    - dir_mode: 750

app-{{ app }}-manage-py:
  file.managed:
    - name: {{ home_dir }}/manage.sh
    - mode: 750
    - source: salt://uwsgi_ng/files/manage.sh.jinja
    - template: jinja
    - defaults:
        user: {{ user }}
        group: {{ nginx.lookup.webuser }}
        django_settings: {{ django_settings }}
        virtualenv: {{ virtualenv }}
        env:
            {{ app_env()|indent(12) }}

app-{{ app }}-uwsgi-upstart-config:
  file.managed:
    - name: {{ uwsgi_upstart_config }}
    - source: {{ uwsgi_upstart_template }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
        - pip: app-{{ app }}-virtualenv-pip
        - file: app-{{ app }}-uwsgi-config
    - defaults:
        uwsgi_config: {{ uwsgi_config }}

app-{{ app }}-uwsgi-upstart-run:
  service.running:
    - name: uwsgi
    - provider: upstart
    - watch:
      - file: app-{{ app }}-uwsgi-upstart-config
      - file: app-{{ app }}-uwsgi-config

app-{{ app }}-uwsgi-graceful-restart:
  cmd.run:
    - name: echo c > {{ uwsgi_master_fifo }}
    - timeout: 5
    - watch:
      - pip: app-{{ app }}-virtualenv-pip
    - require:
      - service: app-{{ app }}-uwsgi-upstart-run

{% endwith %}
{% endfor %}
