<p align="center">
  <img src="logo.png" alt="Bodhiblark" width="520">
</p>

<h3 align="center">Backup dos saves dos seus emuladores no Google Drive.</h3>

---

## O que é

Uma página que roda no seu computador e guarda os saves dos seus emuladores (memory cards, save states, saves de jogos) no seu Google Drive. Você escolhe as pastas uma vez e depois é só clicar em **Salvar saves no Drive**. Se perder um save, traz de volta na aba **Drive**.

Funciona com qualquer emulador, porque você aponta a pasta de saves de cada um: PCSX2, DuckStation, PPSSPP, Dolphin, RetroArch, RPCS3, MAME e outros.

## O que ela faz

- **Backup incremental:** mantém no Drive uma cópia espelhada das suas pastas e envia só o que mudou. O segundo backup em diante leva segundos.
- **Conferência de integridade:** depois de cada envio, compara o tamanho e o MD5 do arquivo com o que o Drive guardou. Se vier diferente, envia de novo.
- **Snapshots em .zip:** se quiser, também cria uma fotografia completa com data e hora, e apaga as mais antigas.
- **Tudo numa aba só, sem abrir o Google Drive:** a aba **Drive** mostra o que está guardado, em pastas. Dali você baixa, restaura nas pastas dos emuladores, vê versões antigas e apaga.
- **Restaurar:** traz de volta um arquivo, uma pasta, um emulador, um computador inteiro ou um snapshot, nas suas pastas ou numa pasta nova. Antes de trocar qualquer arquivo, guarda o atual numa pasta `_restore-backup`, então nada se perde.
- **Vários computadores:** cada computador tem o próprio nome e a própria pasta no Drive.
- **Proteção contra arquivo em uso:** se o emulador gravar um save enquanto ele está subindo, o programa percebe, envia de novo a versão nova e avisa no registro. Se o arquivo não parar de mudar, ele falha com uma mensagem pedindo para fechar o emulador, em vez de guardar uma cópia pela metade.
- **Histórico:** lista os últimos backups e restaurações, com data, resumo e se houve falha. Continua guardado depois de fechar a página.
- **Avisos do Windows:** opcional. Avisa quando um backup termina ou falha, sem incomodar quando você está olhando a página.
- **Backup automático em tempo real:** confere as pastas a cada poucos segundos (mínimo 5) enquanto a página estiver aberta e envia só o que mudou, depois que o arquivo para de mudar. Sem mudança, não envia nada. Quando a sessão do Google expira, o programa tenta renovar sozinho, sem janela. Só pede para você reconectar se o Google não deixar.
- **Ver o que mudou:** mostra o que seria enviado, sem enviar nada.

## Requisitos

- Windows
- Google Chrome ou Microsoft Edge (outros navegadores não deixam escolher pastas)
- Uma conta Google
- Um Client ID do Google (grátis, criado uma vez só, passo a passo abaixo)

## Instalação

1. Baixe os arquivos e deixe todos na mesma pasta:
   - `index.html`
   - `servidor.ps1`
   - `iniciar.bat`
2. Dê dois cliques em `iniciar.bat`. Ele abre a página em `http://localhost:8080`.

> O login do Google não funciona abrindo o `index.html` direto no navegador. Por isso existe o `iniciar.bat`, que liga um servidor local bem simples. Deixe a janela preta aberta enquanto usa o programa.

## Criando o Client ID do Google (uma vez só)

1. Acesse o [Google Cloud Console](https://console.cloud.google.com) e crie um projeto.
2. Em **APIs e serviços**, ative a **Google Drive API**.
3. Em **Google Auth Platform**, configure a tela de consentimento como **Externo**.
4. Em **Público-alvo**, adicione o seu e-mail como **usuário de teste** (ou clique em **Publicar app**).
5. Em **Acesso a dados**, adicione o escopo `https://www.googleapis.com/auth/drive.file`.
6. Em **Credenciais**, crie um **ID do cliente OAuth** do tipo **Aplicativo da Web**.
7. Em **Origens JavaScript autorizadas**, adicione `http://localhost:8080` e salve.
8. Copie o **Client ID** e cole na aba **Ajustes** do programa.

Depois de colar o Client ID, clique em **Testar conexão** (aba Ajustes). O programa confere o formato do ID, o endereço da página, o login, a permissão do Drive e se a Google Drive API está ativa, e diz exatamente qual passo falhou.

Só o Client ID é usado. A chave secreta do cliente não é necessária, então não cole ela em lugar nenhum.

## Usando

1. Na aba **Ajustes**, cole o Client ID. Dê um nome ao computador e escolha o tipo de backup.
2. Na aba **Backup**, clique em **Conectar ao Google Drive**.
3. Clique em **Adicionar outra pasta**, dê um nome (por exemplo PCSX2) e escolha a pasta de saves do emulador.
4. Clique em **Salvar saves no Drive**.

### Onde ficam os arquivos no Drive

```
Backups-Emuladores/
└── Meu-PC/
    ├── PCSX2/          última versão de cada arquivo
    ├── DuckStation/
    └── Snapshots/      saves-2026-10-10_19-30-00.zip, ...
```

Backups feitos em versões antigas, que ficavam dentro de uma pasta `Espelho`, são arrumados sozinhos no primeiro backup: os arquivos sobem um nível e nada é enviado de novo.

### Vendo, baixando e restaurando

Na aba **Drive**, clique em **Buscar no Drive** (se já estiver conectado, ela lista sozinha). Navegue pelas pastas como num explorador de arquivos. Cada linha tem os botões que fazem sentido para ela:

- **Baixar:** um arquivo vai direto para a pasta de downloads. Em uma pasta, **Baixar .zip** junta tudo num .zip com a mesma estrutura de pastas.
- **Restaurar:** coloca de volta na pasta do emulador. Funciona em um arquivo, numa subpasta, na pasta de um emulador, num computador inteiro ou num snapshot. Você escolhe entre as suas pastas configuradas e uma pasta nova.
- **Versões:** mostra as versões antigas de um arquivo (o Drive guarda por cerca de 30 dias) e deixa baixar qualquer uma. Útil quando um save foi sobrescrito.
- **Apagar:** remove do Drive para sempre, depois de pedir confirmação. Não vai para a lixeira. Os arquivos do seu computador não são tocados. Se apagar uma pasta de emulador, o próximo backup envia tudo dela de novo.
- **Filtrar:** o campo de busca filtra pelo nome na pasta aberta.

Como a restauração funciona:

1. Feche o emulador.
2. Clique em **Restaurar** na linha que você quer trazer de volta e escolha o destino.
3. Os arquivos que já estão iguais são pulados. Os que forem trocados vão antes para `_restore-backup-<data>`, na pasta do emulador.

O topo da aba mostra quantos arquivos e quanto espaço os backups ocupam no seu Drive. O programa só enxerga o que ele mesmo enviou.

## Tipos de backup

| Tipo | Como funciona | Quando usar |
| --- | --- | --- |
| Incremental | Espelha as pastas e envia só o que mudou | O dia a dia. É o recomendado. |
| Snapshot em .zip | Um .zip completo a cada vez | Se você quer um histórico por data. |
| Os dois juntos | Incremental e .zip | O mais seguro, e o que mais ocupa espaço. |

No backup automático, o snapshot .zip sai no máximo a cada 30 minutos; para salvar o tempo todo enquanto joga, use o tipo Incremental.

O Drive guarda por cerca de 30 dias as versões antigas dos arquivos das pastas dos emuladores. Para um histórico mais longo, use snapshots.

## Ajustes úteis

- **Testar conexão:** diagnostica o login do Google passo a passo, com a causa provável de cada erro.
- **Avisos:** liga os avisos do Windows para backups concluídos ou com falha.
- **Exportar e importar ajustes:** salva o Client ID, os nomes e as opções num arquivo `.json`, para configurar outro computador rapidamente. O nome do computador e os caminhos das pastas não vão no arquivo: no outro computador você escolhe a pasta de cada emulador de novo.
- **Copiar diagnóstico:** copia um resumo (versão, navegador, ajustes, últimos backups e linhas do registro) para colar quando precisar de ajuda. O Client ID aparece quase todo escondido.

## Onde ficam os saves de cada emulador

Os caminhos mudam conforme a instalação (modo portátil, por exemplo). Os mais comuns:

| Emulador | Pasta |
| --- | --- |
| PCSX2 | `Documentos\PCSX2` (memcards e sstates) |
| DuckStation | `Documentos\DuckStation` (memcards e savestates) |
| PPSSPP | `Documentos\PPSSPP\memstick\PSP\SAVEDATA` e `PPSSPP_STATE` |
| Dolphin | `%APPDATA%\Dolphin Emulator` |
| RetroArch | pastas `saves` e `states` |
| RPCS3 | `dev_hdd0\home\00000001\savedata` |

## Privacidade e segurança

- O programa usa só o acesso `drive.file`: ele enxerga apenas os arquivos que ele mesmo criou no seu Drive, nunca o resto.
- Tudo acontece entre o seu navegador e o Google. Não existe servidor de terceiros.
- O Client ID, as configurações e as pastas escolhidas ficam guardados só no seu navegador.

## Limitações

- O Chrome bloqueia algumas pastas de sistema, como `AppData`. Escolha uma subpasta mais específica ou use o modo portátil do emulador.
- O navegador só trabalha com a página aberta. O backup automático não roda com a página fechada.
- A sessão do Google dura cerca de 1 hora. O programa tenta renovar sozinho; se o Google não deixar, o backup automático pausa e aparece um botão para reconectar. Na hora de salvar ou restaurar manualmente, o login é renovado sozinho.
- O snapshot .zip é montado na memória do navegador. Acima de 1,5 GB ele é ignorado (no tipo "Os dois juntos") ou dá erro (no tipo "Snapshot em .zip"). O backup incremental não tem esse limite.
- Duas pastas de emuladores não podem ter o mesmo nome. O programa recusa o nome repetido.
- O programa funciona sem internet para a parte do .zip: a biblioteca vem dentro do `index.html`.
- Baixar uma pasta inteira em .zip também passa pela memória e tem o mesmo limite de 1,5 GB. Acima disso, baixe as subpastas separadas.
- O navegador pede permissão de leitura das pastas toda vez que a página é aberta.

## Problemas comuns

| Erro | Causa provável |
| --- | --- |
| `400: invalid_request` | A origem `http://localhost:8080` não foi salva no Client ID, ou o tipo do ID não é "Aplicativo da Web". Pode levar alguns minutos para valer. |
| `403: access_denied` | O seu e-mail não está como usuário de teste, ou falta o escopo `drive.file`. Publicar o app resolve. |
| "Não consegui abrir a porta 8080" | O programa já está aberto em outra janela. Feche a outra e tente de novo. |
| Pasta recusada | O navegador bloqueou a pasta. Escolha uma subpasta mais específica. |
| Não sei qual passo do Google deu errado | Use **Testar conexão** nos Ajustes. Ele mostra o passo que falhou e como corrigir. |
| "O arquivo continua mudando durante o envio" | O emulador está gravando esse arquivo. Feche o emulador e salve de novo. |

---

<p align="center"><sub>Feito por Bodhiblark</sub></p>

## Versão .exe (opcional)

Na pasta `exe` há o necessário para gerar o `BodhiblarkSaves.exe`: dê dois cliques em `criar-exe.bat`. O programa abre numa janela própria e fica com um ícone perto do relógio do Windows. Clique com o botão direito no ícone e marque **Iniciar com o Windows** para ele abrir sozinho, minimizado, quando o computador ligar. O backup automático continua precisando da janela aberta (pode deixar minimizada). Na primeira vez, no aviso de permissão das pastas, escolha **Permitir em todas as visitas**, se o Chrome oferecer.
