resource "local_file" "jenkins_infra_data_report" {
  content = jsonencode({
    "archives.jenkins.io" = {
      # https://docs.digitalocean.com/products/networking/dns/getting-started/dns-registrars/
      "name_servers" = [
        "ns1.digitalocean.com",
        "ns2.digitalocean.com",
        "ns3.digitalocean.com",
      ],
      "service_ips" = {
        "ipv4" = digitalocean_droplet.archives_jenkins_io.ipv4_address,
        "ipv6" = digitalocean_droplet.archives_jenkins_io.ipv6_address,
      },
      "outbound_ips" = {
        "ipv4" = digitalocean_droplet.archives_jenkins_io.ipv4_address,
        "ipv6" = digitalocean_droplet.archives_jenkins_io.ipv6_address,
      },
    },
    "jay.training" = {
      "service_ips" = {
        "ipv4" = digitalocean_droplet.jay_training.ipv4_address,
        "ipv6" = digitalocean_droplet.jay_training.ipv6_address,
      },
    },
  })
  filename = "${path.module}/jenkins-infra-data-reports/digitalocean.json"
}
output "jenkins_infra_data_report" {
  value = local_file.jenkins_infra_data_report.content
}
