##
## locals
##
#
## current
#locals {
#  env_vpc_cidr = local.vpc_cidr_split[local.env]
#  vpc_newbits  = local.env_vpc_cidr["newbits"]
#  vpc_netnum   = local.env_vpc_cidr["netnum"]
#  cidr_block   = cidrsubnet(local.service_cidr, local.vpc_newbits, local.vpc_netnum)
#}
#
#locals {
#  env_subnet_cidr   = local.subnet_cidr_split[local.env]
#  subnet_cidr_aznum = local.env_subnet_cidr["aznum"]
#}
#
## system
#locals {
#  system_vpc_cidr = local.vpc_cidr_split["system"]
#  system_newbits  = local.system_vpc_cidr["newbits"]
#  system_netnum   = local.system_vpc_cidr["netnum"]
#  system_cidr_block = cidrsubnet(
#    local.service_cidr,
#    local.system_newbits,
#    local.system_netnum,
#  )
#}
#
#locals {
#  system_subnet_cidr       = local.subnet_cidr_split["system"]
#  system_subnet_cidr_aznum = local.system_subnet_cidr["aznum"]
#}
#
#locals {
#  vpc_flow_log_group_prefix = "/vpc/flow-log/"
#  vpc_flow_log_log_group    = "${local.vpc_flow_log_group_prefix}${local.service_name}-${local.env}"
#  vpc_flow_log_traffic_type = "REJECT"
#}
#
##
## VPC
##
#
#data "aws_availability_zones" "available" {
#}
#
#resource "aws_vpc" "default" {
#  count = local.on_network ? 1 : 0
#
#  cidr_block = local.cidr_block
#
#  enable_dns_support   = true
#  enable_dns_hostnames = true
#
#  tags = {
#    "Name"    = format("%s %s", local.service_name, local.env)
#    "service" = local.service_name
#    "env"     = local.env
#  }
#
#  lifecycle {
#    ignore_changes = [tags]
#  }
#}
#
#resource "aws_cloudwatch_log_group" "vpc-flow-log" {
#  count = local.on_network ? 1 : 0
#
#  name = local.vpc_flow_log_log_group
#  retention_in_days = 7
#}
#
#resource "aws_flow_log" "default" {
#  count = local.on_network ? 1 : 0
#
#  vpc_id               = aws_vpc.default[0].id
#  iam_role_arn         = data.terraform_remote_state.common.outputs.aws_iam_role_vpc_flow_log_arn
#  log_destination_type = "cloud-watch-logs"
#  log_destination      = aws_cloudwatch_log_group.vpc-flow-log[0].arn
#  traffic_type         = local.vpc_flow_log_traffic_type
#}
#
#resource "aws_internet_gateway" "default" {
#  count = local.on_network ? 1 : 0
#
#  vpc_id = aws_vpc.default[0].id
#
#  tags = {
#    Name = format("%s %s", local.service_name, local.env)
#  }
#}
#
#resource "aws_eip" "nat" {
#  count = local.on_system ? 1 : 0
#
#  vpc = true
#}
#
#resource "aws_nat_gateway" "default" {
#  count = local.on_system ? 1 : 0
#
#  allocation_id = aws_eip.nat[0].id
#  subnet_id     = aws_subnet.public[0].id
#}
#
##
## Subnet
##
#
#resource "aws_subnet" "public" {
#  count = local.on_network ? local.subnet_cidr_aznum : 0
#
#  vpc_id            = aws_vpc.default[0].id
#  availability_zone = data.aws_availability_zones.available.names[count.index]
#  cidr_block = cidrsubnet(
#    local.service_cidr,
#    local.env_subnet_cidr["newbits"],
#    local.env_subnet_cidr["start_netnum"] + 2 * count.index,
#  )
#  map_public_ip_on_launch = true
#
#  tags = {
#    "Name" = format(
#      "%s %s Public %s",
#      local.service_name,
#      local.env,
#      data.aws_availability_zones.available.names[count.index],
#    )
#    "service" = local.service_name
#    "env"     = local.env
#  }
#
#  lifecycle {
#    ignore_changes = [tags]
#  }
#}
#
#resource "aws_subnet" "private" {
#  count = local.on_network ? local.subnet_cidr_aznum : 0
#
#  vpc_id            = aws_vpc.default[0].id
#  availability_zone = data.aws_availability_zones.available.names[count.index]
#  cidr_block = cidrsubnet(
#    local.service_cidr,
#    local.env_subnet_cidr["newbits"],
#    local.env_subnet_cidr["start_netnum"] + 2 * count.index + 1,
#  )
#  map_public_ip_on_launch = false
#
#  tags = {
#    "Name" = format(
#      "%s %s Private %s",
#      local.service_name,
#      local.env,
#      data.aws_availability_zones.available.names[count.index],
#    )
#    "service" = local.service_name
#    "env"     = local.env
#  }
#
#  lifecycle {
#    ignore_changes = [tags]
#  }
#}
#
##
## Route
##
#
#resource "aws_route_table" "public" {
#  count = local.on_network ? 1 : 0
#
#  vpc_id = aws_vpc.default[0].id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.default[0].id
#  }
#
#  tags = {
#    Name    = format("%s %s Public", local.service_name, local.env)
#    service = local.service_name
#    env     = local.env
#  }
#}
#
#resource "aws_route_table" "private" {
#  count = local.on_service ? 1 : 0
#
#  vpc_id = aws_vpc.default[0].id
#
#  lifecycle {
#    ignore_changes = [route]
#  }
#
#  tags = {
#    Name    = format("%s %s Private", local.service_name, local.env)
#    service = local.service_name
#    env     = local.env
#  }
#}
#
#resource "aws_route_table" "private_nat" {
#  count = local.on_system ? 1 : 0
#
#  vpc_id = aws_vpc.default[0].id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_nat_gateway.default[0].id
#  }
#
#  lifecycle {
#    ignore_changes = [route]
#  }
#
#  tags = {
#    Name    = format("%s %s Private NAT", local.service_name, local.env)
#    service = local.service_name
#    env     = local.env
#  }
#}
#
#resource "aws_route" "private_nat" {
#  count = local.on_service ? 1 : 0
#
#  route_table_id            = data.terraform_remote_state.system.outputs.aws_route_table_private_nat_id
#  destination_cidr_block    = local.cidr_block
#  vpc_peering_connection_id = aws_vpc_peering_connection.system[0].id
#}
#
#resource "aws_route_table_association" "public" {
#  count = local.on_network ? local.subnet_cidr_aznum : 0
#
#  subnet_id      = element(aws_subnet.public.*.id, count.index)
#  route_table_id = aws_route_table.public[0].id
#}
#
#resource "aws_route_table_association" "private" {
#  count = local.on_service ? local.subnet_cidr_aznum : 0
#
#  subnet_id      = element(aws_subnet.private.*.id, count.index)
#  route_table_id = aws_route_table.private[0].id
#}
#
#resource "aws_route_table_association" "private_nat" {
#  count = local.on_system ? local.subnet_cidr_aznum : 0
#
#  subnet_id      = element(aws_subnet.private.*.id, count.index)
#  route_table_id = aws_route_table.private_nat[0].id
#}
#
##
## service <=peer=> system
##
#
#resource "aws_vpc_peering_connection" "system" {
#  count = local.on_service ? 1 : 0
#
#  vpc_id      = aws_vpc.default[0].id
#  peer_vpc_id = data.terraform_remote_state.system.outputs.aws_vpc_default_id
#
#  auto_accept = true
#
#  tags = {
#    Name = format("%s %s to self system", local.service_name, local.env)
#  }
#}