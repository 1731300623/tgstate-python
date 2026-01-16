#!/usr/bin/env bash
set -euo pipefail

IMG="ghcr.io/buyi06/tgstate-python@sha256:e897ce4c2b61e48a13ef0ec025dfd80148ed8669d75f688a1a8d81036fe116e5"

NAME="${NAME:-tgstate}"
PORT="${PORT:-15767}"
VOL="${VOL:-tgstate-data}"
BASE_URL="${BASE_URL:-}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker 未安装或不可用" >&2
  exit 1
fi

echo "警告：reset 将删除数据卷 ${VOL}，所有数据将被清空且不可逆"

if [[ -z "${BASE_URL}" ]]; then
  IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
  if [[ -z "${IP}" ]]; then
    IP="127.0.0.1"
  fi
  BASE_URL="http://${IP}:${PORT}"
fi

docker rm -f "${NAME}" >/dev/null 2>&1 || true
docker volume rm "${VOL}" >/dev/null 2>&1 || true
docker volume create "${VOL}" >/dev/null
docker pull "${IMG}"

docker run -d \
  --name "${NAME}" \
  --restart unless-stopped \
  -p "${PORT}:8000" \
  -v "${VOL}:/app/data" \
  -e "BASE_URL=${BASE_URL}" \
  "${IMG}" >/dev/null

echo "tgState 已重装并启动"
echo "访问地址：${BASE_URL}"

