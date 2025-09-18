# Configuração prévia

---

**:warning: ATENÇÃO**: JAMAIS DISPONIBILIZE SUAS CHAVES PRIVADAS EM SERVIÇOS DA INTERNET.

---

## Certificados e cadastro no diretório central (SANDBOX)

Para ter permissão para acessar as APIs do Open Finance Brasil ou Open Insurance
Brasil, é necessário cadastrar no *Diretório de Participantes*:

1. A instituição receptora de dados (*Third Party Provider - TPP*).
2. A aplicação em si (*Software Statement Assertion - SSA*).
3. Seus certificados de segurança.

A seção inicial do
[Guia para TPP](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/240648607/PT+Guia+do+Usu+rio+para+Institui+es+Receptores+de+Dados+e+Iniciadores+de+Pagamento+TTP+PISP)
e o [Guia de Operação do Diretório Central](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17378602/Guia+de+Opera+o+do+Diret+rio+Central)
detalham os passos para executar o cadastro e gerar os certificados necessários
para **Open Finance Brasil**.

A seção inicial do
[Guia para TPP](https://br-openinsurance.github.io/areadesenvolvedor/#guia-do-usuario-para-instituicoes-receptores-de-dados)
e o [Guia de Operação do Diretório Central](https://br-openinsurance.github.io/areadesenvolvedor/#guia-de-operacao-do-diretorio-central)
detalham os passos para executar o cadastro e gerar os certificados necessários
para **Open Insurance**.

**ATENÇÃO**:

- **Não** é possível alterar as informações do Software Statement após visualizar
o Software Statement Assertion.
- Verifique todos os campos **múltiplas vezes** antes de concluir o cadastro,
em especial os endereços **`REDIRECT URI`**.

### Certificados TPP

As aplicações clientes (TPPs) necessitam 2 certificados distintos:

- **BRCAC (JWK: `"use": "enc"`):**
utilizado nas conexões mTLS para identificação da aplicação cliente e
criptografia da comunicação entre as partes.
- **BRSEAL (JWK: `"use": "sig"`):**
utilizado na *assinatura* de mensagens entre a aplicação TPP e o servidor
de autenticação e também de tokens JWS.

Após a geração dos certificados BRCAC e BRSEAL pode ser necessário convertê-los
em um JWKS para utilizar no programa de certificação da OpenID.

Para certificação da OpenID também será necessário uma chave de criptografia:

- **ID_TOKEN_ENC (JWK: `"use": "enc"`):** utilizado em testes de criptografia do
id_token

### Convertendo o certificado para JWK

**IMPORTANTE**: Jamais utilize serviços on-line para conversão de certificados,
pois isso pode resultar no comprometimento de suas chaves privadas.

Esta seção tem apresenta uma forma segura de conversão dos
certificados para o formato JWKS.

#### Pré-requisitos

- Node
- `npm install -g pem-jwk`

#### Passos

1. `openssl rsa -in certificado.key -out certificado-rsa.key`
2. `pem-jwk certificado-rsa.key > certificado-jwk.json`
3. Adicionar os atributos faltantes:
   - `"use": "<enc|sig>"` (depende to tipo do certificado: BRCAC=enc, BRSEAL=sig)
   - `"alg": "PS256"`
   - `"kid": "<kid>"`

O valor do atributo `kid` pode ser obtido no JWKS publicado no diretório central
que é o mesmo que o arquivo PEM gerado pelo diretório central.

#### Encapsulando em um JWKS

A estrutura de um arquivo JWKS é a seguinte, basta adicionar cada JWK no atributo
jwks do JSON.

```JSON
{
    "jwks": [ {
        <JWK-1>
    }, {
        <JWK-2>
    }]
}
```

### Links úteis

#### Verificando conteúdo do certificado cliente

Faça uma chamada para a URL <https://prod.idrix.eu/secure/>
utilizando o certificado desejado como certificado cliente para ver suas propriedades.

#### Gerando chaves JWKS para teste

O serviço <https://mkjwk.org/> realiza a geração de JWK de vários formatos
possíveis (útil para ambientes **não-produtivos**).

## Cadastro de um Software Statement no produto

Uma vez realizado o cadastro no Diretório Central,
é necessário inserir as informações do Software Statement
na base de dados do Opus Open Client:

```sql
INSERT INTO public.organisation(id_organisation, name)
VALUES('<código_de_participante>', '<razão_social>');

INSERT INTO public.software_statement
(id_software_statement, software_statement_client_id, ssa_data, proxy_url)
VALUES('<Software_Statement_ID_emitido_pelo_diretório>', '<client_id>', null, null);

INSERT INTO public.application
(id, id_organisation, id_software_statement, name, kid, kid_id_token_enc, fqdn, redirect_identifier)
VALUES('<id_application>', '<código_de_participante>',
'<Software_Statement_ID_emitido_pelo_diretório>', '<razão_social>', '<key_id>', '<key_id>',
'<fqdn>', '<redirect_identifier>');
```

- `id_organisation`: UUID - Código de Participante associado ao CNPJ listado no
Serviço de Diretório;
- `id_application`: UUID - Identificador gerado pela Instituição para o aplicativo;
- `name`: Nome da Razão Social;
- `id_software_statement`: UUID - Software Statement ID gerado pelo Diretório;
- `software_statement_client_id`: Identificador associado ao Código de Participante
e ao Software Statement ID;
- `proxy_url`: URL do proxy para redirecionamento de chamadas mTLS. **Opcional**.
  - *Se configurado*: o Opus Open Client redireciona todas as chamadas mTLS para
  a URL configurada.
  - *Se não configurado*: as chamadas mTLS são direcionadas diretamente para a
  instituição destino (comportamento padrão).
- `id`: UUID - identificador de um aplicativo relacionado a um Software Statement
Id;
- `kid`: Key ID, especifica a chave para a validação de assinaturas;
- `kid_id_token_enc`: Key ID, especifica a chave para a criptografia;
- `fqdn`: Fully qualified domain name utilizado pelo aplicativo para acessar as
APIs do produto. Configuração opcional. Caso não seja configurado, o redirecionamento
será feito utilizando a variável de ambiente `redirectUri` conforme
configuração de deploy;
- `redirect_identifier`: Identificador adicionado ao final da [URL de redirecionamento](../utilizacao/redirecionamento-app-to-app/readme.md)
para diferenciar múltiplos aplicativos com o mesmo `fqdn`. Não deve conter os
seguintes caracteres: `#`, `?` e `/`. Deve ser inserido se e somente se o campo
`fqdn` for configurado.

Exemplo:

```sql
INSERT INTO public.organisation(id_organisation, name)
VALUES('edd26f3e-888a-47f3-b599-f9c87fff3317', 'INSTITUICAO EXEMPLO');

INSERT INTO public.software_statement
(id_software_statement, software_statement_client_id, ssa_data, proxy_url)
VALUES('0e87dafd-2802-4aaf-ad55-f79f91bf7126', 'KEF5Jg2HD0Xn47k1oWC1r', null, null);

INSERT INTO public.application
(id, id_organisation, id_software_statement, name, kid, kid_id_token_enc)
VALUES('2f4473c9-aace-4fa5-9fb7-7dd4e03c09ea', 'edd26f3e-888a-47f3-b599-f9c87fff3317',
'0e87dafd-2802-4aaf-ad55-f79f91bf7126', 'APP Exemplo', 'uHh5XJkiF71orq05gfbaxJLZj6Aft8kDIZuYp4qgFs9','72f4111fa710e07dfc205f342a1c1bdd50d72179fb96a810e1176a57ee5ba43d');
```

## Arquivo de configuração

As variáveis são configuradas via helm como descritas no [deploy](../deploy/readme.md#privateKeys).

Exemplo de uma organização que possui duas marcas (aplicativos):

```yaml
env:
  privateKeys:
    - brSealSecretName: "oofc-tpp-keys"
      brSealSecretKey : "sig.key"
      brSealId : "edd26f3e-888a-47f3-b599-f9c87fff3317"
      softwareStatements:
        - brcacSecretName: "oofc-tpp-keys"
          brcacSecretKey: "enc.cert"
          brcacKeySecretName: "oofc-tpp-keys"
          brcacKeySecretKey: "enc.key"
          brIdTokenEncSecretName: "oofc-tpp-keys"
          brIdTokenEncSecretKey: "id_token_enc.key"
          softwareStatementId: "0e87dafd-2802-4aaf-ad55-f79f91bf7126"
          securityProfilePriority: "private_key_jwt_par,private_key_jwt,tls_client_auth,tls_client_auth_par"
        - brcacSecretName: "oofc-tpp2-keys"
          brcacSecretKey: "enc.cert"
          brcacKeySecretName: "oofc-tpp2-keys"
          brcacKeySecretKey: "enc.key"
          brIdTokenEncSecretName: "oofc-tpp2-keys"
          brIdTokenEncSecretKey: "id_token_enc.key"
          softwareStatementId: "2d8d14e8-16df-4274-84e9-00502c6b549c"
          securityProfilePriority: "private_key_jwt_par,private_key_jwt,tls_client_auth,tls_client_auth_par"
```
