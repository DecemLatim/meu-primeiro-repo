#!/bin/bash

# Função de Estudo
rodar_estudo() {
    arquivo=$1
    # Verifica se o arquivo existe para evitar erro
    if [ ! -f "$arquivo" ]; then
        dialog --msgbox "Erro: Arquivo $arquivo não encontrado!" 10 40
        return
    fi

    grep -n "." "$arquivo" | shuf | while IFS=":" read -r n resto; do
        IFS="|" read -r p r <<< "$resto"
        clear
        printf "\n%.0s" {1..10}
        echo -e "\e[1;34mCARD #$n\e[0m (Arquivo: $arquivo)"
        echo -e "\e[1;33mPERGUNTA:\e[0m $p"
        printf "\n"
        # Captura o ENTER para mostrar a resposta
        read -p "Pense e aperte ENTER..." < /dev/tty
        
        printf "\n\n"
        echo -e "\e[1;32mRESPOSTA:\e[0m $r"
        echo ""
        
        # Pergunta se quer continuar ou voltar ao menu
        read -p "Próxima? [ENTER] ou 'q' para MENU: " acao < /dev/tty
        
        if [[ "$acao" == "q" ]]; then
            return 0  # Sai da função e volta para o loop do menu
        fi
    done
}

# Loop Infinito do Menu
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

    # Verifica se o usuário apertou ESC ou Cancelar no dialog
    exit_status=$?
    if [ $exit_status -ne 0 ] || [ "$OPCAO" == "5" ]; then
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
