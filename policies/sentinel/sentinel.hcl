# Sentinel Policy Configuration

policy "require-tags" {
  source            = "./require-tags.sentinel"
  enforcement_level = "hard-mandatory"
}

# Add more policies as needed:
# policy "restrict-instance-types" {
#   source            = "./restrict-instance-types.sentinel"
#   enforcement_level = "soft-mandatory"
# }
