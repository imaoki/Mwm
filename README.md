# Mwm

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/Mwm)](https://github.com/imaoki/Mwm/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/Mwm)](https://github.com/imaoki/Mwm/blob/main/LICENSE)

MVVMフレームワーク。

## 特徴

* コマンドとプロパティによって構築可能なViewModel。

* 双方向データバインディング機構。

* 設定ファイル（.mxsconfig）をサポート。

## ライセンス

[MIT License](https://github.com/imaoki/Mwm/blob/main/LICENSE)

## 要件

* [imaoki/Standard](https://github.com/imaoki/Standard)

* （任意）[imaoki/StartupLoader](https://github.com/imaoki/StartupLoader)
  導入済みの場合はインストール/アンインストールでスタートアップスクリプトの登録/解除が行われる。
  未使用の場合はスクリプトの評価のみ行われる。

## 開発環境

`3ds Max 2024`

## インストール

01. 依存スクリプトは予めインストールしておく。

02. `install.ms`を実行する。

## アンインストール

`uninstall.ms`を実行する。

## 単一ファイル版

### インストール

01. 依存スクリプトは予めインストールしておく。

02. `Distribution\Mwm.min.ms`を実行する。

### アンインストール

```maxscript
::mwm.Uninstall()
```

<!-- ## 例 -->

## 使い方

`Example`を参照。
ここではシンプルなカウンターアプリケーションを例に順を追って解説する。

01. [モデルを定義](#モデルを定義)

02. [条件を作成](#条件を作成)

03. [ビューモデルのプロパティを作成](#ビューモデルのプロパティを作成)

04. [ビューモデルのコマンドを作成](#ビューモデルのコマンドを作成)

05. [条件を設定](#条件を設定)

06. [ビューを定義](#ビューを定義)

    01. [ロールアウトを定義](#ロールアウトを定義)

    02. [データバインディング](#データバインディング)

07. [ビューインスタンスを作成](#ビューインスタンスを作成)

08. [モデルインスタンスを作成](#モデルインスタンスを作成)

09. [ビューモデルを構築](#ビューモデルを構築)

10. [アプリケーションを構築](#アプリケーションを構築)

11. [アプリケーションを開始](#アプリケーションを開始)

### モデルを定義

```maxscript
struct SimpleCounterStruct (
  /*- @prop <Integer> */
  private count = 0,

  /*-
  @returns <Integer>
  */
  public fn GetCount = (
    this.count
  ),

  /*-
  @param input <Integer>
  @returns <Integer>
  */
  public fn SetCount input = (
    if classOf input == Integer do (
      this.count = input
      this.StateChanged.Notify #Count this.count
    )
    this.GetCount()
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
  )
)
(
  -- ...
)
```

* プロパティにはゲッターとセッターが必要。

* セッターは引数を一つ取る。

* `StateChanged`観察可能オブジェクトで状態変更を通知する。
  `StateChanged`は既定の名前で任意に指定可能。
  既定以外の名前を使用する場合は`ModelAttribute`にて指定する。

### 条件を作成

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  local enabledCondition = ::mwm.CreateCondition evaluator:(
    fn enabledEvaluator params = (
      params.Count == 1 and params[1].Name == #Enabled and params[1].Value
    )
  )
  local executeCondition = ::mwm.CreateCondition()
  -- ...
)
```

* プロパティまたはコマンドが使用可能になる条件を定義する。

### ビューモデルのプロパティを作成

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  local enabledProperty = ::mwm.CreateProperty #Enabled true
  enabledCondition.AddProperty enabledProperty
  local countProperty = ::mwm.CreateProperty #Count 0 \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #SimpleCounter \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      ) \
      enabledCondition:enabledCondition
  executeCondition.AddProperty countProperty
  -- ...
)
```

* モデルのプロパティを参照する場合は`ModelAttribute`を指定する。

* 観察可能オブジェクトのプロパティ名を既定から変更する場合

  ```maxscript
    local countAttribute = ::mwm.CreateModelAttribute \
        #SimpleCounter \
        propertyName:#Count \
        getterName:#GetCount \
        setterName:#SetCount
    countAttribute.SetObservableName #AnyName

    local countProperty = ::mwm.CreateProperty #Count 0 \
        modelAttribute:countAttribute \
        enabledCondition:enabledCondition
  ```

### ビューモデルのコマンドを作成

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  local commandAttribute = ::mwm.CreateModelAttribute #SimpleCounter
  local incrementCommand = ::mwm.CreateCommand #Increment \
      executeFunction:(
        fn executeIncrement model params event = (
          model.SetCount (params[1].Value + 1)
        )
      ) \
      modelAttribute:commandAttribute
  local decrementCommand = ::mwm.CreateCommand #Decrement \
      executeFunction:(
        fn executeDecrement model params event = (
          model.SetCount (params[1].Value - 1)
        )
      ) \
      modelAttribute:commandAttribute
  -- ...
)
```

* コマンド用の`ModelAttribute`はモデル名だけ指定すればよい。

### 条件を設定

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  countProperty.SetEnabledCondition enabledCondition
  incrementCommand.SetCanExecuteCondition enabledCondition
  incrementCommand.SetExecuteCondition executeCondition
  decrementCommand.SetCanExecuteCondition enabledCondition
  decrementCommand.SetExecuteCondition executeCondition
  -- ...
)
```

### ビューを定義

#### ロールアウトを定義

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  rollout RltMain "SimpleCounter" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #SimpleCounterViewModel

    checkBox CkbxEnabled "Enabled"
    editText EdtCount "Count"
    button BtnIncrement "+"
    button BtnDecrement "-"

    /*-
    @param control <RolloutClass|RolloutControl|RCMenu|MenuItem>
    @param eventName <Name>
    @param params <Array[<Any>]|Any>
    @returns <OkClass>
    */
    fn EventNotify control eventName params = (
      if ::mwm.IsValidViewModel DataContext do (
        DataContext.RaiseTargetChanged (
          ::mwm.CreateEvent control eventName params
        )
      )
      ok
    )

    /*-
    @param obj <Struct:MwmViewModelStruct>
    @returns <OkClass>
    */
    fn Initialize obj = (
      if ::mwm.IsValidViewModel obj do (
        DataContext = obj

        /* Data Binding */
        -- ...
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on CkbxEnabled Changed v do EventNotify CkbxEnabled #Changed #(v)
    on EdtCount Entered v do EventNotify EdtCount #Entered #(v)
    on BtnIncrement Pressed do EventNotify BtnIncrement #Pressed #()
    on BtnDecrement Pressed do EventNotify BtnDecrement #Pressed #()
  )
  -- ...
)
```

* 次の変数と関数を必ず実装する。

  * ローカル変数`DataContext`

    * ビューモデルの指定および格納。

  * ローカル関数`EventNotify`

    * イベントを受け取り`DataContext`（ViewModel）に通知する。

  * ローカル関数`Initialize`

    * `DataContext`を初期化する。

    * データバインディングを設定する。

    * `Open`イベントを通知する。

#### データバインディング

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  rollout RltMain "SimpleCounter" (
    -- ...
    /*-
    @param obj <Struct:MwmViewModelStruct>
    @returns <OkClass>
    */
    fn Initialize obj = (
      if ::mwm.IsValidViewModel obj do (
        DataContext = obj

        /* Data Binding */
        local countBinding = ::mwm.CreatePropertyBinding 1 #Count EdtCount #Text #Entered
        countBinding.SetConverter (::mwm.GetConverter #IntegerToString)
        local enabledBinding = ::mwm.CreatePropertyBinding 1 #Enabled CkbxEnabled #Checked #Changed
        local incrementBinding = ::mwm.CreateCommandBinding #Increment BtnIncrement #Pressed
        local decrementBinding = ::mwm.CreateCommandBinding #Decrement BtnDecrement #Pressed
        DataContext.SetBinding countBinding
        DataContext.SetBinding enabledBinding
        DataContext.SetBinding incrementBinding
        DataContext.SetBinding decrementBinding
      )
      EventNotify RltMain #Open #()
      ok
    )
    -- ...
  )
  -- ...
)
```

* コンバータは自前で実装することも可能。

  ```maxscript
  countBinding.SetConverter (
    ::mwm.CreateConverter \
        (fn integerAsString input = input as String) \
        (fn stringToInteger input = input as Integer)
  )
  ```

### ビューインスタンスを作成

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  local view = ::std.DialogStruct RltMain [160, 160]
  -- ...
)
```

### モデルインスタンスを作成

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  global simpleCounterModel = ::SimpleCounterStruct()
  -- ...
)
```

* モデルのプロパティ値を直接操作してUIに反映されるか確認するためのグローバル変数。

### ビューモデルを構築

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  local viewModel = ::mwm.CreateViewModel #SimpleCounterViewModel
  viewModel.AddModel #SimpleCounter ::simpleCounterModel
  viewModel.AddProperty enabledProperty
  viewModel.AddProperty countProperty
  viewModel.AddCommand incrementCommand
  viewModel.AddCommand decrementCommand
  -- ...
)
```

### アプリケーションを構築

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  global simpleCounterApplication = ::mwm.CreateApplication \
      #SimpleCounterApplication #RltMain
  ::simpleCounterApplication.AddModel #SimpleCounter ::simpleCounterModel
  ::simpleCounterApplication.AddView view
  ::simpleCounterApplication.AddViewModel viewModel
  -- ...
)
```

### アプリケーションを開始

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  ::simpleCounterApplication.Run()
)
```

#### 動作確認

* `+`ボタンと`-`ボタンで数値が変化するか。

* `EditTextControl`に入力した値がModelに反映されるか。

  ```maxscript
  ::simpleCounterModel.GetCount()
  ```

* モデルのプロパティ値を直接変更した場合にUIに反映されるか。

  ```maxscript
  ::simpleCounterModel.SetCount 99
  ```

<!-- ## 制限 -->

<!-- * 制限 -->

<!-- ## 既知の問題 -->

<!-- * 問題 -->

## 追加情報

### 設定ファイルの使用

#### モデルの実装

```maxscript
struct SimpleCounterStruct (
  -- ...
  /*-
  @param config <Struct:ConfigStruct>
  @returns <BooleanClass>
  */
  public fn Load config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = config.GetValue #SimpleCounter
      if classOf table == Dictionary do (
        if hasDictValue table #Count do this.SetCount table[#Count]
        isSuccessful = true
      )
    )
    isSuccessful
  ),

  /*-
  @param config <Struct:ConfigStruct>
  @returns <BooleanClass>
  */
  public fn Save config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = Dictionary #Name
      table[#Count] = this.GetCount()
      config.AddValue #SimpleCounter table
      isSuccessful = true
    )
    isSuccessful
  ),

  -- ...

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidConfig obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #ConfigStruct
  ),
  -- ...
)
(
  -- ...
)
```

* 設定オブジェクト（`<Struct:ConfigStruct>`）を引数に取る`Load`メソッドと`Save`メソッドを実装する。

#### アプリケーションの構築オプション

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  global simpleCounterApplication = ::mwm.CreateApplication \
      #SimpleCounterApplication #RltMain applicationFile:(getSourceFileName())
  -- ...
)
```

* キーワード引数`applicationFile`にアプリケーション定義元のファイル名を指定する。

* アプリケーションファイルの拡張子を`.mxsconfig`に変えたものが設定ファイルのパスとなる。

### 共通コンバータの実装

#### 追加

```maxscript
::mwm.AddConverter #IntegerToString (
  ::mwm.CreateConverter \
      (fn toTarget input = input as String) \
      (fn toSource input = input as Integer)
)
```

#### 取得

```maxscript
::mwm.GetConverter #IntegerToString
```
