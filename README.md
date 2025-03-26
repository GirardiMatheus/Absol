<div align="center">
  <h1>
    <img src="./assets/Absol.svg" width="40" height="40" alt="Absol" style="vertical-align: middle;">
    Absol
  </h1>
  <p>Monitoramento Proativo de Arquivos Sensíveis</p>
  
  <p>
    <img src="https://img.shields.io/badge/Shell_Script-100%25-brightgreen" alt="Shell">
    <img src="https://img.shields.io/badge/Security-FF6B6B" alt="Security">
    <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
  </p>
</div>

## Visão Geral

O Absol é um guardião de arquivos críticos que detecta alterações não autorizadas usando hashes SHA256, oferecendo:

- Monitoramento contínuo de diretórios sensíveis (como `/etc`)
- Sistema de alertas via Telegram
- Detecção precisa de modificações em nível de arquivo

## Funcionalidades Principais

**Monitoramento de Arquivos**  
- Cálculo automático de hashes SHA256  
- Comparação inteligente entre verificações  
- Suporte a whitelist de arquivos (em desenvolvimento)  

**Sistema de Alertas**  
- Notificações instantâneas via Telegram  
- Mensagens detalhadas com:  
  - Nome do arquivo alterado  
  - Host onde ocorreu a mudança  
  - Timestamp da detecção  

**Configuração Flexível**  
- Intervalo de verificação ajustável  
- Multiplos diretórios monitoráveis  
- Arquivo de hashes versionável  

## Pré-requisitos

- Bash 4.0+
- Utilitários básicos: `sha256sum`, `find`, `diff`
- Para notificações via Telegram:
  - `curl` instalado

## Instalação Rápida

1. Clone o repositório:

```bash
git clone https://github.com/GirardiMatheus/Absol.git && cd Absol
```

2. Configure o ambiente:

```bash
cp .env.example .env
# Edite as variáveis (Telegram, diretórios, etc)
nano .env
```

3. Torne o script executável:

```bash
chmod +x absol.sh
```

## Como Usar

**Inicialização (primeira execução):**

```bash
./absol.sh --init  # Calcula hashes iniciais
```

**Monitoramento contínuo:**

```bash
./absol.sh --monitor
```

**Agendamento no cron (executar na reinicialização):**

```bash
@reboot /caminho/para/Absol/absol.sh --monitor
```

## Estrutura do Projeto

```bash
Absol/
├── absol.sh           # Script principal
├── .env.example       # Template de configuração
├── hashes.txt         # Banco de hashes (gerado automaticamente)
├── README.md          # Esta documentação
└── assets/            # (Opcional) Ícones e imagens
```

## Melhores Práticas

1. Configuração recomendada:

```bash
# No arquivo .env
TARGET_DIR="/etc"          # Diretório crítico a monitorar
CHECK_INTERVAL="300"       # Verificação a cada 5 minutos
HASH_FILE="hashes.txt"     # Arquivo de hashes versionável
```

2. Proteção do arquivo de hashes:

```bash
chmod 600 hashes.txt  # Restringe acesso apenas ao root
```

3. Integração com Git (para rastrear hashes):

```bash
git add hashes.txt
git commit -m "Snapshot dos hashes em $(date)"
```

## Contribuição

1. Faça um fork do projeto
2. Crie sua branch:
    git checkout -b feature/nova-funcionalidade
3. Commit suas mudanças:
    git commit -am 'Adiciona whitelist de arquivos'
4. Push para a branch:
    git push origin feature/nova-funcionalidade
5. Abra um Pull Request