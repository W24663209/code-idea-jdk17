terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

locals {
  home_dir     = "/home/coder"
  project_dir  = "/home/coder/project"
  cpu_period   = 100000
  cpu_quota    = var.cpu_cores * local.cpu_period
  memory_bytes = var.memory_gb * 1024 * 1024 * 1024
}

resource "coder_agent" "main" {
  arch = "amd64"
  os   = "linux"
  dir  = local.home_dir

  startup_script = <<-EOT
    #!/bin/sh
    set -e
    mkdir -p ${local.project_dir}
  EOT
}

module "code-server" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/code-server/coder"
  version  = "~> 1.0"
  agent_id = coder_agent.main.id
}

module "jetbrains" {
  count    = data.coder_workspace.me.start_count
  source   = "registry.coder.com/coder/jetbrains/coder"
  version  = "~> 1.0"
  agent_id = coder_agent.main.id
  folder   = local.project_dir
}

resource "docker_volume" "home_volume" {
  name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}-home"
}

resource "docker_image" "main" {
  name = "coder-${data.coder_workspace.me.id}"

  build {
    context = "./build"
  }

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "build/*") : filesha1("${path.module}/${f}")]))
  }
}

resource "docker_container" "workspace" {
  count    = data.coder_workspace.me.start_count
  image    = docker_image.main.name
  name     = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  hostname = data.coder_workspace.me.name

  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "localhost|127\\.0\\.0\\.1", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = local.home_dir
    volume_name    = docker_volume.home_volume.name
    read_only      = false
  }

  cpu_period  = local.cpu_period
  cpu_quota   = local.cpu_quota
  memory      = local.memory_bytes
  memory_swap = local.memory_bytes
}

resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = docker_container.workspace[0].id

  item {
    key   = "cpu"
    value = "${var.cpu_cores} cores"
  }

  item {
    key   = "memory"
    value = "${var.memory_gb} GB"
  }

  item {
    key   = "java"
    value = "JDK 17"
  }

  item {
    key   = "tools"
    value = "git, maven"
  }
}
