# evolution-api-heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://dashboard.heroku.com/new?template=https://github.com/ViktorHugodev/evolution-heroku)

## Evolution API - API REST do WhatsApp para automação

Este é um repositório configurado para deploy da [Evolution API](https://github.com/EvolutionAPI/evolution-api) no [Heroku](https://heroku.com/).

### Deploy Rápido

Use o botão **Deploy to Heroku** acima para iniciar a Evolution API no Heroku. Durante o deploy, certifique-se de revisar todas as opções de configuração e ajustá-las conforme suas necessidades.

### Importante

Ao fazer o deploy, certifique-se de:

1. Alterar o `SERVER_URL` para o URL do seu aplicativo Heroku (https://seu-app.herokuapp.com)
2. Verificar se a chave de API `AUTHENTICATION_API_KEY` foi gerada automaticamente ou definir uma chave segura
3. Ajustar outras configurações conforme necessário para seu caso de uso

### Addons Incluídos

Este template configura automaticamente:
- PostgreSQL para armazenamento persistente
- Redis para cache
- Papertrail para logs

### Variáveis de Ambiente

As principais variáveis de ambiente já estão configuradas no arquivo `app.json`. Se precisar personalizar mais configurações, consulte a [documentação oficial](https://github.com/EvolutionAPI/evolution-api) da Evolution API.

### Estrutura do Repositório

- `Dockerfile`: Configura a imagem Docker da Evolution API
- `entrypoint.sh`: Script de inicialização que configura a conexão com o banco de dados e Redis
- `heroku.yml`: Define a configuração de build para o Heroku
- `app.json`: Define as configurações para o botão de deploy do Heroku

### Suporte

Se você tiver dúvidas ou precisar de ajuda, consulte:
- [Documentação da Evolution API](https://github.com/EvolutionAPI/evolution-api)
- [Comunidade da Evolution API](https://github.com/EvolutionAPI/evolution-api/issues)