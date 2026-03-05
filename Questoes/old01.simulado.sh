#!/bin/bash

DIRETORIO="/root/meu-primeiro-repo/Questoes"
LOG_FILE="/root/meu-primeiro-repo/historico_estudos.log"

# Função para formatar o rodapé/topo com data e hora
gerar_topo() {
    local modulo="$1"
    local info_extra="$2"
    echo "📅 $(date '+%d/%m/%Y - %H:%M') | 🖥️ Host: $(hostname) | Tópico: $modulo $info_extra"
}

while true; do
    ACERTOS=0
    ERROS=0
    TOTAL=0
    
    ARQUIVOS_TXT=($(ls $DIRETORIO/*.txt 2>/dev/null))

    if [ ${#ARQUIVOS_TXT[@]} -eq 0 ]; then
        dialog --title "Erro" --msgbox "Nenhum arquivo .txt encontrado em $DIRETORIO" 6 50
        exit 1
    fi

    MENU_ARQUIVOS=()
    MENU_ARQUIVOS+=("MODO_REAL" ">> SIMULADO COMPLETO (60 questões mistas) <<")
    MENU_ARQUIVOS+=("VER_LOG" ">> VER HISTÓRICO DE ESTUDOS <<")
    
    for f in "${ARQUIVOS_TXT[@]}"; do
        DESC=$(head -n 1 "$f")
        LABEL_TEXT=$( [[ $DESC == "#"* ]] && echo "$DESC" | sed 's/^# //;s/^#//' | cut -c1-50 || basename "$f" )
        QTD=$(grep -v "^#" "$f" | grep -v "^$" | wc -l)
        MENU_ARQUIVOS+=("$(basename "$f")" "$LABEL_TEXT ($QTD qst)")
    done

    ARQUIVO_ESCOLHIDO=$(dialog --backtitle "$(gerar_topo 'Menu Principal' '')" \
                               --title "Selecione o Tópico para Estudar" \
                               --cancel-label "Fechar App" \
                               --menu "Selecione o simulado:" 18 95 10 \
                               "${MENU_ARQUIVOS[@]}" \
                               2>&1 >/dev/tty)

    [ $? -ne 0 ] && clear && exit 0
    
    # OPÇÃO DE VER O LOG
    if [ "$ARQUIVO_ESCOLHIDO" == "VER_LOG" ]; then
        if [ ! -f "$LOG_FILE" ]; then
            dialog --title "Histórico" --msgbox "Nenhum registro encontrado ainda!" 6 40
        else
            dialog --title "Seu Histórico de Estudos (Recentes no topo)" \
                   --textbox "$LOG_FILE" 20 90
        fi
        continue
    fi

    QUESTOES_TEMP=$(mktemp)

    if [ "$ARQUIVO_ESCOLHIDO" == "MODO_REAL" ]; then
        TITULO_MODULO="Simulado MIX"
        grep -h -v "^#" $DIRETORIO/*.txt | grep -v "^$" | shuf -n 60 > "$QUESTOES_TEMP"
    else
        TITULO_MODULO=$(head -n 1 "$DIRETORIO/$ARQUIVO_ESCOLHIDO" | sed 's/^# //;s/^#//' | cut -c1-30)
        grep -v "^#" "$DIRETORIO/$ARQUIVO_ESCOLHIDO" | grep -v "^$" | shuf > "$QUESTOES_TEMP"
    fi

    TOTAL_NO_ARQUIVO=$(wc -l < "$QUESTOES_TEMP")
    CONTADOR_ATUAL=0

    # --- INÍCIO DA RODADA ---
    while IFS= read -r LINHA; do
        [ -z "$LINHA" ] && continue
        ((CONTADOR_ATUAL++))

        PERGUNTA=$(echo "$LINHA" | cut -d'|' -f1 | xargs)
        ALTERNATIVAS_RAW=$(echo "$LINHA" | cut -d'|' -f2 | xargs)
        CORRETA=$(echo "$ALTERNATIVAS_RAW" | cut -d';' -f1 | xargs)
        
        OPCOES=()
        i=1
        while IFS= read -r opt; do
            [ -z "$opt" ] && continue
            OPCOES+=("$i" "$opt")
            ((i++))
        done < <(echo "$ALTERNATIVAS_RAW" | tr ';' '\n' | shuf)

        INFO_PLACAR="| Qst: $CONTADOR_ATUAL/$TOTAL_NO_ARQUIVO | ✅ $ACERTOS | ❌ $ERROS"
        
        ESCOLHA=$(dialog --backtitle "$(gerar_topo "$TITULO_MODULO" "$INFO_PLACAR")" \
                         --title "Questão Atual" \
                         --cancel-label "Sair" \
                         --menu "\n$PERGUNTA" 22 95 10 \
                         "${OPCOES[@]}" \
                         2>&1 >/dev/tty)

        if [ $? -ne 0 ]; then break; fi

        TEXTO_ESCOLHA=""
        for (( j=0; j<${#OPCOES[@]}; j+=2 )); do
            if [ "${OPCOES[$j]}" == "$ESCOLHA" ]; then
                TEXTO_ESCOLHA="${OPCOES[$j+1]}"; break
            fi
        done

        ((TOTAL++))
        if [ "$TEXTO_ESCOLHA" == "$CORRETA" ]; then
            ((ACERTOS++))
            STATUS="\Z2[ CORRETO! ]\Zn"
            TITLE="PARABÉNS!"
            SUA_ESCOLHA_COLOR="\Z2$TEXTO_ESCOLHA\Zn"
        else
            ((ERROS++))
            STATUS="\Z1[ ERRADO! ]\Zn"
            TITLE="QUE PENA..."
            SUA_ESCOLHA_COLOR="\Z1$TEXTO_ESCOLHA\Zn"
        fi
        
        RESPOSTA_CORRETA_COLOR="\Z2$CORRETA\Zn"

        dialog --colors \
               --backtitle "$(gerar_topo "$TITULO_MODULO" "$INFO_PLACAR")" \
               --title "$TITLE" \
               --msgbox "PERGUNTA:\n$PERGUNTA\n\n--------------------------------------------\nSUA ESCOLHA:\n$SUA_ESCOLHA_COLOR\n\nRESPOSTA CORRETA:\n$RESPOSTA_CORRETA_COLOR\n\n--------------------------------------------\nSTATUS: $STATUS" 20 95
    done < "$QUESTOES_TEMP"
    
    rm -f "$QUESTOES_TEMP"
    
    if [ $TOTAL -gt 0 ]; then
        PORCENTAGEM=$(( (ACERTOS * 100) / TOTAL ))
        DATA_FIM=$(date '+%d/%m/%Y às %H:%M')
        
        # EXIBE O RESUMO
        dialog --title "📊 RESUMO DO SIMULADO" \
               --msgbox "\nModo: $TITULO_MODULO\nData: $DATA_FIM\n\n--------------------------------------\nTotal Respondido: $TOTAL\nAcertos: $ACERTOS ✅\nErros: $ERROS ❌\n\nAproveitamento Final: $PORCENTAGEM%\n--------------------------------------" 15 55
        
        # GRAVA NO LOG (Adiciona ao início do arquivo para ver o mais recente primeiro)
        LOG_LINHA="[ $DATA_FIM ] | MODO: $TITULO_MODULO | TOTAL: $TOTAL | ACERTOS: $ACERTOS | ERROS: $ERROS | APROVEITAMENTO: $PORCENTAGEM%"
        echo "$LOG_LINHA" | cat - "$LOG_FILE" > temp_log && mv temp_log "$LOG_FILE" 2>/dev/null || echo "$LOG_LINHA" >> "$LOG_FILE"
    fi
done
