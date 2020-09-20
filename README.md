キャッシュテキスト
==================

$VERSION$ ( $GITHASH$ ) by oov

キャッシュテキストは、生成したテキストを画像としてキャッシュすることで描画処理を効率化する拡張編集用スクリプトです。
このスクリプトは AviUtl 1.10 / 拡張編集 0.92 / 拡張編集RAMプレビュー 0.3rc7 で動作確認しています。

画像としてキャッシュするため、表示速度を利用したアニメーション、
サイズのリアルタイムな変更などのような機能は使用できません。

静的なテキストを表示する際の軽量化にお使いください。

動作環境
--------

- AviUtl 1.10
- 拡張編集 0.92
- 拡張編集RAMプレビュー 0.3rc7

以上が導入されていて、かつ script フォルダーに Extram.dll がある環境で動作します。

既知の問題点
------------

- テキスト本文が同じだと別のテキストオブジェクトになってもキャッシュが切り替わらない  
  - 本文に何も差異がない場合スクリプトからは区別が付きません
  - 末尾にスペースや `<s1><s>` を含めることで本文が変われば回避できます
- キャッシュを有効にした状態で「文字毎に個別オブジェクト」を切り替えるとテキストが描画されない  
  - チェックの状態が切り替わったことを事前に検出する方法がないために起こる問題です
  - 手動で切り替えたときに直後の１フレームでだけ起こる問題なので実用上は問題ないはずです

インストール方法
----------------

exedit.auf と同じ場所に「キャッシュテキスト.exa」と「script」をコピーすれば完了です。

使い方
------

拡張編集の右クリックメニューから
[メディアオブジェクトの追加]→[キャッシュテキスト]
を選ぶと、オブジェクトが追加されます。

なお、追加した時点ではキャッシュ処理は "無効" になっています。

「ここにテキストを書く」の部分を書き換えると表示されるテキストを変更できます。
そして、「<?m,s=0,[==[」の 0 を 1 に書き換えるとキャッシュが有効化されます。

有効化されると必要に応じてキャッシュから画像を再利用して表示されるようになり、
負荷が軽減されます。

ただしキャッシュが有効の間はサイズの変更などがすぐには反映されなくなります。
キャッシュを無効化するか、テキスト本文を変更するか、何もせずに３秒待つか、
いずれかを行うと変更結果が反映されます。

キャッシュデータについて
------------------------

画像データは Extram.dll を通じて AviUtl ではなく ZRamPreview.exe に保存されます。
ここで保存されたデータはしばらく使用されなければ勝手に消えますが、
AviUtl のメニューから [編集]→[Extram]→[キャッシュ消去] で手動で消すこともできます。
