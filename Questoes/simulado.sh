#!/bin/bash
# Diretórios e Arquivos
# 
# 
DIRETORIO="/root/meu-primeiro-repo/Questoes"
LOG_FILE="/root/meu-primeiro-repo/historico_estudos.log"

# Função para formatar o rodapé/topo com data e hora
gerar_topo() {
    local modulo="$1"
    local info_extra="$2"
    echo "📅 $(date '+%d/%m/%Y - %H:%M') | 🖥️ Host: $(hostname) | Tópico: $modulo $info_extra"
}

while true; do
    ACERTOS=0; ERROS=0; TOTAL=0
    
    # Busca apenas os arquivos de questões (evita scripts e backups)
    ARQUIVOS_TXT=($(ls $DIRETORIO/linuxquestoes*.txt 2>/dev/null))

    if [ ${#ARQUIVOS_TXT[@]} -eq 0 ]; then
        dialog --title "Erro" --msgbox "Nenhum arquivo linuxquestoes*.txt encontrado em $DIRETORIO" 6 60
        exit 1
    fi

    MENU_ARQUIVOS=()
    MENU_ARQUIVOS+=("MODO_REAL" ">> SIMULADO MIX (60 questões aleatórias) <<")
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
                               --menu "Selecione o simulado (Use as setas):" 18 95 10 \
                               "${MENU_ARQUIVOS[@]}" \
                               2>&1 >/dev/tty)

    [ $? -ne 0 ] && clear && exit 0
    
    # OPÇÃO DE VER O LOG
    if [ "$ARQUIVO_ESCOLHIDO" == "VER_LOG" ]; then
        [ -f "$LOG_FILE" ] && dialog --title "Histórico" --textbox "$LOG_FILE" 20 90 || dialog --msgbox "Sem logs!" 6 30
        continue
    fi

    QUESTOES_TEMP=$(mktemp)

    # --- LÓGICA DE SORTEIO E EMBARALHAMENTO ---
    if [ "$ARQUIVO_ESCOLHIDO" == "MODO_REAL" ]; then
        TITULO_MODULO="Simulado MIX"
        TEMP_RAW=$(mktemp)
        for f in $DIRETORIO/linuxquestoes*.txt; do
            # grep -n captura a linha original do arquivo
            grep -n "|" "$f" | sed "s|^|$(basename $f):|" >> "$TEMP_RAW"
        done
        # shuf embaralha tudo e head pega as 60
        shuf "$TEMP_RAW" | head -n 60 > "$QUESTOES_TEMP"
        rm -f "$TEMP_RAW"
    else
        TITULO_MODULO=$(head -n 1 "$DIRETORIO/$ARQUIVO_ESCOLHIDO" | sed 's/^# //;s/^#//' | cut -c1-30)
        # Pega as questões do arquivo e embaralha mantendo o número da linha original
        grep -n "|" "$DIRETORIO/$ARQUIVO_ESCOLHIDO" | shuf > "$QUESTOES_TEMP"
    fi

    TOTAL_NO_ARQUIVO=$(wc -l < "$QUESTOES_TEMP")
    CONTADOR_ATUAL=0

    # --- INÍCIO DA RODADA ---
    while IFS= read -r LINHA_BRUTA; do
        [ -z "$LINHA_BRUTA" ] && continue
        ((CONTADOR_ATUAL++))

        # Parsing dos dados conforme o modo escolhido
        if [ "$ARQUIVO_ESCOLHIDO" == "MODO_REAL" ]; then
            ARQ_ORIGEM=$(echo "$LINHA_BRUTA" | cut -d':' -f1)
            NUM_LINHA=$(echo "$LINHA_BRUTA" | cut -d':' -f2)
            DADOS_QUESTAO=$(echo "$LINHA_BRUTA" | cut -d':' -f3-)
        else
            ARQ_ORIGEM="$ARQUIVO_ESCOLHIDO"
            NUM_LINHA=$(echo "$LINHA_BRUTA" | cut -d':' -f1)
            DADOS_QUESTAO=$(echo "$LINHA_BRUTA" | cut -d':' -f2-)
        fi

        PERGUNTA=$(echo "$DADOS_QUESTAO" | cut -d'|' -f1 | xargs)
        ALTERNATIVAS_RAW=$(echo "$DADOS_QUESTAO" | cut -d'|' -f2 | xargs)
        CORRETA=$(echo "$ALTERNATIVAS_RAW" | cut -d';' -f1 | xargs)
        
        OPCOES=()
        i=1
        while IFS= read -r opt; do
            [ -z "$opt" ] && continue
            OPCOES+=("$i" "$opt"); ((i++))
        done < <(echo "$ALTERNATIVAS_RAW" | tr ';' '\n' | shuf)

        # Montagem do placar com localização da questão
        INFO_PLACAR="| Qst: $CONTADOR_ATUAL/$TOTAL_NO_ARQUIVO | Local: $ARQ_ORIGEM (L:$NUM_LINHA) | ✅ $ACERTOS | ❌ $ERROS"
        
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
            ((ACERTOS++)); STATUS="\Z2[ CORRETO! ]\Zn"; TITLE="PARABÉNS!"
            SUA_ESCOLHA_COLOR="\Z2$TEXTO_ESCOLHA\Zn"
        else
            ((ERROS++)); STATUS="\Z1[ ERRADO! ]\Zn"; TITLE="QUE PENA..."
            SUA_ESCOLHA_COLOR="\Z1$TEXTO_ESCOLHA\Zn"
        fi
        
        dialog --colors \
               --backtitle "$(gerar_topo "$TITULO_MODULO" "$INFO_PLACAR")" \
               --title "$TITLE" \
               --msgbox "PERGUNTA:\n$PERGUNTA\n\n--------------------------------------------\nSUA ESCOLHA:\n$SUA_ESCOLHA_COLOR\n\nRESPOSTA CORRETA:\n\Z2$CORRETA\Zn\n\n--------------------------------------------\nSTATUS: $STATUS" 20 95
    done < "$QUESTOES_TEMP"
    
    rm -f "$QUESTOES_TEMP"
    
    if [ $TOTAL -gt 0 ]; then
        PORCENTAGEM=$(( (ACERTOS * 100) / TOTAL ))
        DATA_FIM=$(date '+%d/%m/%Y às %H:%M')
        dialog --title "📊 RESUMO DO SIMULADO" \
               --msgbox "\nModo: $TITULO_MODULO\nData: $DATA_FIM\n\n--------------------------------------\nTotal Respondido: $TOTAL\nAcertos: $ACERTOS ✅\nErros: $ERROS ❌\n\nAproveitamento Final: $PORCENTAGEM%\n--------------------------------------" 15 55
        
        LOG_LINHA="[ $DATA_FIM ] | MODO: $TITULO_MODULO | TOTAL: $TOTAL | ACERTOS: $ACERTOS | ERROS: $ERROS | APROVEITAMENTO: $PORCENTAGEM%"
        echo "$LOG_LINHA" | cat - "$LOG_FILE" > temp_log && mv temp_log "$LOG_FILE" 2>/dev/null || echo "$LOG_LINHA" >> "$LOG_FILE"
    fi
done
