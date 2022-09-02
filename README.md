# Description

This cookbook installs and configures Postgres.
Also it provides the ability to create LVM mount points to cover the needs of a Production installation.


# Requirements

## Databags

### postgres

Contains encrypted items that define the structure of the databases/schemas/roles.

Sample format:

```json
{
  "id": "environment name",
  "roles": {
    "superuser": {
      "password": "testkitchen"
    },
    "app_users": {
      "application_user1": {
        "password": "testkitchen"
      }
    }
  },
  "databases": {
    "edp": {
      "role": "application_user1",
      "schemas": [
        "schema1",
        "schema2"
      ]
    }
  }
}
```

## Chef Client:

* chef (>= 12) ()

## Platform:

* redhat
* centos

## Cookbooks:

* setup-utils (= 1.0.2)
* lvm (= 4.5.4)
* sudo (= 4.0.1)

# Attributes

* `node['postgres']['user']` - The os user that is redis owner. Defaults to `app_user`.
* `node['postgres']['group']` - The os group that is redis owner. Defaults to `app_user`.
* `node['postgres']['version']` - The version of Redis to install. Defaults to `11.4.0`.
* `node['postgres']['path']` - The path where the current redis version is installed. Depends on base_override attributes defined on the base role. Defaults to `#{node['base_override']['ark']['prefix_home']}/postgres`.
* `node['postgres']['port']` - The port that postgres listens. Defaults to `5432`.
* `node['postgres']['basedir']` - Postgres base directory. Defaults to `/pgdata`.
* `node['postgres']['data_dir']` - Postgres mandatory directories. Defaults to `#{node['postgres']['basedir']}/data`.
* `node['postgres']['archives_dir']` -  Defaults to `#{node['postgres']['basedir']}/pg_archives`.
* `node['postgres']['logs_dir']` -  Defaults to `#{node['postgres']['basedir']}/logs`.
* `node['postgres']['security']['db_item']` - The name of the postgres data bag item. Defaults to `node.chef_environment`.
* `node['postgres']['service']['name']` - The name of systemd service. Defaults to `postgres`.
* `node['postgres']['service']['enabled']` - Postgres service enabled?. Defaults to `true`.
* `node['postgres']['nofile']['hard']` - The number of file descriptors. Defaults to `10_240`.
* `node['postgres']['data']['device']` - The device name of postgres data. Defaults to `/dev/sdc`.
* `node['postgres']['log_statement']` - The log statement of postgres. Defaults to `all`.
* `node['postgres']['archivelog']['mode']` - Archive log mode for postgres. Defaults to `false`.
* `node['postgres']['archivelog']['timeout']` - The archive log timeout. Defaults to `0`.
* `node['postgres']['lvm']['configure']` - Flag to use lvm or not. Defaults to `true`.
* `node['postgres']['tuning_properties']` - The database tuning properties. Defaults to `{ ... }`.

# Recipes

* postgres::default
* postgres::install
* [postgres::lvm_config](#postgreslvm_config) - Cookbook:: postgres Recipe:: lvm_config Prepares the data folders for postpgres db The recipe can configure a separate lvm volume if desired.

## <a name="postgreslvm_config"></a> postgres::lvm_config

Cookbook:: postgres
Recipe:: lvm_config
Prepares the data folders for postpgres db
The recipe can configure a separate lvm volume if desired.
Copyright:: 2019, The Authors, All Rights Reserved.

# Resources

* [postgres_config](#postgres_config) - This resource configures postgres database   * Creates the basic folders postgres needs to work.
* [postgres_database](#postgres_database)
* [postgres_service](#postgres_service) - This resource creates the linux service for Postgres (SystemD).

## <a name="postgres_config"></a> postgres_config

This resource configures postgres database

 * Creates the basic folders postgres needs to work.
 * Compiles and initializes postgres
 * Creates the configuration file of postgres.
 * Configures Logrotate via postgresql.conf file.

### Actions

- create: configures postgres. Default action.

### Attribute Parameters

- log_statement:
- archivelog_mode:

### Example

  ```ruby
  postgres_config 'configure' do
    log_statement node['postgres']['log_statement']
    archivelog_mode node['postgres']['archivelog']['mode']
  end
  ```

## <a name="postgres_database"></a> postgres_database

This resource creates a postgres database owned by a specified user containing the defined schemas

 * Creates the user of the database
 * Creates the database
 * Creates the tablespace for the database
 * Creates the schemas of the database
 * Exposes the database and the schemas to ohai

### Actions

- create: configures postgres. Default action.

### Attribute Parameters

- database_name: the name of the database to create.
- data_bag_item: the name of the data bag item that contains the database definition.
- owner: the linux user that is postgres admin.
- group: the linux group of the postgres admin.
- postgres_path: the installation path of postgreSQL.
- data_dir: the data path of posgreSQL.

### Example

  ```ruby
  postgres_database 'dbname' do
    databag_item 'db_name_qa'
    owner 'vagrant'
    group 'vagrant'
    data_dir '/pgdata'
    postgres_path '/opt/applications/postgres'
  end
  ```

## <a name="postgres_service"></a> postgres_service

This resource creates the linux service for Postgres (SystemD).
Also takes care to allow the program user to start/stop/restart the service
with the appropriate sudoer entries.

This implementation is RHEL specific and creates the service in systems that use systemd.

### Actions

- create: Creates the service, configures the sudoers and enables or disables the service. Default action.
- reload:
- restart: Restarts the service.
- start: Starts the service.
- stop: Stops the service.

### Attribute Parameters

- program_home: The installation path for Postgres.
- service_name: The name of the service in linux. Defaults to <code>"\"postgres\""</code>.
- maintenance: If this flag is set to true the service cannot be started by CHEF. Defaults to <code>"false"</code>.
- program_user: The user that executes Postgres.
- program_group:
- enabled: This flag indicates if the service will start after a reboot. Defaults to <code>"true"</code>.

### Example

  ```ruby
  postgres_service 'create postgres service' do
    program_home '/opt/applications/postgres'
    program_user 'app_user'
  end
  ```

# Code Quality

## Auto-config
To easily configure your cookbook with the up to date quality configuration
make sure you have an up to date checkout of this cookbook from git in a path let's say `SEED_PATH`

Go to your cookbook root folder and execute:
```bash
SEED_PATH/apply-quality-configs.sh
```
This will copy to your cookbook all the up to date quality configuration.

## Cookbook Integration testing with kitchen.

### Workstation Preparation

WARNING: It is advised to have vagrant without any plugins installed for kitchen to work smoothly.

#### Linux hosts

#### Windows Hosts

##### Required software:
- Windows 10
- WLS (Windows subsystem for linux ubuntu 18.04)
- VirtualBox > 5.1 (for windows)
- Vagrant > 2 (for ubuntu)
- ChefDK latest (for ubuntu)
- git (with ssh authentication)
- Powershell

##### Installation instructions
- Install VirtualBox
- Install WSL (Windows Subsystem for Linux)

```powershell
# Enable WSL and restart
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Download the ubuntu image
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.appx -UseBasicParsing

# Install by just clicking on it.
# When prompted for user creation (use your P account)
```

- Configure the WSL

```bash

#Inside the WSL
# Setup apt proxy
Edit the file with sudo /etc/apt/apt.conf.d/01Proxy
Add inside: Acquire::http::Proxy "http://webproxy.nrb.be:8080/";

#Install vagrant and chefdk
to install a downloadable deb file use the command: sudo dpkg -i <file>.deb

# Setup the internal DNS server
Edit the file with sudo /etc/resolv.conf
Comment out all entries and add a new one:
nameserver 172.17.52.220

# Set system variables
Edit ~/.bashrc
# Add the following lines to the end.
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
export KITCHEN_YAML=".kitchen-windows.yml"

#Create a shared folder
mkdir -p /mnt/c/projects

# Close are reopen WSL
```

##### Verification
- Clone the cookbook in your WLS home folder ("cd ~" to go there).
- Activate the WSL configuration for kitchen
```bash
# Inside the cookbook folder execute:
cp kitchen-configs/wsl.yml .kitchen.local.yml
```
- Verify that the seed kitchen environment works:

```bash
# Inside the cookbook folder execute:
kitchen list
```

Expected output:
```bash
Instance       Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-rhel6  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-rhel7  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
```
- Converge the vm it should start without errors

```bash
# Inside the cookbook folder execute:
kitchen converge default-rhel7
```

- (Optional) connect to the converged vm
```bash
kitchen login default-rhel7
```

- Destroy the vm after you complete the testing
```bash
# Inside the cookbook folder execute:
kitchen destroy default-rhel7
```

# Development notes

# License and Maintainer

Maintainer:: Lampros Batalas

License:: All Rights Reserved
