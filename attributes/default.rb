if platform_family?('debian', 'rhel')
  default['sysctl']['conf_dir'] = '/etc/sysctl.d'
else
  default['sysctl']['conf_dir'] = nil
end

default['sysctl']['allow_sysctl_conf'] = false
default['sysctl']['enable_sysctl'] = false

#Param to be setup manually into chef, not in this file. personal behaviour
default['sysctl']['params']["net.netfilter.nf_conntrack_tcp_timeout_established"]= "86400"
default['sysctl']['params']["net.ipv4.netfilter.ip_conntrack_tcp_timeout_established"]= "86400"
