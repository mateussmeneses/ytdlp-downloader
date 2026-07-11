# Transparent Auto Downloader (yt-dlp) 🎥

Um script automatizado, interativo e **em arquivo único** (`.cmd`) para baixar vídeos e playlists do YouTube sem complicações. 

O foco deste projeto é a **Transparência e a Fluidez**. O programa roda através do terminal de comandos explicando cada ação e opera em um **Loop Contínuo** — ele nunca fechará sozinho a menos que você escolha a opção "Sair".

## ✨ Funcionalidades Atuais

* **Loop Contínuo:** O menu não fecha após downloads ou instalações.
* **Script Poliglota (Single-file):** O arquivo `downloader.cmd` funciona nativamente como Batch no Windows e como Bash no Linux/macOS.
* **Seleção Visual de Pasta (Windows):** Ao baixar, você pode abrir um seletor de pastas nativo do Windows para escolher o destino.
* **Padronização de Nomes:** Arquivos são salvos automaticamente no formato `Nome do Canal - Título do Vídeo`.
* **Detecção Inteligente de Playlists:** O script identifica se o link é de um vídeo único ou playlist e pergunta como proceder apenas quando necessário.
* **Persistência de Sessão:** Suas escolhas de pasta e preferência de playlist são lembradas enquanto o programa estiver aberto.
* **Auto-instalação:** Gerencia automaticamente o `yt-dlp` e o `FFmpeg` (via `winget`, `apt` ou `brew`).
* **Atualização Integrada:** Opção no menu para atualizar o motor de download (`yt-dlp`) sem sair do script.

## ⚙️ Opções de Download e Configurações

Você pode personalizar seus downloads através do menu de Configurações:
* **SponsorBlock:** Pula automaticamente segmentos de patrocínio, intros e lembretes de inscrição.
* **Legendas:** Opção para baixar e embutir legendas (PT/EN) diretamente no arquivo.
* **Metadados:** Adiciona capas (thumbnails) e informações detalhadas (título, artista, data) ao arquivo final.
* **Qualidades Disponíveis:**
  - Melhor Qualidade (Vídeo + Áudio - MP4)
  - Melhor Qualidade (Somente Vídeo)
  - Qualidade Média (Até 720p - MP4)
  - Apenas Áudio (MP3 de alta qualidade)

## 🧹 Área de Limpeza

* **Limpeza Seletiva:** Apague apenas vídeos, apenas áudios ou todos os arquivos de mídia de uma pasta específica.
* **Desinstalação Limpa:** Remove o `yt-dlp` e tenta desinstalar o `FFmpeg` do sistema de forma automatizada.

## 🚀 Como usar

### 🪟 No Windows
1. Baixe o `downloader.cmd`.
2. Dê um **duplo clique** para iniciar.
3. Use o menu numérico para navegar.

### 🐧/🍎 No Linux e macOS
1. Abra o terminal.
2. Execute: `bash downloader.cmd`

## 🛠️ Requisitos
O script tentará instalar estes itens automaticamente se não forem encontrados:
* `yt-dlp` (Motor de download)
* `FFmpeg` (Para conversão e união de arquivos)
* `curl` (Para baixar as ferramentas)