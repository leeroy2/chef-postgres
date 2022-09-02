# frozen_string_literal: true

hostname = command('hostname').stdout.strip

control 'ohai' do
  describe json(command: '/opt/chef/embedded/bin/ohai -d /opt/kitchen/ohai/plugins service') do
    its('listen_address') { should eq hostname }
    context 'postgres' do
      its(%w(postgres host)) { should eq hostname }
      its(%w(postgres port)) { should eq '5432' }
      its(%w(postgres jdbc_url)) { should eq "jdbc:postgresql://#{hostname}:5432" }
      context 'edp database' do
        its(%w(postgres databases edp jdbc_url)) { should eq "jdbc:postgresql://#{hostname}:5432/edp" }
        context 'schemas' do
          its(%w(postgres databases edp schemas public jdbc_url)) do
            should eq "jdbc:postgresql://#{hostname}:5432/edp?currentSchema=public"
          end
          its(%w(postgres databases edp schemas edp jdbc_url)) do
            should eq "jdbc:postgresql://#{hostname}:5432/edp?currentSchema=edp"
          end
          its(%w(postgres databases edp schemas mock jdbc_url)) do
            should eq "jdbc:postgresql://#{hostname}:5432/edp?currentSchema=mock"
          end
        end
      end
    end
  end
end
