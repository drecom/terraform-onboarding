
locals {
  ec2_enabled_env = {
    production = false
  }
  on_ec2 = lookup(local.ec2_enabled_env, local.env, false)
}