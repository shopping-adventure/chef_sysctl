require 'spec_helper'

# examples at https://github.com/sethvargo/chefspec/tree/master/examples

describe 'sysctl::default' do
  platforms = {
    'ubuntu' => ['10.04', '12.04'],
    'debian' => ['7.0'],
    'centos' => ['5.9', '6.4']
  }

  # Test all generic stuff on all platforms
  platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node.set['sysctl']['conf_dir'] = '/etc/sysctl.d'
            node.set['sysctl']['params'] = {
            'vm' => {
              'swappiness' => 19
            },
            'net' => {
              'ipv4' => {
                'tcp_fin_timeout' => 29
              }
            }
          }
          end.converge('sysctl::default')
        end

        it 'creates sysctl.conf_dir directory' do
          expect(chef_run).to create_directory('/etc/sysctl.d').with(
            user: 'root',
            group: 'root'
          )

          expect(chef_run).to_not create_directory('/etc/sysctl.d').with(
            user: 'bacon',
            group: 'fat'
          )
        end

        it 'creates the 99-chef-attributes.conf template with attributes' do
          expect(chef_run).to create_template('/etc/sysctl.d/99-chef-attributes.conf').with(
            source: 'sysctl.conf.erb',
            mode: '0644'
          )
          expect(chef_run).to_not create_template('/etc/sysctl.d/99-chef-attributes.conf').with(
            mode: '0755'
          )
        end

        let(:template) { chef_run.template('/etc/sysctl.d/99-chef-attributes.conf') }

        it 'sends a notification to the procps service' do
          expect(template).to notify('service[procps]').immediately
          expect(template).to_not notify('service[not_procps]').immediately
        end

        it 'sends the specific notification to the procps service immediately' do
          expect(template).to notify('service[procps]').to(:start).immediately
          expect(template).to_not notify('service[procps]').to(:start).delayed
        end
      end
    end
  end

  versions = ['5.9', '6.4']
  versions.each do |version|
    context "on Centos #{version}" do
      let(:chef_run) do
        runner = ChefSpec::Runner.new(platform: 'centos', version: version)
        runner.node.set['sysctl']['conf_dir'] = '/etc/sysctl.d'
        runner.node.set['sysctl']['params'] = {
          'vm' => {
            'swappiness' => 19
          },
          'net' => {
            'ipv4' => {
              'tcp_fin_timeout' => 29
            }
          }
        }
        runner.converge(described_recipe)
      end
      it 'creates a template /etc/rc.d/init.d/procps' do
        expect(chef_run).to create_template('/etc/rc.d/init.d/procps')
      end
    end
  end
end
