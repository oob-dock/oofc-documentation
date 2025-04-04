# Permissões e agrupamentos

> Nota: as *Operações de crédito* referem-se às [modalidades de crédito](./modalidades-credito.md)
definidas pela documentação oficial.

| CATEGORIA DE DADOS | AGRUPAMENTO | PERMISSIONS |
|--------------------|-------------|-------------|
| Cadastro | Dados Cadastrais PF | CUSTOMERS_PERSONAL_IDENTIFICATIONS_READ<br>RESOURCES_READ |
| Cadastro | Informações complementares PF | CUSTOMERS_PERSONAL_ADITTIONALINFO_READ<br>RESOURCES_READ |
| Cadastro | Dados Cadastrais PJ | CUSTOMERS_BUSINESS_IDENTIFICATIONS_READ<br>RESOURCES_READ |
| Cadastro | Informações complementares PJ | CUSTOMERS_BUSINESS_ADITTIONALINFO_READ<br>RESOURCES_READ |
| Contas | Saldos | ACCOUNTS_READ<br>ACCOUNTS_BALANCES_READ<br>RESOURCES_READ |
| Contas | Limites | ACCOUNTS_READ<br>ACCOUNTS_OVERDRAFT_LIMITS_READ<br>RESOURCES_READ |
| Contas | Extratos | ACCOUNTS_READ<br>ACCOUNTS_TRANSACTIONS_READ<br>RESOURCES_READ |
| Cartão de Crédito | Limites | CREDIT_CARDS_ACCOUNTS_READ<br>CREDIT_CARDS_ACCOUNTS_LIMITS_READ<br>RESOURCES_READ |
| Cartão de Crédito | Transações | CREDIT_CARDS_ACCOUNTS_READ<br>CREDIT_CARDS_ACCOUNTS_TRANSACTIONS_READ<br>RESOURCES_READ |
| Cartão de Crédito | Faturas | CREDIT_CARDS_ACCOUNTS_READ<br>CREDIT_CARDS_ACCOUNTS_BILLS_READ<br>CREDIT_CARDS_ACCOUNTS_BILLS_TRANSACTIONS_READ<br>RESOURCES_READ |
| Operações de Crédito | Dados do Contrato | LOANS_READ<br>LOANS_WARRANTIES_READ<br>LOANS_SCHEDULED_INSTALMENTS_READ<br>LOANS_PAYMENTS_READ<br>FINANCINGS_READ<br>FINANCINGS_WARRANTIES_READ<br>FINANCINGS_SCHEDULED_INSTALMENTS_READ<br>FINANCINGS_PAYMENTS_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_WARRANTIES_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_SCHEDULED_INSTALMENTS_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_PAYMENTS_READ<br>INVOICE_FINANCINGS_READ<br>INVOICE_FINANCINGS_WARRANTIES_READ<br>INVOICE_FINANCINGS_SCHEDULED_INSTALMENTS_READ<br>INVOICE_FINANCINGS_PAYMENTS_READ<br>RESOURCES_READ |
| Operações de Crédito | Empréstimos | LOANS_READ<br>LOANS_WARRANTIES_READ<br>LOANS_SCHEDULED_INSTALMENTS_READ<br>LOANS_PAYMENTS_READ<br>RESOURCES_READ |
| Operações de Crédito | Financiamentos | FINANCINGS_READ<br>FINANCINGS_WARRANTIES_READ<br>FINANCINGS_SCHEDULED_INSTALMENTS_READ<br>FINANCINGS_PAYMENTS_READ<br>RESOURCES_READ |
| Operações de Crédito | Adiantamento a depositantes | UNARRANGED_ACCOUNTS_OVERDRAFT_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_WARRANTIES_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_SCHEDULED_INSTALMENTS_READ<br>UNARRANGED_ACCOUNTS_OVERDRAFT_PAYMENTS_READ<br>RESOURCES_READ |
| Operações de Crédito | Direitos creditórios descontados | INVOICE_FINANCINGS_READ<br>INVOICE_FINANCINGS_WARRANTIES_READ<br>INVOICE_FINANCINGS_SCHEDULED_INSTALMENTS_READ<br>INVOICE_FINANCINGS_PAYMENTS_READ<br>RESOURCES_READ |
| Investimento | Dados da Operação | BANK_FIXED_INCOMES_READ<br>CREDIT_FIXED_INCOMES_READ<br>FUNDS_READ<br>VARIABLE_INCOMES_READ<br>TREASURE_TITLES_READ<br>RESOURCES_READ |
| Câmbio       | Dados da Operação | EXCHANGES_READ<br>RESOURCES_READ |
