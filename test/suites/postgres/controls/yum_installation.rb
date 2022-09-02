# frozen_string_literal: true

ip_address = command('hostname -I').stdout.strip.split(' ').last

control 'yum_installation' do
  describe directory('/pgdata') do
    it { should exist }
    its('owner') { should eq 'postgres' }
  end

  describe file('/tmp/secretfile') do
    it { should_not exist }
  end

  describe systemd_service('postgres') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5432) do
    its('processes') { should include 'postmaster' }
    its('protocols') { should include 'tcp' }
    its('addresses') { should include ip_address }
  end

  def query(database, query)
    %W(
      export PGPASSWORD=testkitchen && /usr/bin/psql
      #{database}
      -U postgres
      -tAc \"#{query}\"
    ).join(' ')
  end

  describe bash(query('postgres', "SELECT 1 FROM pg_roles WHERE rolname='postgres'")) do
    its('stdout') { should match(/1/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  describe bash(query('postgres', "SELECT 1 FROM pg_roles WHERE rolname='edpuser'")) do
    its('stdout') { should match(/1/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  describe bash(query('postgres', "SELECT 1 FROM pg_roles WHERE rolname='edpuser'")) do
    its('stdout') { should match(//) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  describe bash('export PGPASSWORD=testkitchen && /usr/bin/psql postgres -U postgres -lqt') do
    its('stdout') { should match(/edp[ ]*\| edpuser/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end

  schemas_query = %w(select nspname)
  schemas_query << %w(from pg_catalog.pg_namespace)
  schemas_query << %w(where nspname not like)
  schemas_query << "'pg_%'"
  schemas_query << %w(and nspname !=)
  schemas_query << "'information_schema'"
  schemas_query << %w(order by nspname)

  describe bash(query('edp', schemas_query.join(' '))) do
    its('stdout') { should match(/edp/) }
    its('stdout') { should match(/public/) }
    its('stdout') { should match(/mock/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end
end
