#!/bin/bash

rodar_estudo() {
    arquivo=$1
    if [ ! -f "$arquivo" ]; then
        dialog --msgbox "Erro: Arquivo $arquivo não encontrado!" 10 40
        return
    fi

    grep -n "." "$arquivo" | shuf | while IFS=":" read -r n resto; do
        IFS="|" read -r p r <<< "$resto"
        
        dialog --backtitle "Estudando: $arquivo" \
               --title "CARD #$n - PERGUNTA" \
               --ok-label "VER RESPOSTA" \
               --extra-button --extra-label "SAIR" \
               --msgbox "\nPERGUNTA:\n$p\n\n" 15 65
        
        if [ $? -eq 3 ]; then return; fi

        dialog --colors \
               --backtitle "Estudando: $arquivo" \
               --title "CARD #$n - REVELADO" \
               --ok-label "PRÓXIMA" \
               --extra-button --extra-label "MENU" \
               --msgbox "\n\Z4PERGUNTA:\Zn\n$p\n\n\n\Z2RESPOSTA:\Zn\n$r\n\n" 18 65
        
        if [ $? -eq 3 ]; then return; fi
    done
}

while true; do
    OPCAO=$(dialog --clear \
                    --backtitle "Sistema de Estudos LPIC-1 - Decem" \
                    --title " MENU PRINCIPAL " \
                    --cancel-label "Sair do Script" \
                    --menu "Escolha o deck que deseja estudar:" \
                    17 60 7 \
                    1 "Deck 01 (Geral, Processos, Pacotes)" \
                    2 "Deck 02 (Redes, Serviços, Segurança)" \
                    3 "Deck 03 (SQL, Kernel, Boot)" \
                    4 "Deck 04 (Quotas, SQL Adv, Shell Adv)" \
                    5 "Deck 05 (BOOT - BIOS/UEFI/GRUB)" \
                    6 "MARATONA (Todos os 245+ cards)" \
                    7 "Sair" \
                    2>&1 >/dev/tty)

    if [ $? -ne 0 ] || [ "$OPCAO" == "7" ]; then
        clear
        echo "Bons estudos e até a próxima!"
        exit 0
    fi

    case $OPCAO in
        1) rodar_estudo "LinuxFlashcard01.txt" ;;
        2) rodar_estudo "LinuxFlashcard02.txt" ;;
        3) rodar_estudo "LinuxFlashcard03.txt" ;;
        4) rodar_estudo "LinuxFlashcard04.txt" ;;
        5) rodar_estudo "LinuxFlashcard05.txt" ;;
        6) 
            cat LinuxFlashcard01.txt LinuxFlashcard02.txt LinuxFlashcard03.txt LinuxFlashcard04.txt LinuxFlashcard05.txt > .tudo.tmp
            rodar_estudo ".tudo.tmp"
            rm .tudo.tmp
            ;;
    esac
done
