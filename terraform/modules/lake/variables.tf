variable "sufixo" {
  type        = string
  description = "Sufixo dos nomes de recurso (login do aluno)."
}

variable "teto_bytes" {
  type        = number
  description = "DECISAO 05. Bytes que uma consulta pode varrer antes de o Athena aborta-la."
}
