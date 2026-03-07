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

# 1. Coleta e embaralha a ordem das perguntas
grep -h "^\[LPIC-1\]" $DIR_QUESTOES/*.txt | shuf > $TEMP_FILE

# 2. Ajuste de quantidade se o banco for menor que o total da prova
TOTAL_DISPONIVEL=$(wc -l < $TEMP_FILE)
[ $TOTAL_DISPONIVEL -lt $TOTAL_PROVA ] && TOTAL_PROVA=$TOTAL_DISPONIVEL

# 3. Loop do Simulado
for i in $(seq 1 $TOTAL_PROVA); do
    LINHA=$(sed -n "${i}p" $TEMP_FILE)
    
    # Separa Pergunta e Gabarito (Limpando espaços com xargs)
    PERGUNTA=$(echo "$LINHA" | cut -d'|' -f1 | xargs)
    GABARITO=$(echo "$LINHA" | cut -d'|' -f2 | cut -d';' -f1 | xargs)
    
    # Embaralha as alternativas individuais
    ALTS=$(echo "$LINHA" | cut -d'|' -f2 | tr ';' '\n' | xargs -L1 | shuf | tr '\n' ';')

    OPC1=$(echo "$ALTS" | cut -d';' -f1)
    OPC2=$(echo "$ALTS" | cut -d';' -f2)
    OPC3=$(echo "$ALTS" | cut -d';' -f3)
    OPC4=$(echo "$ALTS" | cut -d';' -f4)
    OPC5=$(echo "$ALTS" | cut -d';' -f5)

    # Menu de seleção
    RESPOSTA=$(dialog --stdout --colors --backtitle "Simulado Master LPIC-1 - Preparatório Rubens Miyahira" \
        --title "Questão $i de $TOTAL_PROVA" \
        --menu "\n$PERGUNTA" 20 85 5 \
        "1" "$OPC1" \
        "2" "$OPC2" \
        "3" "$OPC3" \
        "4" "$OPC4" \
        "5" "$OPC5")

    # Sai do script se o usuário apertar ESC ou Cancelar
    [ $? -ne 0 ] && break

    # Identifica a opção escolhida
    ESCOLHIDA=""
    case $RESPOSTA in
        1) ESCOLHIDA=$OPC1 ;;
        2) ESCOLHIDA=$OPC2 ;;
        3) ESCOLHIDA=$OPC3 ;;
        4) ESCOLHIDA=$OPC4 ;;
        5) ESCOLHIDA=$OPC5 ;;
    esac

    # Comparação e Feedback
    if [ "$ESCOLHIDA" == "$GABARITO" ]; then
        ((ACERTOS++))
        # \Z2 = Verde / \Zn = Reset
        dialog --colors --title "Resultado" --sleep 1 --infobox "\n          \Z2CORRETO! ✔️\Zn" 5 40
    else
        # \Z1 = Vermelho / \Z2 = Verde / \Zb = Negrito
        dialog --colors --title "❌ ANÁLISE DO ERRO" --msgbox \
"PERGUNTA:
$PERGUNTA

-----------------------------------------------------------
SUA RESPOSTA:
\Z1$ESCOLHIDA\Zn

RESPOSTA CORRETA:
\Z2$GABARITO\Zn" 16 75
    fi
done

# 4. Resultado Final
if [ $i -gt 0 ]; then
    PORCENTAGEM=$(( (ACERTOS * 100) / i ))
    dialog --colors --title "📊 RELATÓRIO FINAL" --msgbox \
"\nSimulado encerrado.

Total de questões respondidas: $i
Acertos: \Z2$ACERTOS\Zn
Aproveitamento: \Zb$PORCENTAGEM%\Zn" 12 50
fi

# Limpeza e encerramento
rm -f $TEMP_FILE
clear
