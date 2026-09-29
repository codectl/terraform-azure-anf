module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "snap"]
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

    snapshot_policies = {
      policy-daily = {
        enabled = true

        daily_schedule = {
          hour              = 2
          minute            = 0
          snapshots_to_keep = 7
        }
      }
      policy-weekly = {
        enabled = true

        weekly_schedule = {
          days_of_week      = ["Monday"]
          hour              = 3
          minute            = 0
          snapshots_to_keep = 4
        }
      }
    }
  }
}
