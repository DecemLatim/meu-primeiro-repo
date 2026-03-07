#!/bin/bash

# Configurações de caminhos
DIR_QUESTOES="./Questoes"
TEMP_FILE="/tmp/simulado_temp.txt"
LOG_FILE="./simulado.log"
TOTAL_PROVA=60
ACERTOS=0

# Verifica dependências
if ! command -v dialog &> /dev/null; then
    echo "Erro: Instale o 'dialog' (sudo apt install dialog)"
    exit 1
fi

# 1. Iniciar Log
DATA_INICIO=$(date "+%d/%m/%Y %H:%M:%S")
echo "--------------------------------------------------" >> $LOG_FILE
echo "Início do Simulado: $DATA_INICIO" >> $LOG_FILE

# 2. Coleta e embaralha perguntas
grep -h "^\[LPIC-1\]" $DIR_QUESTOES/*.txt | shuf > $TEMP_FILE
TOTAL_DISPONIVEL=$(wc -l < $TEMP_FILE)
[ $TOTAL_DISPONIVEL -lt $TOTAL_PROVA ] && TOTAL_PROVA=$TOTAL_DISPONIVEL

# 3. Loop do Simulado
for i in $(seq 1 $TOTAL_PROVA); do
    # Atualiza o relógio para cada questão
    AGORA=$(date "+%H:%M:%S")
    LINHA=$(sed -n "${i}p" $TEMP_FILE)
    
    PERGUNTA=$(echo "$LINHA" | cut -d'|' -f1 | xargs)
    GABARITO=$(echo "$LINHA" | cut -d'|' -f2 | cut -d';' -f1 | xargs)
    ALTS=$(echo "$LINHA" | cut -d'|' -f2 | tr ';' '\n' | xargs -L1 | shuf | tr '\n' ';')

    OPC1=$(echo "$ALTS" | cut -d';' -f1)
    OPC2=$(echo "$ALTS" | cut -d';' -f2)
    OPC3=$(echo "$ALTS" | cut -d';' -f3)
    OPC4=$(echo "$ALTS" | cut -d';' -f4)
    OPC5=$(echo "$ALTS" | cut -d';' -f5)

    # Menu com Relógio no Backtitle (barra azul superior)
    RESPOSTA=$(dialog --stdout --colors \
        --backtitle "LPIC-1 | Rubens Miyahira | Hora: $AGORA | Data: $(date +%d/%m/%Y)" \
        --title "Questão $i de $TOTAL_PROVA" \
        --menu "\n$PERGUNTA" 20 85 5 \
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
        dialog --colors --title "Resultado" --sleep 1 --infobox "\n          \Z2CORRETO! ✔️\Zn" 5 40
    else
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

# 4. Resultado Final e Log de Fecho
DATA_FIM=$(date "+%d/%m/%Y %H:%M:%S")
if [ $i -gt 0 ]; then
    PORCENTAGEM=$(( (ACERTOS * 100) / i ))
    
    # Escreve no ficheiro de Log
    echo "Fim: $DATA_FIM" >> $LOG_FILE
    echo "Resultado: $ACERTOS/$i ($PORCENTAGEM%)" >> $LOG_FILE
    echo "--------------------------------------------------" >> $LOG_FILE

    dialog --colors --title "📊 RELATÓRIO FINAL" --msgbox \
"\nSimulado encerrado em $DATA_FIM.

Total de questões: $i
Acertos: \Z2$ACERTOS\Zn
Aproveitamento: \Zb$PORCENTAGEM%\Zn" 12 50
fi

rm -f $TEMP_FILE
clear
