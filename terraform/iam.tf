data "template_file" "pol-splunk-ec2" {
  template = file("policy-aws/pol-splunk-ec2.json.tpl")
  vars = {
    s3_install      = aws_s3_bucket.s3_install.arn
    profile         = var.profile
    splunktargetenv = var.splunktargetenv
  }
}

locals {
  name-prefix-pol-splunk-ec2 = "pol-splunk-ec2-${var.profile}-$(var.region-master}-${var.splunktargetenv}"
}

#aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-worker} --instance-ids ${self.id}
##ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name} master_ip=${aws_instance.jenkins-master.private_ip}' ansible_templates/install_jenkins_worker.yml
##ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-worker-sample.yml
#resource "null_resource" "splunk-config" {
#  provisioner "local-exec" {
#    command = <<EOF
#EOF
#  }
#  depends_on = [ aws_s3_bucket.s3_data ]
#}


resource "aws_iam_policy" "pol-splunk-ec2" {
  name_prefix = "splunkconf_ec2_"
  # ... other configuration ...
  #name_prefix = local.name-prefix-pol-splunk-ec2
  description = "This policy include shared policy for Splunk EC2 instances"
  provider    = aws.region-master
  policy      = data.template_file.pol-splunk-ec2.rendered
}

data "template_file" "pol-splunk-splunkconf-backup" {
  template = file("policy-aws/pol-splunk-splunkconf-backup.json.tpl")

  vars = {
    s3_backup       = aws_s3_bucket.s3_backup.arn
    profile         = var.profile
    splunktargetenv = var.splunktargetenv
  }
}

resource "aws_iam_policy" "pol-splunk-splunkconf-backup" {
  name_prefix = "splunkconf_splunkconf-backup_"
  # ... other configuration ...
  #statement {
  #  sid = "pol-splunk-splunkconf-backup-${var.profile}-$(var.region-master}-${var.splunktargetenv}"
  #}
  description = "This policy allow instance to upload backup and fetch files for restauration in the bucket used for backups. Note that instances cant delete backups as this is completely managed by a lifecycle policy by design"
  provider    = aws.region-master
  policy      = data.template_file.pol-splunk-splunkconf-backup.rendered
}

locals {
   dnszone_id = data.terraform_remote_state.network.outputs.dnszone_id
}

data "template_file" "pol-splunk-route53-updatednsrecords" {
  template = file("policy-aws/pol-splunk-route53-updatednsrecords.json.tpl")

  vars = {
    zone-id         = local.dnszone_id
    profile         = var.profile
    splunktargetenv = var.splunktargetenv
  }
}

resource "aws_iam_policy" "pol-splunk-route53-updatednsrecords" {
  name_prefix = "splunkconf_route53_updatednsrecords_"
  # ... other configuration ...
  #statement {
  #  sid = "pol-splunk-splunkconf-backup-${var.profile}-$(var.region-master}-${var.splunktargetenv}"
  #}
  description = "Allow to update dns records from ec2 instance at instance creation"
  provider    = aws.region-master
  policy      = data.template_file.pol-splunk-route53-updatednsrecords.rendered
}

data "template_file" "pol-splunk-smartstore" {
  template = file("policy-aws/pol-splunk-smartstore.json.tpl")

  vars = {
    s3_data         = aws_s3_bucket.s3_data.arn
    profile         = var.profile
    splunktargetenv = var.splunktargetenv
  }
}

resource "aws_iam_policy" "pol-splunk-smartstore" {
  # ... other configuration ...
  #statement {
  #  sid = "pol-splunk-smartstore-${var.profile}-$(var.region-master}-${var.splunktargetenv}"
  #}
  name_prefix = "splunkconf_s3_smartstore_"
  description = "Permissions needed for Splunk SmartStore"
  provider    = aws.region-master
  policy      = data.template_file.pol-splunk-smartstore.rendered
}

data "template_file" "pol-splunk-s3ia" {
  template = file("policy-aws/pol-splunk-s3ia.json.tpl")

  vars = {
    s3_ia         = aws_s3_bucket.s3_ia.arn
    s3_iaprefix     = var.s3_iaprefix
    profile         = var.profile
    splunktargetenv = var.splunktargetenv
  }
}

resource "aws_iam_policy" "pol-splunk-s3ia" {
  # ... other configuration ...
  #statement {
  #  sid = "pol-splunk-smartstore-${var.profile}-$(var.region-master}-${var.splunktargetenv}"
  #}
  name_prefix = "splunkconf_s3_ia_"
  description = "Permissions needed for Splunk S3 IA"
  provider    = aws.region-master
  policy      = data.template_file.pol-splunk-s3ia.rendered
}


