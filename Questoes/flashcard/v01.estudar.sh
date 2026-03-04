#!/bin/bash

# Função principal do Flashcard
rodar_estudo() {
    arquivo=$1
    grep -n "." "$arquivo" | shuf | while IFS=":" read -r n resto; do
        IFS="|" read -r p r <<< "$resto"
        clear
        printf "\n%.0s" {1..10}
        echo -e "\e[1;34mCARD #$n\e[0m (Arquivo: $arquivo)"
        echo -e "\e[1;33mPERGUNTA:\e[0m $p"
        printf "\n"
        read -p "Pense e aperte ENTER..." < /dev/tty
        printf "\n\n"
        echo -e "\e[1;32mRESPOSTA:\e[0m $r"
        echo ""
        read -p "Próxima? [ENTER] ou 'q' para sair: " acao < /dev/tty
        [[ "$acao" == "q" ]] && break
    done
}

# Menu de Seleção
clear
printf "\n%.0s" {1..5}
echo "=========================================="
echo "    CENTRAL DE ESTUDOS LPIC-1 - DECEM     "
echo "=========================================="
echo "1) Deck 01: Geral, Processos e Pacotes (100 itens)"
echo "2) Deck 02: Redes, Serviços e Segurança (75 itens)"
echo "3) Estudar TUDO (Modo Maratona)"
echo "4) Sair"
echo "=========================================="
read -p "Escolha uma opção: " opcao

case $opcao in
    1) rodar_estudo "LinuxFlashcard.txt" ;;
    2) rodar_estudo "LinuxFlashcard02.txt" ;;
    3) cat LinuxFlashcard.txt LinuxFlashcard02.txt > .tudo.tmp && rodar_estudo ".tudo.tmp" && rm .tudo.tmp ;;
    4) exit ;;
    *) echo "Opção inválida!" ;;
esac
