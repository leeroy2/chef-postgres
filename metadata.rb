# frozen_string_literal: true

name                'postgres'
maintainer          'Lampros Batalas'
maintainer_email    'labrosbat@gmail.com'
license             'All Rights Reserved'
description         'Installs/Configures Postgres'
chef_version        '>= 12'
supports            'redhat'
supports            'centos'

version             '2.0.0'
depends             'lvm', '= 4.5.4'
depends             'sudo', '= 4.0.1'
