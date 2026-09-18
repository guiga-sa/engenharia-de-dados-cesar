# Os cinco outputs de contrato. O verifica.sh le estes nomes - nao os mude.

output "BucketName" {
  description = "Bucket do lake."
  value       = module.lake.bucket_name
}

output "DatabaseName" {
  description = "Database no Glue Data Catalog."
  value       = module.lake.database_name
}

output "TableName" {
  description = "Tabela declarada."
  value       = module.lake.table_name
}

output "WorkGroupName" {
  description = "Workgroup do Athena."
  value       = module.lake.workgroup_name
}

output "TetoBytes" {
  description = "Teto de bytes por consulta, da DECISAO 05."
  value       = module.lake.teto_bytes
}
