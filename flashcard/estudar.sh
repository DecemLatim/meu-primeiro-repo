#!/bin/bash

rodar_estudo() {
    arquivo=$1
    acertos=0
    erros=0
    
    if [ ! -f "$arquivo" ]; then
        dialog --msgbox "Erro: Arquivo $arquivo não encontrado!" 10 40
        return
    fi

    grep -n "." "$arquivo" | shuf | while IFS=":" read -r n resto; do
        IFS="|" read -r p r <<< "$resto"
        
        # 1. Tela de Pergunta
        dialog --backtitle "Estudando: $arquivo | Placar: ✅ $acertos | ❌ $erros" \
               --title "CARD #$n - PERGUNTA" \
               --ok-label "VER RESPOSTA" \
               --extra-button --extra-label "SAIR" \
               --msgbox "\nPERGUNTA:\n$p\n\n" 15 65
        
        [ $? -eq 3 ] && break

        # 2. Tela de Resposta com botões customizados
        # OK = Acertei (Próxima) | Extra = Errei | Cancel = Sair
        dialog --colors \
               --backtitle "Estudando: $arquivo | Placar: ✅ $acertos | ❌ $erros" \
               --title "CARD #$n - RESPOSTA" \
               --ok-label "ACERTEI! ✅" \
               --extra-button --extra-label "ERREI... ❌" \
               --cancel-label "SAIR" \
               --msgbox "\n\Z4PERGUNTA:\Zn\n$p\n\n--------------------------------------------\n\n\Z2RESPOSTA:\Zn\n$r\n\n" 18 65
        
        RES=$?

        case $RES in
            0) ((acertos++)) ;; # Botão OK (Acertei)
            3) ((erros++))   ;; # Botão Extra (Errei)
            1) break         ;; # Botão Cancel (Sair)
        esac

        # Salvando progresso para o loop
        echo "$acertos" > .acertos.tmp
        echo "$erros" > .erros.tmp
    done

    # Resumo Final
    final_a=$(cat .acertos.tmp 2>/dev/null || echo 0)
    final_e=$(cat .erros.tmp 2>/dev/null || echo 0)
    total=$((final_a + final_e))
    
    [ $total -gt 0 ] && dialog --title "RESULTADO DO TREINO" \
           --msgbox "\nSessão Finalizada!\n\nTotal de Cards: $total\nAcertos: $final_a ✅\nErros: $final_e ❌" 12 45
    
    rm -f .acertos.tmp .erros.tmp
}

while true; do
    OPCAO=$(dialog --clear \
                    --backtitle "Sistema de Estudos LPIC-1 - Decem" \
                    --title " MENU PRINCIPAL - 330 CARDS " \
                    --cancel-label "Sair" \
                    --menu "Escolha o seu deck:" \
                    18 65 8 \
                    1 "Deck 01 (Geral, Processos, Pacotes)" \
                    2 "Deck 02 (Redes, Serviços, Segurança)" \
                    3 "Deck 03 (SQL, Kernel, Hardware)" \
                    4 "Deck 04 (Quotas, Usuários, Permissões)" \
                    5 "Deck 05 (Boot, FHS, VI e Bibliotecas)" \
                    6 "MARATONA (Todos os 330 cards)" \
                    7 "Sair" \
                    2>&1 >/dev/tty)

    [ $? -ne 0 ] || [ "$OPCAO" == "7" ] && { clear; echo "Bons estudos!"; exit 0; }

    case $OPCAO in
        1) rodar_estudo "LinuxFlashcard01.txt" ;;
        2) rodar_estudo "LinuxFlashcard02.txt" ;;
        3) rodar_estudo "LinuxFlashcard03.txt" ;;
        4) rodar_estudo "LinuxFlashcard04.txt" ;;
        5) rodar_estudo "LinuxFlashcard05.txt" ;;
        6) cat LinuxFlashcard0*.txt > .tudo.tmp && rodar_estudo ".tudo.tmp" && rm .tudo.tmp ;;
    esac
done
