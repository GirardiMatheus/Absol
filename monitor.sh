#!/bin/bash

# Carrega variáveis de ambiente
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Arquivo .env não encontrado. Use .env.example como modelo."
    exit 1
fi

# Diretório a ser monitorado (padrão: /etc)
TARGET_DIR="${TARGET_DIR:-/etc}"

# Arquivo para armazenar hashes
HASH_FILE="${HASH_FILE:-hashes.txt}"

# Telegram Bot Config
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-your_telegram_bot_token}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-your_chat_id}"

# Arquivo de log opcional
LOG_FILE="monitor.log"

# Verifica se o diretório existe
if [ ! -d "$TARGET_DIR" ]; then
    echo "[!] Diretório $TARGET_DIR não encontrado!"
    exit 1
fi

# Função para enviar alerta via Telegram
send_telegram_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=Markdown" > /dev/null
}

# Função para calcular hashes
calculate_hashes() {
    find "$TARGET_DIR" -type f -exec sha256sum {} \; > "$HASH_FILE"
}

# Função para verificar alterações
check_for_changes() {
    while true; do
        temp_file=$(mktemp)
        trap 'rm -f "$temp_file"' EXIT  # Remove o arquivo temporário ao sair do script
        find "$TARGET_DIR" -type f -exec sha256sum {} \; > "$temp_file"

        # Compara os hashes salvos com os novos
        if ! diff -q "$HASH_FILE" "$temp_file" > /dev/null; then
            echo "[!] Alterações detectadas em $TARGET_DIR!"
            changed_files=$(diff "$HASH_FILE" "$temp_file" | awk '{print $2}')

            for file in $changed_files; do
                alert_message="🚨 *Absol Alert* 🚨\n\n📂 *Arquivo Alterado:* \`$file\`\n🖥️ *Host:* \`$(hostname)\`"
                echo "$alert_message"

                # Registra log
                echo "$(date '+%Y-%m-%d %H:%M:%S') - $file modificado" >> "$LOG_FILE"

                # Envia alerta via Telegram
                if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
                    send_telegram_alert "$alert_message"
                fi
            done

            # Atualiza o arquivo de hashes
            mv "$temp_file" "$HASH_FILE"
        else
            echo "[✓] Nenhuma alteração detectada."
            rm "$temp_file"
        fi

        sleep "${CHECK_INTERVAL:-60}"
    done
}

# Menu principal
case "$1" in
    --init)
        echo "[*] Calculando hashes iniciais..."
        calculate_hashes
        echo "[✓] Hashes salvos em $HASH_FILE"
        ;;
    --monitor)
        echo "[*] Iniciando monitoramento..."
        check_for_changes
        ;;
    *)
        echo "Uso: $0 [--init | --monitor]"
        echo "  --init     Calcula hashes iniciais"
        echo "  --monitor  Inicia o monitoramento contínuo"
        exit 1
        ;;
esac
