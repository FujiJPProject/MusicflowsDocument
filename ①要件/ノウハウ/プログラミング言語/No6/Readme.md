# 第6部：並行処理と非同期処理

## 1. 並行性・並列性・スケジューリング

学ぶ内容：

- プロセスとスレッド
- OSスレッドとユーザースレッド
- タスクとコルーチン
- 並行性と並列性
- プリエンプティブと協調的スケジューリング
- CPU-boundとI/O-bound
- スレッドプール

## 2. 共有メモリ・同期・メモリモデル

学ぶ内容：

- mutexとsemaphore
- read-write lock
- atomic operation
- critical section
- race condition
- deadlock、livelock、starvation
- happens-before
- 可視性と順序性
- sequential consistency
- relaxed ordering

## 3. メッセージパッシング・CSP・Actor

学ぶ内容：

- メッセージパッシング
- channel
- send・receive
- buffered channel
- select
- CSP
- Actor model
- shared-nothing
- 所有権移動による通信

## 4. Future・Promise・コルーチン・構造化並行性

学ぶ内容：

- Future、Promise、Task
- coroutine
- async/await
- 非同期関数の状態機械変換
- キャンセルとタイムアウト
- 構造化並行性
- backpressure
- 非同期エラー伝播
