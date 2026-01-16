#!/usr/bin/env bash
set -euo pipefail

NAME="${NAME:-tgstate}"
VOL="${VOL:-tgstate-data}"
REPO="ghcr.io/buyi06/tgstate-python"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker 未安装或不可用" >&2
  exit 1
fi

docker rm -f "${NAME}" >/dev/null 2>&1 || true
docker volume rm "${VOL}" >/dev/null 2>&1 || true

IDS="$(
  docker images --format '{{.Repository}} {{.ID}}' \
    | awk -v repo="$REPO" '$1==repo{print $2}' \
    | sort -u
)"

if [[ -n "${IDS}" ]]; then
  echo "${IDS}" | xargs -r docker rmi -f >/dev/null 2>&1 || true
fi

echo "已清理：容器=${NAME} 数据卷=${VOL} 镜像仓库=${REPO}"

