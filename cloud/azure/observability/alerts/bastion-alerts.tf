# Bastion Alerts
# Azure Bastion monitoring and alerts

# Note: Azure Bastion metrics are limited. We monitor at the resource health level
# and through Log Analytics queries when enabled.

# =============================================================================
# Bastion Session Alerts (via Activity Log)
# =============================================================================

# Activity Log alerts for Bastion can be set up at the subscription level
# This is typically done through Azure Policy or manually in the portal

# For now, we document the recommended alerts:
# 1. Failed Bastion connections
# 2. Unusual number of Bastion sessions
# 3. Bastion host health changes
