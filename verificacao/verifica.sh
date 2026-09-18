#!/usr/bin/env bash
# Verificacao do Exercicio 03 - modulo lake + contrato de outputs.
# Rode a partir de verificacao/: ./verifica.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT/terraform"
PASS=0
FAIL=0

ok()   { echo "[OK]    $*"; PASS=$((PASS + 1)); }
fail() { echo "[FALHA] $*"; FAIL=$((FAIL + 1)); }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Comando obrigatorio ausente: $1"; exit 1; }
}

need_cmd terraform
need_cmd aws
need_cmd jq

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "=== Exercicio 03 — verificacao ==="
echo "Terraform dir: $TF_DIR"
echo

# --- Critério 1: estrutura do modulo ---
if [[ -f "$TF_DIR/modules/lake/main.tf" \
   && -f "$TF_DIR/modules/lake/variables.tf" \
   && -f "$TF_DIR/modules/lake/outputs.tf" ]]; then
  ok "Estrutura modules/lake (main, variables, outputs)"
else
  fail "Estrutura modules/lake incompleta"
fi

# --- Critério 2: chamada module "lake" ---
if grep -qE 'module\s+"lake"' "$TF_DIR/main.tf"; then
  ok 'main.tf instancia module "lake"'
else
  fail 'main.tf nao instancia module "lake"'
fi

# --- Critério 3: backend s3 ---
if grep -qE 'backend\s+"s3"\s*\{\s*\}' "$TF_DIR/main.tf" \
   || grep -qE 'backend\s+"s3"' "$TF_DIR"/*.tf 2>/dev/null; then
  ok 'backend "s3" {} presente'
else
  fail 'backend "s3" {} ausente'
fi

# --- Critério 4: REGRA DE OURO — identificadores no modulo ---
for res in \
  'resource "aws_s3_bucket" "lake"' \
  'resource "aws_s3_bucket_public_access_block" "lake"' \
  'resource "aws_s3_bucket" "results"' \
  'resource "aws_glue_catalog_database" "db"' \
  'resource "aws_glue_catalog_table" "corridas"' \
  'resource "aws_athena_workgroup" "wg"'
do
  if grep -Fq "$res" "$TF_DIR/modules/lake/main.tf"; then
    ok "Identificador preservado: $res"
  else
    fail "Identificador ausente/alterado: $res"
  fi
done

# --- Critério 5: state sob module.lake ---
cd "$TF_DIR"
STATE_LIST="$(terraform state list 2>/dev/null || true)"
EXPECTED_STATE=(
  module.lake.aws_s3_bucket.lake
  module.lake.aws_s3_bucket_public_access_block.lake
  module.lake.aws_s3_bucket.results
  module.lake.aws_glue_catalog_database.db
  module.lake.aws_glue_catalog_table.corridas
  module.lake.aws_athena_workgroup.wg
)
for addr in "${EXPECTED_STATE[@]}"; do
  if echo "$STATE_LIST" | grep -qx "$addr"; then
    ok "State contem $addr"
  else
    fail "State nao contem $addr (rode os state mv)"
  fi
done

# --- Critério 6: outputs de contrato (PascalCase) ---
OUT_JSON="$(terraform output -json 2>/dev/null || echo '{}')"
for key in BucketName DatabaseName TableName WorkGroupName TetoBytes; do
  val="$(echo "$OUT_JSON" | jq -r --arg k "$key" '.[$k].value // empty')"
  if [[ -n "$val" && "$val" != "null" ]]; then
    ok "Output $key = $val"
  else
    fail "Output de contrato ausente: $key"
  fi
done

BUCKET="$(echo "$OUT_JSON" | jq -r '.BucketName.value // empty')"
DB="$(echo "$OUT_JSON" | jq -r '.DatabaseName.value // empty')"
TABLE="$(echo "$OUT_JSON" | jq -r '.TableName.value // empty')"
WG="$(echo "$OUT_JSON" | jq -r '.WorkGroupName.value // empty')"
TETO="$(echo "$OUT_JSON" | jq -r '.TetoBytes.value // empty')"

# --- Critério 7: recursos existem na AWS ---
if [[ -n "$BUCKET" ]] && aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  ok "S3 lake existe: $BUCKET"
else
  fail "S3 lake inacessivel: $BUCKET"
fi

if [[ -n "$DB" ]] && aws glue get-database --name "$DB" >/dev/null 2>&1; then
  ok "Glue database existe: $DB"
else
  fail "Glue database inacessivel: $DB"
fi

if [[ -n "$DB" && -n "$TABLE" ]] \
  && aws glue get-table --database-name "$DB" --name "$TABLE" >/dev/null 2>&1; then
  ok "Glue table existe: $DB.$TABLE"
else
  fail "Glue table inacessivel: $DB.$TABLE"
fi

if [[ -n "$WG" ]] && aws athena get-work-group --work-group "$WG" >/dev/null 2>&1; then
  ok "Athena workgroup existe: $WG"
else
  fail "Athena workgroup inacessivel: $WG"
fi

if [[ -n "$TETO" && "$TETO" -ge 10485760 ]]; then
  CUTOFF="$(aws athena get-work-group --work-group "$WG" \
    --query 'WorkGroup.Configuration.BytesScannedCutoffPerQuery' --output text 2>/dev/null || echo "")"
  if [[ "$CUTOFF" == "$TETO" ]]; then
    ok "TetoBytes alinhado no workgroup: $TETO"
  else
    fail "TetoBytes divergente (output=$TETO, aws=$CUTOFF)"
  fi
else
  fail "TetoBytes invalido: $TETO"
fi

# --- Critério 8: plan limpo ---
PLAN_OUT="$(terraform plan -var="sufixo=${SUFIXO:-gsa3}" -no-color 2>&1 || true)"
if echo "$PLAN_OUT" | grep -q "No changes. Your infrastructure matches the configuration."; then
  ok "terraform plan limpo (No changes)"
else
  fail "terraform plan nao esta limpo"
  echo "$PLAN_OUT" | tail -20
fi

echo
echo "=== Resultado: $PASS ok, $FAIL falha(s) ==="
if [[ "$FAIL" -eq 0 ]]; then
  echo "STATUS: APROVADO"
  exit 0
fi
echo "STATUS: REPROVADO"
exit 1
