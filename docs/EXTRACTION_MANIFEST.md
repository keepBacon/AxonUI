# FlClash UI 源码提取记录

- 输入：上传的 `FlClash-main.zip`
- 输入 SHA-256：`3150225aadd9f0e2cc0dc320af10d7f661c655aa9149b5a813ac47fb4f332233`
- 提取 Dart 文件数：**203**
- 原包 Dart 文件数：**891**
- 复制的目录：`lib/ui`、`lib/widgets`、`lib/features/form`、`lib/views`、`lib/pages`。
- 原始 Dart 文件原样提取；未改写 FlClash 类名、依赖或包路径。
- 提取文件不是独立可编译 package，它们仍使用 `package:fl_clash/*` 的包依赖。
- 当前 Flutter 组件库的主执行目录是根目录 `lib/`，没有编译/加载原始参考目录。
- 复制了上游 LICENSE，许可证为 GNU General Public License v3。
