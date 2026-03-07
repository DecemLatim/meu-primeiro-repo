#!/bin/bash

# Diretório das questões
DIR_QUESTOES="./Questoes"
TEMP_FILE="/tmp/simulado_temp.txt"
TOTAL_PROVA=60
ACERTOS=0

# Verifica se o dialog está instalado
if ! command -v dialog &> /dev/null; then
    echo "Erro: O utilitário 'dialog' não está instalado."
    exit 1
fi

# 1. Coletar questões e embaralhar
grep -h "^\[LPIC-1\]" $DIR_QUESTOES/*.txt | shuf > $TEMP_FILE

# 2. Ajustar total de questões
TOTAL_DISPONIVEL=$(wc -l < $TEMP_FILE)
if [ $TOTAL_DISPONIVEL -lt $TOTAL_PROVA ]; then
    TOTAL_PROVA=$TOTAL_DISPONIVEL
fi

# 3. Loop do Simulado
for i in $(seq 1 $TOTAL_PROVA); do
    LINHA=$(sed -n "${i}p" $TEMP_FILE)
    
    # Limpeza de strings
    PERGUNTA=$(echo "$LINHA" | cut -d'|' -f1 | xargs)
    GABARITO=$(echo "$LINHA" | cut -d'|' -f2 | cut -d';' -f1 | xargs)
    ALTS=$(echo "$LINHA" | cut -d'|' -f2 | tr ';' '\n' | xargs -L1 | shuf | tr '\n' ';')

    OPC1=$(echo "$ALTS" | cut -d';' -f1)
    OPC2=$(echo "$ALTS" | cut -d';' -f2)
    OPC3=$(echo "$ALTS" | cut -d';' -f3)
    OPC4=$(echo "$ALTS" | cut -d';' -f4)
    OPC5=$(echo "$ALTS" | cut -d';' -f5)

    RESPOSTA=$(dialog --stdout --backtitle "Simulado LPIC-1 - Estudo Rubens Miyahira" \
        --title "Questão $i de $TOTAL_PROVA" \
        --menu "\n$PERGUNTA" 18 85 5 \
        "1" "$OPC1" \
        "2" "$OPC2" \
        "3" "$OPC3" \
        "4" "$OPC4" \
        "5" "$OPC5")

    [ $? -ne 0 ] && break

    case $RESPOSTA in
        1) ESCOLHIDA=$OPC1 ;;
        2) ESCOLHIDA=$OPC2 ;;
        3) ESCOLHIDA=$OPC3 ;;
        4) ESCOLHIDA=$OPC4 ;;
        5) ESCOLHIDA=$OPC5 ;;
    esac

    if [ "$ESCOLHIDA" == "$GABARITO" ]; then
        ((ACERTOS++))
        dialog --title "Resultado" --sleep 1 --infobox "\n   CORRETO! ✔️" 5 30
    else
        # AQUI A MUDANÇA: Mostra Pergunta + Resposta Correta
        dialog --title "❌ RESPOSTA INCORRETA" --msgbox \
"PERGUNTA:
$PERGUNTA

-----------------------------------------------------------
RESPOSTA CORRETA:
➜ $GABARITO" 16 75
    fi
done

# 4. Resultado Final
if [ $i -gt 0 ]; then
    PORCENTAGEM=$(( (ACERTOS * 100) / i ))
    dialog --title "📊 RELATÓRIO FINAL" --msgbox \
"\nSimulado encerrado.

Total de questões: $i
Acertos: $ACERTOS
Aproveitamento: $PORCENTAGEM%" 12 50
fi

rm -f $TEMP_FILE
clear
