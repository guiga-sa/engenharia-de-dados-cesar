variable "aws_region" {
  type        = string
  description = "Regiao AWS do deploy."
  default     = "us-east-1"
}

variable "sufixo" {
  type        = string
  description = "Sufixo dos nomes de recurso (login do aluno)."
}

variable "teto_bytes" {
  type        = number
  description = "DECISAO 05. Bytes que uma consulta pode varrer antes de o Athena aborta-la."
  default     = 11000000
}
