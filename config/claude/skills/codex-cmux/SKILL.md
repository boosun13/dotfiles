---
name: codex-cmux
description: cmux 上で動いている Codex のメインセッション（OpenAI Codex CLI の TUI）に指示を送り、その回答を Claude のメインセッションで受け取る。ユーザーが「Codex に聞いて」「Codex と会話して」「Codex に挨拶して」「Codex にレビューさせて」など Codex とのやり取りを求めたときに使う。Codex が開いていなければ cmux で Claude のペインを右に分割して自動起動する。codex exec で新しい Codex を立ち上げる方法や codex-* サブエージェントより、こちらを優先する。
---

# codex-cmux

cmux のターミナル機能で、すでに起動している Codex のメインセッションとやり取りする。cmux TUI（`cmux terminal write` / `screen read` / `tab create`）と macOS の cmux アプリ（`cmux send` / `read-screen` / `new-split`、surface 単位）の両方に対応し、`CMUX_TUI_SOCKET` があれば TUI、無く `CMUX_SOCKET_PATH` があればアプリとして動く。engineering-harness の `codex-run` も、cmux の中ではこのスクリプトを使う。

## 使い方

```bash
S=~/.claude/skills/codex-cmux/scripts/codex-cmux
$S ask "Codex への指示"        # 送信して最終回答を標準出力に出す
$S ask --timeout 1800 "重い依頼"  # 回答待ちの上限（秒、既定 900）
$S find                        # Codex のターミナル ID（無ければ終了コード 1）
$S ensure                      # 無ければ Claude の右に分割ペイン「Codex」を開いて起動

# ハーネス用（codex-run が使う）: 名前付きタブの Codex を使い、依頼ごとに /new で会話を新しくする
$S ask --session codex-sol-medium-rw --codex-args "-m gpt-6.1-sol -s workspace-write -a never" --fresh "…"
```

- 長い依頼や時間のかかる依頼は Bash の `run_in_background` で実行し、完了通知を待つ。
- 改行を含む文もそのまま 1 メッセージとして送れる（TUI は bracketed paste、アプリは `cmux rpc terminal.paste`）。
- 返ってきた回答は要点をユーザーに伝える。Codex の回答をそのまま事実として扱わず、必要なら裏を取る。

## 仕組みと注意

- **Codex の特定**: cmux の稼働中ターミナルのうち、子孫プロセスに `@openai/codex` を持つものを Codex とみなす（自分のターミナル `$CMUX_TUI_TERMINAL_ID`、アプリでは `$CMUX_SURFACE_ID` は除外）。アプリでは `cmux tree` の surface の tty で `ps -t` を引いて判定し、タブ名は surface のタイトルを使う。`--session` 無しのときは、名前が `codex-` で始まるハーネス用タブを除いて探す。
- **順番待ち**: 同じタブへの依頼は `~/.cache/codex-cmux/<タブ名>.lock` のロックで 1 件ずつ処理する。
- **`/new`**: Git リポジトリ内では新しい会話の場所（worktree）を聞かれるので、既定の「現在の worktree」を選ぶ。
- **起動**: メインは自分 (Claude) のペインを `cmux pane <id> split --right` で分割して開く。ハーネス用（`--session`）は、TUI ではメイン Codex のペインにタブとして追加する（メインが無ければ分割）。アプリではタブを増やさず、メイン Codex のペインを下に分割する（メインが無ければ自分の右に分割）。どちらも失敗したら新しいタブ。開いた先で現在地に cd し、本物の Codex をフルパスで起動する。`/workspaces/workspace` では npm の同名パッケージ `codex` が `node_modules/.bin` で先に解決されるため、`codex` とだけ打つと別物が起動する。
- **回答の取得**: 画面ではなく `~/.codex/sessions/**/*.jsonl` を読み、送ったメッセージ（role=user の `response_item`）の後に来る `task_complete` イベントの `last_agent_message` を返す。画面の表示範囲で回答が切れることはない。
- **確認待ち**: Codex がコマンド実行の承認などで止まると `task_complete` が来ずタイムアウトする。そのときは `cmux terminal <id> screen read`（アプリは `cmux read-screen --surface <id>`）で画面を見て、ユーザーに状況を伝える（承認操作を勝手に代行しない）。
- `--correlation-key` は冪等キーで、同じ値を使い回すと前回の作成と衝突する（または古い結果が返る）ので付けない。タブを閉じても中のターミナルは残ることがあるため、タブに表示されていないターミナルは対象外にしている。
- `cmux terminal <id> keys Enter` は「キー指定が無効」で失敗する。送信には `write --text $'\r'` を使う。
- アプリ版の `cmux send` は `\n` を Enter に変換し ESC を落とすので、bracketed paste や `ctrl+j` では複数行を 1 メッセージにできない。`terminal.paste` は貼り付け後に必ず送信まで行う。
- アプリ版では cmux が PATH に無いことがあるので、`CMUX_BUNDLED_CLI_PATH` を使う。
