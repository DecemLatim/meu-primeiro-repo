
---

```markdown
# 📖 Manual de Instruções – GitHub para Iniciantes

## 1. Instalação e Configuração Inicial
- Instale o Git:
  ```bash
  sudo apt install git
  ```
- Configure seu nome e e‑mail (aparecem nos commits):
  ```bash
  git config --global user.name "SeuNome"
  git config --global user.email "seuemail@example.com"
  ```

---

## 2. Criando um Repositório Local
1. Crie uma pasta:
   ```bash
   mkdir meu-projeto
   cd meu-projeto
   ```
2. Inicie o Git:
   ```bash
   git init
   ```
3. Crie um arquivo simples:
   ```bash
   echo "Hello World" > hello.txt
   ```
4. Adicione e faça o primeiro commit:
   ```bash
   git add hello.txt
   git commit -m "Primeiro commit"
   ```

---

## 3. Conectando ao GitHub
1. Crie uma conta em [github.com](https://github.com).  
2. Crie um repositório novo (ex.: `meu-projeto`).  
3. Configure o remoto via SSH:
   ```bash
   git remote add origin git@github.com:SeuUsuario/meu-projeto.git
   ```
4. Envie o código:
   ```bash
   git branch -M main
   git push -u origin main
   ```

---

## 4. Fluxo de Trabalho Básico
Sempre que alterar arquivos:
1. **Adicionar ao índice**:
   ```bash
   git add arquivo.txt
   ```
   ou todos de uma vez:
   ```bash
   git add .
   ```
2. **Criar commit**:
   ```bash
   git commit -m "Mensagem explicando a mudança"
   ```
3. **Enviar para o GitHub**:
   ```bash
   git push
   ```

Se alterar algo direto no GitHub, traga para o local:
```bash
git pull
```

---

## 5. Conflitos e Sincronização
- Se você alterar o mesmo arquivo localmente e no GitHub, o `git pull` pode gerar **conflito**.  
- O Git marca o arquivo com:
  ```
  <<<<<<< HEAD
  (sua versão local)
  =======
  (versão do GitHub)
  >>>>>>> origin/main
  ```
- Resolva manualmente, salve, depois:
  ```bash
  git add arquivo
  git commit
  ```

---

## 6. Limites do GitHub
- Repositório recomendado: até **5 GB**.  
- Arquivo máximo: **100 MB**.  
- Repositório máximo: **100 GB**.  
- Para arquivos grandes: usar **Git LFS (Large File Storage)**.

---

## 7. Dicas Úteis
- Atalho para commit rápido:
  ```bash
  git commit -am "Mensagem"
  ```
- Verificar status:
  ```bash
  git status
  ```
- Ver histórico:
  ```bash
  git log
  ```

---

# 📊 Guia Rápido dos Comandos Git

| Comando Git        | Tradução literal | Quando usar | Exemplo prático |
|--------------------|------------------|-------------|-----------------|
| `git init`         | iniciar          | Quando você quer começar um repositório Git em uma pasta nova. | `git init` dentro da pasta `meu-projeto` |
| `git clone`        | clonar           | Para copiar um repositório do GitHub para sua máquina. | `git clone git@github.com:DecemLatim/meu-projeto.git` |
| `git add`          | adicionar        | Quando você modificou ou criou arquivos e quer preparar para commit. | `git add hello.txt` ou `git add .` |
| `git commit`       | comprometer      | Para registrar oficialmente as mudanças no histórico local. | `git commit -m "Atualizei hello.txt"` |
| `git push`         | empurrar         | Quando quer enviar seus commits locais para o GitHub. | `git push origin main` |
| `git pull`         | puxar            | Para trazer alterações do GitHub para sua máquina. | `git pull origin main` |
| `git status`       | status           | Para verificar quais arquivos foram modificados e se estão prontos para commit. | `git status` |
| `git log`          | registro         | Para ver o histórico de commits feitos. | `git log --oneline` |
| `git branch`       | ramo             | Para criar ou listar branches (linhas de desenvolvimento). | `git branch nova-funcionalidade` |
| `git merge`        | mesclar          | Para juntar alterações de um branch em outro. | `git merge nova-funcionalidade` |

---

## ✅ Em resumo
- **push = empurrar** → do local para o GitHub.  
- **pull = puxar** → do GitHub para o local.  
- **add + commit** → preparar e registrar mudanças.  
- **clone/init** → começar um repositório.  
- **branch/merge** → trabalhar em paralelo e juntar depois.  
```

--- 

Fim do processo.
