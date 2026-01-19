# Coder 模板：JDK17 + Maven + Git + Code Server + JetBrains

这个模板基于 Coder 官方模块，默认提供：
- 8 核 CPU、16GB 内存的资源限制（Docker 容器）
- 预装 git / maven / jdk17
- 预装 Docker（容器内独立 dockerd，不挂宿主机 /var/run/docker.sock）
- 官方 code-server 模块
- 官方 JetBrains 模块（用于 JetBrains Gateway/IDE 连接）

## 目录结构
- `main.tf` / `variables.tf`: Coder 模板定义
- `build/Dockerfile`: 工作区镜像，内置 git、maven、jdk17
- `scripts/package-template.sh`: 打包模板为上传用压缩包

## 使用方式
1. 在 Coder 中创建模板时选择此目录。
2. 需要 Docker provider 支持（此模板使用 Docker 运行工作区）。

## 资源规格
默认：
- `cpu_cores = 8`
- `memory_gb = 16`

可在创建模板/工作区时修改变量。

## 打包脚本
在本地执行：
```bash
./scripts/package-template.sh
```
输出压缩包路径示例：
```
./dist/code-idea-jdk17-template.zip
```

注意：Coder 读取模板时要求 `.tf` 文件在压缩包根目录；脚本会生成满足该要求的结构。

## 说明
- code-server 与 JetBrains 均使用官方 registry 模块。
- 如需使用其它基础镜像或添加工具，可修改 `build/Dockerfile`。
