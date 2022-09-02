# frozen_string_literal: true

control 'archive_log_off' do
  def query(database, query)
    %W(
      export PGPASSWORD=testkitchen && /opt/applications/postgres/bin/psql
      #{database}
      -U postgres
      -tAc \"#{query}\"
    ).join(' ')
  end

  describe bash(query('postgres', 'show archive_mode')) do
    its('stdout') { should match(/off/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end
end

control 'archive_log_on' do
  def query(database, query)
    %W(
      export PGPASSWORD=testkitchen && /opt/applications/postgres/bin/psql
      #{database}
      -U postgres
      -tAc \"#{query}\"
    ).join(' ')
  end

  describe bash(query('postgres', 'show archive_mode')) do
    its('stdout') { should match(/on/) }
    its('stderr') { should eq '' }
    its('exit_status') { should eq 0 }
  end
end
