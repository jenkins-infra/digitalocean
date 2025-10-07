locals {
  # Ref. https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
  # Only IPv4
  # TODO track with updatecli
  github_ips = {
    webhooks = ["140.82.112.0/20", "143.55.64.0/20", "185.199.108.0/22", "192.30.252.0/22"]
  }
  default_tags = {
    scope                    = "terraform-managed"
    jenkins_infra_repository = "digitalocean"
  }

  usage_jenkins_io_vmname = "usage"
  usage_jenkins_io_fqdn   = "${local.usage_jenkins_io_vmname}.${digitalocean_domain.do_jenkins_io.name}"

  archives_jenkins_io_vmname = "archives"
  archives_jenkins_io_fqdn   = "${local.archives_jenkins_io_vmname}.${digitalocean_domain.do_jenkins_io.name}"

  # Tracked by 'updatecli' from the following source: https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
  outbound_ips_private_vpn_jenkins_io = "52.232.183.117"
  # Tracked by 'updatecli' from the following source: https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
  outbound_ips_trusted_ci_jenkins_io = "104.209.128.236"
  # Tracked by 'updatecli' from the following source: https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
  outbound_ips_infra_ci_jenkins_io = "20.57.120.46 52.179.141.53 172.210.200.59 20.10.193.4"
  # TODO: track with updatecli
  inbound_ips_pkg_origin_jenkins_io = "52.202.51.185"
  # TODO: track with updatecli
  outbound_ips_pkg_origin_jenkins_io = "52.202.51.185"
  # TODO: track with updatecli
  inbound_ips_ftp_osl_osuosl_org = "140.211.166.134 2605:bc80:3010::134"
}
