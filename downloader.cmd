: <<'---BATCH---'
@echo off
goto :BATCH
---BATCH---

#!/bin/bash

# Configurações padrão
OPT_SPONSOR="N"
OPT_SUBS="N"
OPT_METADATA="S"
SAVED_OUTDIR=""
SAVED_PLAYLIST=""

while true; do
    clear
    echo "=================================================="
    echo "          DOWNLOADER DE VÍDEOS (YT-DLP)           "
    echo "=================================================="
    echo ""
    echo "[1] Baixar Vídeos / Músicas"
    echo "[2] Limpeza (Apagar Mídias ou Desinstalar)"
    echo "[3] Configurações (SponsorBlock, Legendas, etc.)"
    echo "[4] Gerenciar Dependências (yt-dlp, FFmpeg)"
    echo "[5] Atualizar yt-dlp"
    echo "[6] Sair"
    echo ""
    read -p "Escolha uma opção (1-6): " opcao

    case $opcao in
        1)
            clear
            echo "--- ÁREA DE DOWNLOAD ---"
            echo "[SISTEMA] Iniciando diagnóstico do ambiente Linux/macOS..."
            
            # 1. Verifica yt-dlp
            echo "[*] Verificando 'yt-dlp'..."
            if ! command -v yt-dlp &> /dev/null; then
                echo "[!] yt-dlp NÃO ENCONTRADO."
                echo "[INFO] O 'yt-dlp' é a ferramenta que conecta ao YouTube."
                read -p "Deseja instalar o yt-dlp agora em '/usr/local/bin'? (S/N): " install_yt
                if [[ "$install_yt" =~ ^[SsYy] ]]; then
                    echo "[SISTEMA] Baixando yt-dlp oficial do GitHub..."
                    sudo curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
                    sudo chmod a+rx /usr/local/bin/yt-dlp
                    echo "[OK] yt-dlp instalado com sucesso."
                    read -p "Pressione ENTER para continuar..." dummy
                else
                    echo "[SISTEMA] Operação cancelada pelo usuário."
                    read -p "Pressione ENTER para voltar ao menu..." dummy
                    continue
                fi
            else
                echo "[OK] yt-dlp detectado."
            fi

            # 2. Verifica ffmpeg e ffprobe
            echo ""
            echo "[*] Verificando 'ffmpeg' e 'ffprobe'..."
            if ! command -v ffmpeg &> /dev/null || ! command -v ffprobe &> /dev/null; then
                echo "[!] FFmpeg e/ou FFprobe NÃO ENCONTRADOS."
                echo "[INFO] Necessários para unir vídeo/áudio e converter para MP3."
                read -p "Deseja instalar o pacote FFmpeg agora? (S/N): " install_ff
                if [[ "$install_ff" =~ ^[SsYy] ]]; then
                    echo "[SISTEMA] Acionando o gerenciador de pacotes local..."
                    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                        echo "[INFO] Usando apt-get..."
                        sudo apt-get update -qq && sudo apt-get install -y ffmpeg -qq
                    elif [[ "$OSTYPE" == "darwin"* ]]; then
                        echo "[INFO] Usando Homebrew..."
                        brew install ffmpeg -q
                    fi
                    echo "[OK] FFmpeg/FFprobe configurados."
                    read -p "Pressione ENTER para continuar..." dummy
                else
                    echo "[SISTEMA] Operação cancelada. Downloads podem falhar sem FFmpeg."
                    read -p "Pressione ENTER para continuar..." dummy
                fi
            else
                echo "[OK] Componentes de mídia detectados."
            fi

            echo ""
            if [ -z "$SAVED_OUTDIR" ]; then
                read -p "Onde deseja salvar os arquivos? (Ex: /home/user/Downloads): " outdir
                if [ -z "$outdir" ]; then
                    echo "[!] Caminho inválido."
                    read -p "Pressione ENTER para voltar ao menu..." dummy
                    continue
                fi
                SAVED_OUTDIR="$outdir"
            else
                outdir="$SAVED_OUTDIR"
                echo "[SISTEMA] Pasta de destino: $outdir"
            fi

            if [ ! -d "$outdir" ]; then
                echo "[SISTEMA] Criando pasta: $outdir"
                mkdir -p "$outdir"
            fi

            echo ""
            read -p "Cole o link do vídeo ou playlist: " url
            if [ -z "$url" ]; then
                echo "[!] Link inválido."
                read -p "Pressione ENTER para voltar ao menu..." dummy
                continue
            fi

            # Detecção de Playlist
            EXTRA_ARGS=""
            IS_PL_LINK="N"
            if [[ "$url" == *"list="* || "$url" == *"/playlist?"* ]]; then
                IS_PL_LINK="S"
            fi

            if [ "$IS_PL_LINK" == "S" ]; then
                if [ -z "$SAVED_PLAYLIST" ]; then
                    echo ""
                    echo "[?] O link parece ser uma playlist."
                    echo "[1] Baixar tudo (Playlist completa)"
                    echo "[2] Apenas o video do link"
                    read -p "Escolha (1/2): " pl_choice
                    SAVED_PLAYLIST="$pl_choice"
                fi
                
                if [ "$SAVED_PLAYLIST" == "1" ]; then
                    EXTRA_ARGS="$EXTRA_ARGS --yes-playlist"
                else
                    EXTRA_ARGS="$EXTRA_ARGS --no-playlist"
                fi
            else
                EXTRA_ARGS="$EXTRA_ARGS --no-playlist"
            fi

            echo ""
            echo "[1] Melhor Qualidade (Video + Audio - MP4)"
            echo "[2] Melhor Qualidade (Somente Video)"
            echo "[3] Qualidade Media / Leve (Ate 720p - MP4)"
            echo "[4] Apenas Audio (MP3)"
            read -p "Sua escolha (1/2/3/4): " qual

            if [ "$qual" == "1" ]; then
                FORMAT="bestvideo+bestaudio/best"
                EXTRA_ARGS="$EXTRA_ARGS --merge-output-format mp4"
            elif [ "$qual" == "2" ]; then
                FORMAT="bestvideo"
            elif [ "$qual" == "3" ]; then
                FORMAT="bestvideo[height<=720]+bestaudio/best[height<=720]/best"
                EXTRA_ARGS="$EXTRA_ARGS --merge-output-format mp4"
            elif [ "$qual" == "4" ]; then
                FORMAT="ba/b"
                EXTRA_ARGS="$EXTRA_ARGS --extract-audio --audio-format mp3 --audio-quality 0"
            else
                echo "[!] Opção inválida."
                read -p "Pressione ENTER para voltar ao menu..." dummy
                continue
            fi

            if [ "$OPT_SPONSOR" == "S" ]; then EXTRA_ARGS="$EXTRA_ARGS --sponsorblock-remove all"; fi
            if [ "$OPT_SUBS" == "S" ]; then EXTRA_ARGS="$EXTRA_ARGS --write-subs --embed-subs --sub-langs pt,en.*"; fi
            if [ "$OPT_METADATA" == "S" ]; then EXTRA_ARGS="$EXTRA_ARGS --add-metadata --embed-thumbnail"; fi

            echo ""
            echo "[SISTEMA] Iniciando download em: $outdir"
            
            # Garante que use o binário correto se acabou de ser instalado
            YTDLP_EXEC="yt-dlp"
            if [ -f "/usr/local/bin/yt-dlp" ]; then
                YTDLP_EXEC="/usr/local/bin/yt-dlp"
            fi

            if command -v ffmpeg &> /dev/null; then
                FFMPEG_LOC="--ffmpeg-location $(command -v ffmpeg)"
            else
                # Fallback para combined format se ffmpeg não for encontrado
                FORMAT="best"
            fi

            "$YTDLP_EXEC" -f "$FORMAT" $EXTRA_ARGS $FFMPEG_LOC -o "$outdir/%(uploader)s - %(title).150B.%(ext)s" --restrict-filenames --ignore-errors "$url"
            
            echo ""
            echo "[✓] Tarefa concluída!"
            read -p "Pressione ENTER para voltar ao menu..." dummy
            ;;
        2)
            while true; do
                clear
                echo "=================================================="
                echo "        ÁREA DE LIMPEZA E DESINSTALAÇÃO"
                echo "=================================================="
                echo "[1] Limpar APENAS Vídeos (.mp4, .webm)"
                echo "[2] Limpar APENAS Áudios (.mp3, .m4a)"
                echo "[3] Limpar TUDO (Vídeos + Áudios)"
                echo "[4] Desinstalar Ferramentas (yt-dlp, FFmpeg)"
                echo "[5] Voltar ao Menu Principal"
                echo ""
                read -p "Escolha uma opção (1-5): " op_limpa

                if [ "$op_limpa" == "1" ]; then
                    echo ""
                    read -p "Digite o caminho da pasta para excluir VÍDEOS: " limpadir
                    if [ -d "$limpadir" ]; then
                        echo "[SISTEMA] Limpando vídeos em $limpadir..."
                        rm -f "$limpadir"/*.mp4 "$limpadir"/*.webm 2>/dev/null
                        echo "[OK] Limpeza concluída."
                    else
                        echo "[!] A pasta não existe."
                    fi
                    read -p "Pressione ENTER para continuar..." dummy
                elif [ "$op_limpa" == "2" ]; then
                    echo ""
                    read -p "Digite o caminho da pasta para excluir ÁUDIOS: " limpadir
                    if [ -d "$limpadir" ]; then
                        echo "[SISTEMA] Limpando áudios em $limpadir..."
                        rm -f "$limpadir"/*.mp3 "$limpadir"/*.m4a 2>/dev/null
                        echo "[OK] Limpeza concluída."
                    else
                        echo "[!] A pasta não existe."
                    fi
                    read -p "Pressione ENTER para continuar..." dummy
                elif [ "$op_limpa" == "3" ]; then
                    echo ""
                    read -p "Digite o caminho da pasta para excluir TUDO: " limpadir
                    if [ -d "$limpadir" ]; then
                        echo "[SISTEMA] Limpando mídias em $limpadir..."
                        rm -f "$limpadir"/*.mp4 "$limpadir"/*.mp3 "$limpadir"/*.webm "$limpadir"/*.m4a 2>/dev/null
                        echo "[OK] Limpeza completa concluída."
                    else
                        echo "[!] A pasta não existe."
                    fi
                    read -p "Pressione ENTER para continuar..." dummy
                elif [ "$op_limpa" == "4" ]; then
                    echo ""
                    echo "[SISTEMA] --- DESINSTALAÇÃO ---"
                    echo "[INFO] Este processo removerá o yt-dlp e tentará remover o FFmpeg."
                    read -p "Tem certeza? (S/N): " confirma
                    if [[ ! "$confirma" =~ ^[SsYy] ]]; then continue; fi
                    
                    if [ -f "/usr/local/bin/yt-dlp" ]; then
                        echo "[SISTEMA] Apagando yt-dlp de /usr/local/bin..."
                        sudo rm -f /usr/local/bin/yt-dlp
                        echo "[OK] yt-dlp removido."
                    fi

                    echo "[SISTEMA] Removendo pacotes de mídia..."
                    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                        sudo apt-get remove -y ffmpeg -qq 2>/dev/null
                        sudo apt-get autoremove -y -qq 2>/dev/null
                    elif [[ "$OSTYPE" == "darwin"* ]]; then
                        brew uninstall ffmpeg -q 2>/dev/null
                    fi
                    echo "[OK] Tentativa de remoção concluída."
                    read -p "Pressione ENTER para continuar..." dummy
                elif [ "$op_limpa" == "5" ]; then
                    break
                fi
            done
            ;;
        3)
            while true; do
                clear
                echo "=================================================="
                echo "             CONFIGURAÇÕES DE DOWNLOAD"
                echo "=================================================="
                echo "[1] SponsorBlock (Pular Intros): [$OPT_SPONSOR]"
                echo "[2] Legendas (Baixar e Embutir): [$OPT_SUBS]"
                echo "[3] Metadados e Capa:            [$OPT_METADATA]"
                echo "[4] Resetar Pasta e Preferencias"
                echo "[5] Voltar ao Menu Principal"
                echo ""
                read -p "Escolha uma opção para alternar (1-5): " op_conf
                if [ "$op_conf" == "1" ]; then
                    if [ "$OPT_SPONSOR" == "S" ]; then OPT_SPONSOR="N"; else OPT_SPONSOR="S"; fi
                elif [ "$op_conf" == "2" ]; then
                    if [ "$OPT_SUBS" == "S" ]; then OPT_SUBS="N"; else OPT_SUBS="S"; fi
                elif [ "$op_conf" == "3" ]; then
                    if [ "$OPT_METADATA" == "S" ]; then OPT_METADATA="N"; else OPT_METADATA="S"; fi
                elif [ "$op_conf" == "4" ]; then
                    SAVED_OUTDIR=""
                    SAVED_PLAYLIST=""
                    echo "[OK] Configurações resetadas."
                    sleep 1
                elif [ "$op_conf" == "5" ]; then
                    break
                fi
            done
            ;;
        4)
            clear
            echo "--- GERENCIAR DEPENDÊNCIAS ---"
            
            # Verificação de yt-dlp
            if command -v yt-dlp &> /dev/null; then
                echo "[OK] yt-dlp: Instalado ($(yt-dlp --version))"
            else
                echo "[!] yt-dlp: NÃO ENCONTRADO"
            fi

            # Verificação de FFmpeg
            if command -v ffmpeg &> /dev/null; then
                echo "[OK] FFmpeg: Instalado"
            else
                echo "[!] FFmpeg: NÃO ENCONTRADO"
            fi

            echo ""
            echo "[1] Instalar/Atualizar yt-dlp"
            echo "[2] Instalar FFmpeg"
            echo "[3] Voltar"
            read -p "Escolha: " dep_op

            if [ "$dep_op" == "1" ]; then
                sudo curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
                sudo chmod a+rx /usr/local/bin/yt-dlp
                echo "[OK] yt-dlp processado."
            elif [ "$dep_op" == "2" ]; then
                if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                    sudo apt-get update -qq && sudo apt-get install -y ffmpeg -qq
                elif [[ "$OSTYPE" == "darwin"* ]]; then
                    brew install ffmpeg -q
                fi
                echo "[OK] FFmpeg processado."
            fi
            read -p "Pressione ENTER para continuar..." dummy
            ;;
        5)
            clear
            echo "[SISTEMA] Verificando atualizações para yt-dlp..."
            YTDLP_EXEC="yt-dlp"
            if [ -f "/usr/local/bin/yt-dlp" ]; then YTDLP_EXEC="/usr/local/bin/yt-dlp"; fi
            sudo "$YTDLP_EXEC" -U
            read -p "Pressione ENTER para continuar..." dummy
            ;;
        6)
            echo "Encerrando..."
            exit 0
            ;;
        *)
            echo "Opção inválida."
            sleep 1
            ;;
    esac
done
exit 0

:BATCH
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
if not defined OPT_SPONSOR set "OPT_SPONSOR=N"
if not defined OPT_SUBS set "OPT_SUBS=N"
if not defined OPT_METADATA set "OPT_METADATA=S"
if not defined SAVED_OUTDIR set "SAVED_OUTDIR="
if not defined SAVED_PLAYLIST set "SAVED_PLAYLIST="

:menu_principal
cls
echo ==================================================
echo           DOWNLOADER DE VIDEOS (YT-DLP)           
echo ==================================================
echo.
echo [1] Baixar Videos / Musicas
echo [2] Limpeza (Apagar Midias ou Desinstalar)
echo [3] Configuracoes (SponsorBlock, Legendas, etc.)
echo [4] Gerenciar Dependencias (yt-dlp, FFmpeg)
echo [5] Atualizar yt-dlp
echo [6] Sair
echo.
set "opcao="
set /p "opcao=Escolha uma opcao (1-6): "

if not defined opcao goto menu_principal
set "opcao=!opcao:"=!"

if "!opcao!"=="1" goto baixar_midia
if "!opcao!"=="2" goto menu_limpeza
if "!opcao!"=="3" goto menu_config
if "!opcao!"=="4" goto menu_deps
if "!opcao!"=="5" goto atualizar_ytdlp
if "!opcao!"=="6" exit /b
goto menu_principal

:baixar_midia
cls
echo --- AREA DE DOWNLOAD ---
call :check_internet
if errorlevel 1 (
    echo [!] Sem conexao com a internet.
    pause
    goto menu_principal
)

echo [SISTEMA] Iniciando diagnostico do ambiente...
call :check_dependencies
if errorlevel 1 (
    echo [!] Erro ao verificar dependencias.
    pause
    goto menu_principal
)

echo.
if not defined SAVED_OUTDIR (
    echo [DICA] Deixe em branco para abrir o seletor visual de pastas.
    set "outdir="
    set /p "outdir=Onde deseja salvar os arquivos? (ou ENTER para abrir seletor): "
    if not defined outdir (
        echo [SISTEMA] Abrindo seletor de pastas...
        for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Selecione a pasta para salvar os downloads'; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"`) do set "outdir=%%I"
    )
    if not defined outdir (
        echo [!] Nenhuma pasta selecionada ou caminho invalido.
        pause
        goto menu_principal
    )
    set "SAVED_OUTDIR=!outdir!"
) else (
    set "outdir=!SAVED_OUTDIR!"
    echo [SISTEMA] Pasta de destino: !outdir!
)
set "outdir=!outdir:"=!"

if not exist "!outdir!" (
    echo [SISTEMA] Criando pasta: !outdir!
    mkdir "!outdir!" 2>nul
    if not exist "!outdir!" (
        echo [!] Nao foi possivel criar a pasta.
        pause
        goto menu_principal
    )
)

echo.
set "url="
set /p "url=Cole o link do video ou playlist: "
if not defined url (
    echo [!] Link invalido.
    pause
    goto menu_principal
)
set "url=!url:"=!"

set "EXTRA_ARGS="
set "IS_PL_LINK=N"
echo "!url!" | findstr /i "list= /playlist?" >nul
if not errorlevel 1 set "IS_PL_LINK=S"

if "!IS_PL_LINK!"=="S" (
    if not defined SAVED_PLAYLIST (
        echo.
        echo [?] O link parece ser uma playlist.
        echo [1] Baixar tudo (Playlist completa)
        echo [2] Apenas o video do link
        set "pl_choice="
        set /p "pl_choice=Escolha (1/2): "
        if not defined pl_choice set "pl_choice=2"
        set "SAVED_PLAYLIST=!pl_choice!"
    )
    
    if "!SAVED_PLAYLIST!"=="1" (
        set EXTRA_ARGS=!EXTRA_ARGS! --yes-playlist
    ) else (
        set EXTRA_ARGS=!EXTRA_ARGS! --no-playlist
    )
) else (
    set EXTRA_ARGS=!EXTRA_ARGS! --no-playlist
)

echo.
echo [1] Melhor Qualidade (Video + Audio - MP4)
echo [2] Melhor Qualidade (Somente Video)
echo [3] Qualidade Media / Leve (Ate 720p - MP4)
echo [4] Apenas Audio (MP3)
set "qual="
set /p "qual=Sua escolha (1/2/3/4): "
if not defined qual goto menu_principal
set "qual=!qual:"=!"

set "FORMAT="

if "!qual!"=="1" (
    set "FORMAT=bestvideo+bestaudio/best"
    set EXTRA_ARGS=!EXTRA_ARGS! --merge-output-format mp4
) else (
    if "!qual!"=="2" (
        set "FORMAT=bestvideo"
    ) else (
        if "!qual!"=="3" (
            set "FORMAT=bestvideo[height<=720]+bestaudio/best[height<=720]/best"
            set EXTRA_ARGS=!EXTRA_ARGS! --merge-output-format mp4
        ) else (
            if "!qual!"=="4" (
                set "FORMAT=ba/b"
                set EXTRA_ARGS=!EXTRA_ARGS! --extract-audio --audio-format mp3 --audio-quality 0
            ) else (
                echo [!] Opcao invalida.
                pause
                goto menu_principal
            )
        )
    )
)

if "!OPT_SPONSOR!"=="S" set EXTRA_ARGS=!EXTRA_ARGS! --sponsorblock-remove all
if "!OPT_SUBS!"=="S" set EXTRA_ARGS=!EXTRA_ARGS! --write-subs --embed-subs --sub-langs "pt,en.*"
if "!OPT_METADATA!"=="S" set EXTRA_ARGS=!EXTRA_ARGS! --add-metadata --embed-thumbnail

set EXTRA_ARGS=!EXTRA_ARGS! --restrict-filenames

echo.
echo =================================
echo Preparando download...
echo =================================
echo.

if not exist "!YTDLP_BIN!" (
    set "YTDLP_BIN=yt-dlp"
)

set "FFMPEG_ARG="
if defined FFMPEG_PATH (
    set "FFMPEG_ARG=--ffmpeg-location "!FFMPEG_PATH!""
) else (
    rem Fallback para combined format se ffmpeg nao for encontrado
    if "!qual!"=="1" set "FORMAT=best"
    if "!qual!"=="3" set "FORMAT=best[height<=720]"
)

"!YTDLP_BIN!" -f "!FORMAT!" !EXTRA_ARGS! !FFMPEG_ARG! -o "!outdir!\%%(uploader)s - %%(title).150B.%%(ext)s" --ignore-errors "!url!"

if errorlevel 1 (
    echo.
    echo ======================================
    echo ERRO AO BAIXAR O VIDEO
    echo ======================================
    pause
) else (
    echo.
    echo [V] Download concluido!
    pause
)
goto menu_principal

:menu_limpeza
cls
echo ==================================================
echo        AREA DE LIMPEZA E DESINSTALACAO
echo ==================================================
echo [1] Limpar APENAS Videos (.mp4, .webm)
echo [2] Limpar APENAS Audios (.mp3, .m4a)
echo [3] Limpar TUDO (Videos + Audios)
echo [4] Desinstalar Ferramentas (yt-dlp, FFmpeg)
echo [5] Voltar ao Menu Principal
echo.
set "op_limpa="
set /p "op_limpa=Escolha uma opcao (1-5): "
if not defined op_limpa goto menu_limpeza
set "op_limpa=!op_limpa:"=!"

if "!op_limpa!"=="1" goto limpar_videos
if "!op_limpa!"=="2" goto limpar_audios
if "!op_limpa!"=="3" goto limpar_tudo
if "!op_limpa!"=="4" goto desinstalar_ferramentas
if "!op_limpa!"=="5" goto menu_principal
goto menu_limpeza

:limpar_videos
echo.
set "limpadir="
set /p "limpadir=Digite o caminho da pasta: "
if not defined limpadir goto menu_limpeza
set "limpadir=!limpadir:"=!"
if exist "!limpadir!" (
    del /q "!limpadir!\*.mp4" 2>nul
    del /q "!limpadir!\*.webm" 2>nul
    echo [OK] Limpeza concluida.
) else (
    echo [!] A pasta nao existe.
)
pause
goto menu_limpeza

:limpar_audios
echo.
set "limpadir="
set /p "limpadir=Digite o caminho da pasta: "
if not defined limpadir goto menu_limpeza
set "limpadir=!limpadir:"=!"
if exist "!limpadir!" (
    del /q "!limpadir!\*.mp3" 2>nul
    del /q "!limpadir!\*.m4a" 2>nul
    echo [OK] Limpeza concluida.
) else (
    echo [!] A pasta nao existe.
)
pause
goto menu_limpeza

:limpar_tudo
echo.
set "limpadir="
set /p "limpadir=Digite o caminho da pasta: "
if not defined limpadir goto menu_limpeza
set "limpadir=!limpadir:"=!"
if exist "!limpadir!" (
    del /q "!limpadir!\*.mp4" 2>nul
    del /q "!limpadir!\*.mp3" 2>nul
    del /q "!limpadir!\*.webm" 2>nul
    del /q "!limpadir!\*.m4a" 2>nul
    echo [OK] Limpeza completa concluida.
) else (
    echo [!] A pasta nao existe.
)
pause
goto menu_limpeza

:desinstalar_ferramentas
echo.
echo [SISTEMA] --- DESINSTALACAO ---
set /p "confirma=Tem certeza? (S/N): "
if not defined confirma goto menu_limpeza
set "confirma=!confirma:"=!"
if /i not "!confirma!"=="S" goto menu_limpeza

if exist "yt-dlp.exe" (
    del /q yt-dlp.exe
    echo [OK] yt-dlp removido.
)
where winget >nul 2>nul
if not errorlevel 1 (
    echo [AVISO] Uma janela do Windows (UAC) pode aparecer.
    cmd /c "winget uninstall --id=Gyan.FFmpeg --silent" || cmd /c "winget uninstall --id=Gyan.FFmpeg"
) else (
    echo [!] 'winget' nao encontrado. Nao foi possivel desinstalar o FFmpeg automaticamente.
)
echo.
echo [SISTEMA] Processo de limpeza/desinstalacao concluido.
pause
goto menu_limpeza

:menu_config
cls
echo ==================================================
echo             CONFIGURACOES DE DOWNLOAD
echo ==================================================
echo [1] SponsorBlock (Pular Intros/Sponsors): [!OPT_SPONSOR!]
echo [2] Legendas (Baixar e Embutir pt/en):    [!OPT_SUBS!]
echo [3] Metadados e Capa (Thumbnails):       [!OPT_METADATA!]
echo [4] Resetar Pasta e Preferencias
echo [5] Voltar
echo.
set "opc="
set /p "opc=Escolha uma opcao para alternar (1-5): "
if "!opc!"=="1" (
    if "!OPT_SPONSOR!"=="S" (set "OPT_SPONSOR=N") else (set "OPT_SPONSOR=S")
    goto menu_config
)
if "!opc!"=="2" (
    if "!OPT_SUBS!"=="S" (set "OPT_SUBS=N") else (set "OPT_SUBS=S")
    goto menu_config
)
if "!opc!"=="3" (
    if "!OPT_METADATA!"=="S" (set "OPT_METADATA=N") else (set "OPT_METADATA=S")
    goto menu_config
)
if "!opc!"=="4" (
    set "SAVED_OUTDIR="
    set "SAVED_PLAYLIST="
    echo [OK] Configuracoes resetadas.
    timeout /t 1 >nul
    goto menu_config
)
goto menu_principal

:menu_deps
cls
echo ==================================================
echo             GERENCIAR DEPENDENCIAS
echo ==================================================
echo.

set "YT_STATUS=[!] NAO ENCONTRADO"
where yt-dlp >nul 2>nul
if not errorlevel 1 (
    for /f "tokens=*" %%v in ('yt-dlp --version') do set "YT_STATUS=[OK] Instalado (%%v)"
) else (
    if exist "yt-dlp.exe" (
        for /f "tokens=*" %%v in ('.\yt-dlp.exe --version') do set "YT_STATUS=[OK] Local (%%v)"
    )
)

set "FF_STATUS=[!] NAO ENCONTRADO"
where ffmpeg >nul 2>nul
if not errorlevel 1 (
    set "FF_STATUS=[OK] Instalado"
) else (
    if defined FFMPEG_PATH (
        if exist "!FFMPEG_PATH!" set "FF_STATUS=[OK] Detectado em Path Custom"
    )
)

echo yt-dlp: !YT_STATUS!
echo FFmpeg: !FF_STATUS!
echo.
echo [1] Instalar/Atualizar yt-dlp (.exe local)
echo [2] Instalar FFmpeg (via WinGet)
echo [3] Voltar
echo.
set "dep_op="
set /p "dep_op=Escolha: "

if "!dep_op!"=="1" (
    echo [SISTEMA] Baixando yt-dlp...
    curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
    echo [OK] yt-dlp.exe baixado/atualizado.
    pause
    goto menu_deps
)
if "!dep_op!"=="2" (
    echo [SISTEMA] Tentando instalar FFmpeg via WinGet...
    cmd /c "winget install --id=Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements"
    pause
    goto menu_deps
)
goto menu_principal

:atualizar_ytdlp
cls
echo [SISTEMA] Verificando atualizacoes para yt-dlp...
if not exist "!YTDLP_BIN!" set "YTDLP_BIN=yt-dlp"
call "!YTDLP_BIN!" -U
echo.
pause
goto menu_principal

:check_internet
ping -n 1 github.com >nul 2>&1
if errorlevel 1 exit /b 1
exit /b 0

:check_dependencies
where curl >nul 2>nul
if errorlevel 1 exit /b 1

set "FFMPEG_PATH="
where ffmpeg >nul 2>nul
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('where ffmpeg') do set "FFMPEG_PATH=%%i"
)

where yt-dlp >nul 2>nul
if not errorlevel 1 (
    set "YTDLP_BIN=yt-dlp"
) else (
    if exist "yt-dlp.exe" (
        set "YTDLP_BIN=.\yt-dlp.exe"
    ) else (
        echo [!] yt-dlp nao encontrado.
        set /p "inst=Baixar agora? (S/N): "
        if /i "!inst!"=="S" (
            curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe -o yt-dlp.exe
            set "YTDLP_BIN=.\yt-dlp.exe"
        ) else (
            exit /b 1
        )
    )
)

if not defined FFMPEG_PATH (
    if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe" (
        set "FFMPEG_PATH=%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe"
        set "PATH=!PATH!;%LOCALAPPDATA%\Microsoft\WinGet\Links"
    ) else (
        echo [!] FFmpeg nao encontrado.
        echo [INFO] Sem o FFmpeg, videos podem ser baixados sem som ou em baixa qualidade.
        set /p "instf=Instalar FFmpeg via WinGet? (S/N): "
        if /i "!instf!"=="S" (
            cmd /c "winget install --id=Gyan.FFmpeg -e --accept-package-agreements --accept-source-agreements"
            if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe" (
                set "FFMPEG_PATH=%LOCALAPPDATA%\Microsoft\WinGet\Links\ffmpeg.exe"
                set "PATH=!PATH!;%LOCALAPPDATA%\Microsoft\WinGet\Links"
            )
        )
    )
)
exit /b 0
