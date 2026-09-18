output "bucket_name" {
  description = "Bucket do lake."
  value       = aws_s3_bucket.lake.bucket
}

output "database_name" {
  description = "Database no Glue Data Catalog."
  value       = aws_glue_catalog_database.db.name
}

output "table_name" {
  description = "Tabela declarada."
  value       = aws_glue_catalog_table.corridas.name
}

output "workgroup_name" {
  description = "Workgroup do Athena."
  value       = aws_athena_workgroup.wg.name
}

output "teto_bytes" {
  description = "Teto de bytes por consulta, da DECISAO 05."
  value       = var.teto_bytes
}
