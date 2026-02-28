```markdown
# 📖 Meu Primeiro Repositório – Manual GitHub

Este repositório foi criado para aprender e praticar os comandos básicos do **Git** e do **GitHub**.  
Aqui estão as instruções e anotações que usei durante o processo.

---

## 🚀 Fluxo de Trabalho Básico

1. **Adicionar arquivos ao índice**
   ```bash
   git add arquivo.txt
   git add .
   ```

2. **Criar commit**
   ```bash
   git commit -m "Mensagem explicando a mudança"
   ```

3. **Enviar para o GitHub**
   ```bash
   git push
   ```

4. **Trazer alterações do GitHub para o local**
   ```bash
   git pull
   ```

---

## 📊 Guia Rápido dos Comandos Git

| Comando Git        | Tradução literal | Quando usar | Exemplo prático |
|--------------------|------------------|-------------|-----------------|
| `git init`         | iniciar          | Criar um repositório Git em uma pasta nova. | `git init` dentro da pasta `meu-projeto` |
| `git clone`        | clonar           | Copiar um repositório do GitHub para sua máquina. | `git clone https://github.com/usuario/repositorio.git` |
| `git add`          | adicionar        | Preparar arquivos modificados para commit. | `git add hello.txt` ou `git add .` |
| `git commit`       | comprometer      | Registrar mudanças no histórico local. | `git commit -m "Atualizei hello.txt"` |
| `git push`         | empurrar         | Enviar commits locais para o GitHub. | `git push origin main` |
| `git pull`         | puxar            | Trazer alterações do GitHub para sua máquina. | `git pull origin main` |
| `git status`       | status           | Verificar quais arquivos foram modificados. | `git status` |
| `git log`          | registro         | Ver histórico de commits. | `git log --oneline` |
| `git branch`       | ramo             | Criar ou listar branches. | `git branch nova-funcionalidade` |
| `git merge`        | mesclar          | Juntar alterações de um branch em outro. | `git merge nova-funcionalidade` |

---

## 🔒 Conflitos e Sincronização
- O `git pull` **não apaga suas alterações locais**.  
- Se houver conflito, o Git marca o arquivo com:
  ```
  <<<<<<< HEAD
  (sua versão local)
  =======
  (versão do GitHub)
  >>>>>>> origin/main
  ```
- Resolva manualmente, salve e finalize com:
  ```bash
  git add arquivo
  git commit
  ```

---

## 📦 Limites do GitHub
- Repositório recomendado: até **5 GB**.  
- Arquivo máximo: **100 MB**.  
- Repositório máximo: **100 GB**.  
- Para arquivos grandes: usar **Git LFS (Large File Storage)**.  

---

## 📖 README.md
Este arquivo serve como **introdução** ao repositório.  
Ele explica o que é o projeto, como usar e como contribuir.  
No GitHub, o `README.md` aparece automaticamente na página inicial do repositório.

---

## ✅ Em resumo
- **push = empurrar** → do local para o GitHub.  
- **pull = puxar** → do GitHub para o local.  
- **add + commit** → preparar e registrar mudanças.  
- **clone/init** → começar um repositório.  
- **branch/merge** → trabalhar em paralelo e juntar depois.  
```

---

👉 Agora é só você abrir o `vim` com `vim README.md`, colar esse conteúdo, salvar e dar o ciclo `git add → git commit → git push`. Assim o manual vai aparecer na **página inicial do repositório** já formatado.  

Excelente! Deixar o **README.md** redondo é o que diferencia um repositório "bagunçado" de um projeto de **nível profissional**.

Se alguém (ou você mesmo no futuro) cair nesse repositório, vai saber exatamente o que fazer sem precisar ler todo o código do alias.

### Sugestão de texto para o seu README.md

Você pode abrir o arquivo com `nano README.md` e colar esta seção no final:

```markdown
---

## 🚀 Como Estudar para a LPIC-1

Este repositório contém um sistema de Flashcards automatizado para rodar direto no terminal.

### 1. Configuração
Para usar o comando `est_lpic`, adicione o alias ao seu ambiente:
- O passo a passo está no arquivo `flashcard/AdicionarAlias.txt`.

### 2. Como rodar
Basta digitar o comando abaixo no terminal:
\`\`\`bash
est_lpic
\`\`\`

### 3. O que o sistema faz?
- Sorteia 1 de 100 questões fundamentais da LPIC-1.
- Centraliza a pergunta para melhor foco.
- Mostra o número do Card (linha) para facilitar a revisão posterior.

```

---

### 💡 Dica Final de Git:

Depois de editar o README, não esqueça daquele "combo" que você já mestreou:

1. `git add README.md`
2. `git commit -m "docs: adiciona instruções de uso dos flashcards"`
3. `git push origin main`

Agora sim, seu projeto está com "selo de qualidade" internacional!

**Tudo pronto por aqui?** Se o cérebro pedir uma pausa, vá tomar um café — você trabalhou bem hoje. Se quiser continuar, é só mandar! ☕🐧

Fim do processo.
