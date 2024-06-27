# Redirecionamento App-to-App no fluxo de autorização de consentimentos

Conforme [definido pelo Open Finance Brasil](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17378415/Redirecionamento+App-to-App)
a comunicação entre o aplicativo da Instituição Receptora e o aplicativo da
Instituição Transmissora deve ser realizada de maneira direta, não devendo
envolver nenhuma etapa adicional - como redirecionamentos intermediários para
páginas web para que ocorra seleção de qual aplicativo da transmissora usar.

## Android App Links e Universal Links

Diante do cenário apresentado, o aplicativo da Instituição Receptora precisa
interceptar o retorno das chamadas de autorização de consentimentos de
compartilhamento de dados e pagamentos (exclusivo ao Opus Open Finance Client)
realizadas junto ao aplicativo da Instituição Transmissora.

Há dois padrões de URLs que precisam ser interceptadas para o Opus Open Finance
Client (OOFC) e um padrão para o Opus Open Insurance Client (OOIC), vide tabela
abaixo:

| Descrição                                                                            | URL                                                                                                                                          |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| URL de redirecionamento de autorização de consentimento de compartilhamento de dados | OOFC: `https://<OOC-FQDN>/opus-open-finance/consents/redirect-uri` </br>OOIC: `https://<OOC-FQDN>/opus-open-insurance/consents/redirect-uri` |
| URL de redirecionamento de autorização de consentimento de pagamentos                | OOFC: `https://<OOC-FQDN>/opus-open-finance/payments/redirect-uri`                                                                           |

**Observação importante:** O <OOC-FQDN> utilizado pelo aplicativo para acessar as
APIs do Opus Open Client deve estar corretamente configurado na `application` correspondente,
conforme descrito na [configuração do produto](../../configuracao%20do%20produto/readme.md).

Além de configurar o aplicativo para interceptar as URLs descritas acima, é
necessário também configurar corretamente os arquivos *Asset Links* (Android) e
o *Apple App Site Association File* (iOS). Estes dois arquivos podem ser
configurados via variável de ambiente, e os detalhes para esta configuração
estão disponíveis nas páginas de documentação do deploy para o [OOFC](../../deploy/oofc-core/readme.md)
e para o [OOIC](../../deploy/ooic-core/readme.md).

Após configuração das variáveis, as rotas que retornarão os arquivos são:

* Android: `GET https://<OOC-FQDN>/.well-known/assetlinks.json`.
* iOS: `GET https://<OOC-FQDN>/.well-known/apple-app-site-association`.

## O que fazer ao interceptar uma URL?

Ao interceptar alguma das URLs acima o aplicativo irá notar que a URL
interceptada conterá uma *query string* (caso logo após `redirect-uri`
estiver presente um `?`) ou um *fragment* (caso logo após `redirect-uri`
estiver presente um `#`). A *query string* ou *fragment* retornados são o
resultado do fluxo OIDC realizado junto ao aplicativo da Instituição
Transmissora. A Instituição Receptora então deverá extrair a informação
presente na URL *as-is* (começando logo após o `?` ou `#`) e enviá-la de volta
ao Opus Open Client para que haja troca do *authorization code* retornado pelos
*tokens* ou para que o tratamento de eventuais erros aconteça.

Detalhes da API que deve ser chamada para o envio do retorno do fluxo OIDC
podem ser conferidos abaixo:

* Verbo: `POST`
* URL:
    * OOFC: `https://<OOC-FQDN>/opus-open-finance/authorization-result`
    * OOIC: `https://<OOC-FQDN>/opus-open-insurance/authorization-result`
* Payload:

  ```JSON
  {
    "data": "<query string ou fragment extraídos da URL>"
  }
  ```

* Retornos possíveis:
  * `204 No content`: Neste caso a autorização do consentimento foi bem
    sucedida e o aplicativo da Receptora pode prosseguir com o fluxo normal.
  * `422 Unprocessable Entity`: A autorização não foi bem sucedida. Dois campos
    voltarão neste caso: `error` e `error_description`. Eles conterão o tipo e
    motivo do erro ocorrido.

**Observação importante:** Recomendamos que a chamada ao endpoint `/authorization-result`
ocorra tão logo o aplicativo intercepte a URL de redirecionamento, antes mesmo
de exigir a autenticação de seu próprio correntista. Essa recomendação é
baseada no fato de que o *authorization code* retornado pelo fluxo OIDC possui
um TTL definido pelo AS da Instituição Transmissora que pode ser muito pequeno.

## Suporte a múltiplos aplicativos

Caso a Instituição Receptora possua mais de um aplicativo vinculado ao produto,
é fundamental assegurar que um usuário siga no mesmo aplicativo em que iniciou o
consentimento após finalizar o fluxo de aprovação na Instituição Transmissora.

Para realizar essa configuração, a instituição deverá ajustar cada um de seus aplicativos
para interceptar exclusivamente a URI com o `FQDN` correspondente ao registrado no
campo `application`, levando também em consideração o `redirect_identifier` associado.
Por exemplo, se a instituição possuir dois aplicativos registrados no Opus Open Client
com os `redirect_identifiers` *id-app-a* e *id-app-b*, juntamente com os FQDNs *ooc-appA.instituicao.com.br*
e *ooc-appB.instituicao.com.br*, respectivamente, os aplicativos devem estar configurados
para interceptar as URIs de acordo com as instruções fornecidas na tabela a seguir:

| Produto                                    | Aplicativo | URIs                                                                                   |
| ------------------------------------------ | ---------- | -------------------------------------------------------------------------------------- |
| Open Finance - Compartilhamento de Dados   | id-app-a   | https://ooc-appA.instituicao.com.br/opus-open-finance/consents/redirect-uri/id-app-a   |
| Open Finance - Pagamento                   | id-app-a   | https://ooc-appA.instituicao.com.br/opus-open-finance/consents/redirect-uri/id-app-a   |
| Open Insurance - Compartilhamento de Dados | id-app-a   | https://ooc-appA.instituicao.com.br/opus-open-insurance/consents/redirect-uri/id-app-a |
| Open Finance - Compartilhamento de Dados   | id-app-b   | https://ooc-appB.instituicao.com.br/opus-open-finance/consents/redirect-uri/id-app-b   |
| Open Finance - Pagamento                   | id-app-b   | https://ooc-appB.instituicao.com.br/opus-open-finance/consents/redirect-uri/id-app-b   |
| Open Insurance - Compartilhamento de Dados | id-app-b   | https://ooc-appB.instituicao.com.br/opus-open-insurance/consents/redirect-uri/id-app-b |

Note que o identificador de redirecionamento é adicionado ao final da URI.

**Observação importante:** Todas as URIs de redirecionamento utilizadas pela instituição
devem ser obrigatoriamente registradas ao seu Software Statement do diretório de
participantes.
