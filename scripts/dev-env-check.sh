#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/4] Java runtime:"
java -version
echo

echo "[2/4] Maven runtime:"
mvn -version
echo

echo "[3/4] Installed JDKs:"
JDK_LIST="$(
  /usr/libexec/java_home -V 2>&1 || true
)"
echo "${JDK_LIST}"
echo

if echo "${JDK_LIST}" | grep -Eq '^[[:space:]]*21\.' || [ -x "/usr/local/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java" ]; then
  echo "[info] JDK 21 detected."
else
  echo "[warn] JDK 21 not detected. Current projects target Java 21."
  echo "[warn] You can still compile with JDK 25 locally, but align CI/server to Java 21."
fi
echo

echo "[4/4] Maven compile check:"
cd "${ROOT_DIR}"
mvn -q -DskipTests compile
echo "[ok] Workspace compile passed."
