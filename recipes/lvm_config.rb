# frozen_string_literal: true

lvm_volume_group 'PGDATA' do
  physical_volumes [node['postgres']['data']['device']]
  wipe_signatures false

  if node['postgres']['archivelog']['mode']
    logical_volume 'pgdata' do
      size        '60%VG'
      filesystem  'ext4'
      mount_point node['postgres']['basedir']
    end

    logical_volume 'pgarchives' do
      size '100%VG'
      filesystem 'ext4'
      mount_point node['postgres']['archives_dir']
    end
  else
    logical_volume 'pgdata' do
      size        '100%VG'
      filesystem  'ext4'
      mount_point node['postgres']['basedir']
    end
  end
  only_if { node['postgres']['lvm']['configure'] }
end
