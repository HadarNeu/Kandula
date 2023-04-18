#########For future work: Create eks tags after the creation of resources############
# resource "aws_ec2_tag" "example" {
#   for_each = { "Name" : "MyAttachment", "Owner" : "Operations" }

#   resource_id = aws_vpn_connection.example.transit_gateway_attachment_id
#   key         = each.key
#   value       = each.value
# }