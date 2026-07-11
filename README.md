# Transparent Auto Downloader (yt-dlp) 🎥

Um script automatizado, interativo e **em arquivo único** (`.cmd`) para baixar vídeos e playlists do YouTube sem complicações. 

O foco deste projeto é a **Transparência e a Fluidez**. O programa roda através do terminal de comandos explicando cada ação (o que está instalando, para onde estão indo os arquivos) e opera em um **Loop Contínuo** — ele nunca fechará sozinho a menos que você escolha a opção "Sair". Conta também com um **Menu Interativo** que permite limpar os arquivos baixados e desinstalar tudo de forma limpa.

## ✨ Funcionalidades

* **Loop Contínuo:** Uma vez aberto, o menu não fecha após instalações ou erros. Ele injeta as ferramentas baixadas na sessão ativa de forma invisível.
* **Interface de Menu:** Controle tudo a partir de um menu inicial simples (Download, Limpeza e Desinstalação).
* **Transparência Ativa:** Informações contínuas na tela. Você nunca ficará sem saber o que o programa está fazendo.
* **Script Poliglota (Single-file):** O arquivo `downloader.cmd` funciona nativamente como Batch no Windows e como um script Bash no Linux/macOS.
* **Auto-instalação e Auto-recuperação:** Se faltarem dependências (`yt-dlp`, `ffmpeg`, `ffprobe`), o programa explica a importância de cada uma e instala tudo automaticamente usando os pacotes oficiais (`winget`, `apt-get` ou `brew`).
* **Menu de Limpeza Avançado:**
  * Escolha o que apagar: Apenas Vídeos, Apenas Áudios ou Tudo.
  * Desinstalação completa das ferramentas (`yt-dlp` e `ffmpeg`) com confirmação de segurança.
* **Resiliência na Instalação:** O script agora explica cada etapa da instalação, pede permissão, informa o diretório de destino e aguarda o usuário antes de prosseguir, evitando fechamentos inesperados do terminal.
* **Multi-OS:** Compatibilidade total com Windows (Batch), Linux (Apt) e macOS (Homebrew).

## 🚀 Como usar

Baixe o arquivo `downloader.cmd` deste repositório e siga as instruções:

### 🪟 No Windows
1. Dê um **duplo clique** no arquivo `downloader.cmd`.
2. Navegue pelo menu digitando os números das opções e confirme com a tecla *Enter*. 
3. Se for sua primeira vez, o script fará o diagnóstico e instalará o `yt-dlp` na pasta atual e o `FFmpeg` no sistema usando o WinGet. 
4. **Importante:** Se o FFmpeg for instalado pela primeira vez, o script informará se você precisa reabrir o terminal para que as alterações no PATH entrem em vigor.
5. Cole o link, escolha o formato e aguarde o download.

### 🐧/🍎 No Linux e macOS
1. Abra o terminal na pasta onde você baixou o script.
2. Execute o arquivo passando-o pelo bash:
   ```bash
   bash downloader.cmd
   ```
3. O script detectará seu sistema operacional e usará o gerenciador de pacotes correto (`apt` ou `brew`).