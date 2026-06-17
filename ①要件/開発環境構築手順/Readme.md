# 開発環境構築手順

## 前提

- 端末のOSはWindows11(Ubuntuをインストールできる環境さえあればよい)
- Githubアカウントを持っていること
- VSCodeはインストール済み

## 【1】WSLの構築

※Windows環境でない場合はVirtual Box等仮想化ソフトをインストールし、その上にUbuntu24.04をインストール

1. Windows PowerShellを開き、下記コマンドを実行。

```shell
wsl --install -d Ubuntu-24.04 --name MusicBlocksBase
```

2. 実行後はユーザー名とパスワードを設定する

![WSLインストール](./images/WSLインストール.png)

コマンド一覧

| 使用用途                    | コマンド               |
| :-------------------------- | :--------------------- |
| WSL上のUbuntuから抜ける     | exit                   |
| WSLの状態とバージョンを見る | wsl -l -v              |
| 指定のWSLを停止             | wsl -t MusicBlocksBase |
| 　指定のWSLを起動           | wsl -d MusicBlocksBase |

## 【2】Dockerの導入

1. 実行用のフォルダを/home/ユーザー名配下に作成

```shell
cd ~
mkdir setup
cd setup
```

2. setup-docker.shを作成

```shell
vi setup-docker.sh
```

3. 「開発環境構築手順」フォルダにある「setup-docker.sh」の内容をコピーして貼り付けし「:wq」で保存

4. 実行権限を付与

```shell
chmod +x setup-docker.sh
ls -l
```

5. Docker環境構築シェルを実行

```shell
./setup-docker.sh
```

<details>

<summary>setup-docker.shのフロー</summary>

![Docker構築](./images/setup-docker.drawio.png)

</details>

6. MusicBlocksBaseからログアウトして再起動

```shell
exit
wsl -t MusicBlocksBase
wsl -l -v
wsl -d MusicBlocksBase
```

## 【3-1】Gitの導入とプロジェクトの導入(gitで管理しない場合は3-2)

1. setupフォルダに移動

```shell
cd ~/setup
```

2. setup-git.shを作成

```shell
vi setup-git.sh
```

3. 「開発環境構築手順」フォルダにある「setup-git.sh」の内容をコピーして貼り付けし「:wq」で保存

4. 実行権限を付与

```shell
chmod +x setup-git.sh
ls -l
```

5. Git環境構築シェルを実行、「user.name」「user.email」にそれぞれGithubアカウントのユーザー名とemailアドレスを設定。それ以降はEnterでよい

```shell
./setup-git.sh
```

<details>

<summary>setup-git.shのフロー</summary>

![Git構築](./images/setup-git.drawio.png)

</details>

6. 実行後に表示されている公開鍵をコピー※「ssh-ed25519 XXXX」

7. Githubアカウントのアカウントアイコンを右クリック→「Settings」→「SSH and GPG keys」→「New SSH key」

![Github画像1](./images/Github画像1.png)

8. titleと6でコピーしたSSHキーを入力

![Github画像2](./images/Github画像2.png)

9. 下記接続確認コマンドを実行

```shell
ssh -T git@github.com
```

下記内容が表示されていればOK

「Hi ユーザー名! You've successfully authenticated～.」

10. クローン先のフォルダを作成

```shell
mkdir ~/music-app
mkdir ~/music-infra
```

11. Git Clone

※TODO 記載予定

## 【3-2】プロジェクトの導入(3-1実施済みの場合は不要)

1. WSLの/home/ユーザー名配下にmusic-app、music-infraを配置

## 【4】JDKインストール

VSCode上での開発に必要

1. setupフォルダに移動

```shell
cd ~/setup
```

2. setup-jdk25-gradlek.shを作成

```shell
vi setup-jdk25-gradle.sh
```

3. 「開発環境構築手順」フォルダにある「setup-jdk25-gradle.sh」の内容をコピーして貼り付けし「:wq」で保存

4. 実行権限を付与

```shell
chmod +x setup-jdk25-gradle.sh
ls -l
```

5. JDK,Gradleをインストール

```shell
./setup-jdk25-gradle.sh
```

6. バージョン,環境変数の確認。表示されていればOK

```
source ~/.bashrc
java -version
javac -version
gradle --version
echo $JAVA_HOME
echo $GRADLE_HOME
```

## 【5】WSL連携

※【１】で仮想マシンでの構築の場合はVSCodeに拡張機能 Remote - SSH導入後

1. VSCodeの拡張機能からWSLをインストール

![WSL1](./images/WSL連携1.png)

2. 「><」→「ディストリビューションを使用してWSLに接続」

![WSL2](./images/WSL連携2.png)

3. MusicBlocksBaseを選択

![WSL3](./images/WSL連携3.png)

4. 「表示」→「ターミナル」でコマンド操作可能

![WSL4](./images/WSL連携4.png)

## 【6】コンテナ起動

### 初回

1. プロジェクトに移動

```shell
cd ~/music-app
```

2. node_moduleの生成

```shell
docker run --rm -it -v "$PWD/frontend:/app" -w /app node:24-bookworm npm install
```

3. Spring Boot通常APIのビルド確認

```shell
   docker compose build backend
   # jarファイル生成
   docker compose run --rm backend ./gradlew clean bootJar
   # lambdaデプロイ用
   docker compose run --rm backend ./gradlew clean buildLambdaZip
```

4. 権限の付与

```shell
mkdir ./frontend/public/config
chmod -R 777 ./frontend/public/config
```

5. PostgreSQL / Floci起動

```shell
docker compose up -d postgres floci
```

6. React起動

```shell
   docker compose up -d frontend
```

### 2回目以降

```shell
docker compose up -d
```

## 【7】バックエンド用setup.jsonの作成

1. VSCodeにて下記拡張機能のインストール

- Extension Pack for Java
- Spring boot Extension Pack

2. /backendフォルダに.vscode/settings.jsonを作成

3. settings.jsonファイルに下記内容を記載

<details>

<summary>settings.json</summary>

```json
{
  // ------------------------------------------------------------
  // Java / JDK
  // ------------------------------------------------------------
  "java.jdt.ls.java.home": "/usr/lib/jvm/temurin-25-jdk-amd64",

  "java.configuration.runtimes": [
    {
      "name": "JavaSE-25",
      "path": "/usr/lib/jvm/temurin-25-jdk-amd64",
      "default": true
    }
  ],

  // ------------------------------------------------------------
  // Gradle
  // ------------------------------------------------------------
  "java.import.gradle.enabled": true,
  "java.import.gradle.wrapper.enabled": true,
  "java.import.gradle.java.home": "/usr/lib/jvm/temurin-25-jdk-amd64",
  "java.configuration.updateBuildConfiguration": "automatic",

  // ------------------------------------------------------------
  // 保存時の自動整形
  // ------------------------------------------------------------
  "editor.formatOnSave": true,
  "java.format.enabled": true,

  // ------------------------------------------------------------
  // 保存時の import 整理
  // ------------------------------------------------------------
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit"
  },

  // ------------------------------------------------------------
  // null / 非推奨APIなどの警告
  // ------------------------------------------------------------
  "java.compile.nullAnalysis.mode": "automatic",

  // ------------------------------------------------------------
  // テスト
  // ------------------------------------------------------------
  "java.test.config": [
    {
      "name": "default",
      "workingDirectory": "${workspaceFolder}"
    }
  ],

  // ------------------------------------------------------------
  // ファイル監視の除外
  // ------------------------------------------------------------
  "files.watcherExclude": {
    "**/.gradle/**": true,
    "**/build/**": true,
    "**/node_modules/**": true
  },

  "search.exclude": {
    "**/.gradle": true,
    "**/build": true,
    "**/node_modules": true
  }
}
```

</details>

4. VSCode再起動
