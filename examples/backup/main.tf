module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "bkup"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "swedencentral"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "netapp" {
  source  = "codectl/anf/azure"
  version = "~> 1.0"

  netapp = {
    name                = module.naming.netapp_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "pools" {
  source  = "codectl/anf/azure//modules/pools"
  version = "~> 1.0"

  account_name        = module.netapp.account.name
  resource_group_name = module.netapp.account.resource_group_name
  location            = module.netapp.account.location

  netapp = {
    backup_vaults = {
      vault-demo = {
        backup_policies = {
          policy-daily = {
            daily_backups_to_keep   = 7
            weekly_backups_to_keep  = 4
            monthly_backups_to_keep = 3
          }
        }
      }
    }
  }
}
