# 1 - O lake (dados brutos).
resource "aws_s3_bucket" "lake" {
  bucket        = "eda-a04-lake-${var.sufixo}"
  force_destroy = true

  tags = {
    Disciplina = "EDA"
    Aula       = "04"
    Turma      = "2026-2"
    Owner      = "gsa3@cesar.school"
  }
}

resource "aws_s3_bucket_public_access_block" "lake" {
  bucket = aws_s3_bucket.lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2 - Bucket de resultados do Athena.
resource "aws_s3_bucket" "results" {
  bucket        = "eda-a04-results-${var.sufixo}"
  force_destroy = true

  tags = {
    Disciplina = "EDA"
    Aula       = "04"
    Turma      = "2026-2"
    Owner      = "gsa3@cesar.school"
  }
}

# 3 - Database no Glue Data Catalog.
resource "aws_glue_catalog_database" "db" {
  name        = "eda_a04_raw_${var.sufixo}"
  description = "Camada raw do exercicio - schema declarado, sem Crawler."
}

# 4 - Tabela corridas (schema declarado).
resource "aws_glue_catalog_table" "corridas" {
  name          = "corridas"
  database_name = aws_glue_catalog_database.db.name
  description   = "Eventos de corrida como chegaram, um JSON por linha."
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification       = "json"
    "projection.enabled" = "false"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lake.bucket}/raw/corridas/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        # DECISAO 03 - barulho ou silencio.
        "ignore.malformed.json" = "false"
      }
    }

    columns {
      name = "corrida_id"
      type = "string"
    }
    columns {
      name = "motorista_id"
      type = "string"
    }
    columns {
      name = "passageiro_id"
      type = "string"
    }
    columns {
      name = "bairro"
      type = "string"
    }
    # DECISAO 02 - tipo das colunas de tempo.
    columns {
      name = "data_corrida"
      type = "string"
    }
    columns {
      name = "fim"
      type = "string"
    }
    columns {
      name = "distancia_km"
      type = "double"
    }
    columns {
      name = "duracao_min"
      type = "double"
    }
    # DECISAO 01 - tipo de valor.
    columns {
      name = "valor"
      type = "string"
    }
  }

  partition_keys {
    name = "dt"
    type = "string"
  }
}

# 5 - Workgroup do Athena com teto de bytes.
resource "aws_athena_workgroup" "wg" {
  name          = "eda-a04-wg-${var.sufixo}"
  description   = "Workgroup do exercicio - teto calculado, nao presenteado."
  state         = "ENABLED"
  force_destroy = true

  configuration {
    bytes_scanned_cutoff_per_query     = var.teto_bytes
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.results.bucket}/"
    }
  }

  tags = {
    Disciplina = "EDA"
    Aula       = "04"
    Turma      = "2026-2"
    Owner      = "gsa3@cesar.school"
  }
}
