#!/bin/bash

rodar_estudo() {
    arquivo=$1
    if [ ! -f "$arquivo" ]; then
        dialog --msgbox "Erro: Arquivo $arquivo não encontrado!" 10 40
        return
    fi

    grep -n "." "$arquivo" | shuf | while IFS=":" read -r n resto; do
        IFS="|" read -r p r <<< "$resto"
        
        # 1. TELA DA PERGUNTA
        dialog --backtitle "Estudando: $arquivo" \
               --title "CARD #$n - PERGUNTA" \
               --ok-label "VER RESPOSTA" \
               --extra-button --extra-label "SAIR" \
               --msgbox "\nPERGUNTA:\n$p\n\n" 15 65
        
        if [ $? -eq 3 ]; then return; fi

        # 2. TELA DE REVELAÇÃO (Pergunta + Resposta na mesma caixa)
        # Usamos \Z1 para cor vermelha ou \Z2 para verde se o dialog suportar --colors
        dialog --colors \
               --backtitle "Estudando: $arquivo" \
               --title "CARD #$n - REVELADO" \
               --ok-label "PRÓXIMA" \
               --extra-button --extra-label "MENU" \
               --msgbox "\n\Z4PERGUNTA:\Zn\n$p\n\n--------------------------------------------\n\n\Z2RESPOSTA:\Zn\n$r\n\n" 18 65
        
        if [ $? -eq 3 ]; then return; fi
    done
}

# Loop do Menu Principal
while true; do
    OPCAO=$(dialog --clear \
                    --backtitle "Sistema de Estudos LPIC-1 - Decem" \
                    --title " MENU PRINCIPAL " \
                    --cancel-label "Sair do Script" \
                    --menu "Escolha o deck que deseja estudar:" \
                    15 55 5 \
                    1 "Deck 01 (Geral, Processos, Pacotes)" \
                    2 "Deck 02 (Redes, Serviços, Segurança)" \
                    3 "Deck 03 (SQL, Kernel, Boot)" \
                    4 "MARATONA (Todos os 175+ cards)" \
                    5 "Sair" \
                    2>&1 >/dev/tty)

    if [ $? -ne 0 ] || [ "$OPCAO" == "5" ]; then
        clear
        echo "Bons estudos e até a próxima!"
        exit 0
    fi

    case $OPCAO in
        1) rodar_estudo "LinuxFlashcard.txt" ;;
        2) rodar_estudo "LinuxFlashcard02.txt" ;;
        3) rodar_estudo "LinuxFlashcard03.txt" ;;
        4) 
            cat LinuxFlashcard.txt LinuxFlashcard02.txt LinuxFlashcard03.txt > .tudo.tmp
            rodar_estudo ".tudo.tmp"
            rm .tudo.tmp
            ;;
    esac
done
