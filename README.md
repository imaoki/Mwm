# Mwm

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/Mwm)](https://github.com/imaoki/Mwm/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/Mwm)](https://github.com/imaoki/Mwm/blob/main/LICENSE)

MVVMフレームワーク。
<!-- MVVM framework. -->

## 特徴
<!-- ## Features -->

* コマンドとプロパティによって構築可能なViewModel。
  <!-- * ViewModel that can be constructed by commands and properties. -->

* 双方向データバインディング機構。
  <!-- * Two-way data binding mechanism. -->

* 設定ファイル（.mxsconfig）をサポート。
  <!-- * Supports configuration files (.mxsconfig). -->

## ライセンス
<!-- ## License -->

[MIT License](https://github.com/imaoki/Mwm/blob/main/LICENSE)

## 要件
<!-- ## Requirements -->

* [imaoki/Standard](https://github.com/imaoki/Standard)

## 開発環境
<!-- ## Development Environment -->

`3ds Max 2024`

## インストール
<!-- ## Install -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. `install.ms`を実行する。
    <!-- 02. Execute `install.ms`. -->

## アンインストール
<!-- ## Uninstall -->

`uninstall.ms`を実行する。
<!-- Execute `uninstall.ms`. -->

## 単一ファイル版
<!-- ## Single File Version -->

### インストール
<!-- ### Install -->

01. 依存スクリプトは予めインストールしておく。
    <!-- 01. Dependent scripts should be installed beforehand. -->

02. `Distribution\Mwm.min.ms`を実行する。
    <!-- 02. Execute `Distribution\Mwm.min.ms`. -->

### アンインストール
<!-- ### Uninstall -->

```maxscript
::mwm.Uninstall()
```

<!-- ## 例 -->
<!-- ## Examples -->

## 使い方
<!-- ## Usage -->

`Example`を参照。
<!-- See `Example`. -->
ここではシンプルなカウンターアプリケーションを例に順を追って解説する。
<!-- The following is a step-by-step explanation using a simple counter application as an example. -->

01. [モデルを定義](#モデルを定義)
    <!-- 01. [Define Model](#define-model) -->

02. [条件を作成](#条件を作成)
    <!-- 02. [Create Condition](#create-condition) -->

03. [ビューモデルのプロパティを作成](#ビューモデルのプロパティを作成)
    <!-- 03. [Create ViewModel Property](#create-viewmodel-property) -->

04. [ビューモデルのコマンドを作成](#ビューモデルのコマンドを作成)
    <!-- 04. [Create ViewModel Command](#create-viewmodel-command) -->

05. [条件を設定](#条件を設定)
    <!-- 05. [Set Condition](#set-condition) -->

06. [ビューを定義](#ビューを定義)
    <!-- 06. [Define View](#define-view) -->

    01. [ロールアウトを定義](#ロールアウトを定義)
        <!-- 01. [Define Rollout](#define-rollout) -->

    02. [データバインディング](#データバインディング)
        <!-- 02. [Data Binding](#data-binding) -->

07. [ビューインスタンスを作成](#ビューインスタンスを作成)
    <!-- 07. [Create View Instance](#create-view-instance) -->

08. [モデルインスタンスを作成](#モデルインスタンスを作成)
    <!-- 08. [Create Model Instance](#create-model-instance) -->

09. [ビューモデルを構築](#ビューモデルを構築)
    <!-- 09. [Build ViewModel](#build-viewmodel) -->

10. [アプリケーションを構築](#アプリケーションを構築)
    <!-- 10. [Build Application](#build-application) -->

11. [アプリケーションを開始](#アプリケーションを開始)
    <!-- 11. [Start Application](#start-application) -->

### モデルを定義
<!-- ### Define Model -->

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
  <!-- * The property needs a getter and a setter. -->

* セッターは引数を一つ取る。
  <!-- * The setter takes one argument. -->

* `StateChanged`観察可能オブジェクトで状態変更を通知する。
  <!-- * Notify state changes with `StateChanged` observable object. -->
  `StateChanged`は既定の名前で任意に指定可能。
  <!-- `StateChanged` is the default name and can be specified arbitrarily. -->
  既定以外の名前を使用する場合は`ModelAttribute`にて指定する。
  <!-- If a non-default name is used, specify it in `ModelAttribute`. -->

### 条件を作成
<!-- ### Create Condition -->

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
  <!-- * Defines the conditions under which a property or command becomes available. -->

### ビューモデルのプロパティを作成
<!-- ### Create ViewModel Property -->

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
  <!-- * Specify `ModelAttribute` when referring to Model properties. -->

* 観察可能オブジェクトのプロパティ名を既定から変更する場合
  <!-- * To change the property name of an observable object from the default -->

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
<!-- ### Create ViewModel Command -->

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
  <!-- * The `ModelAttribute` for the command only needs to specify the model name. -->

### 条件を設定
<!-- ### Set Condition -->

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
<!-- ### Define View -->

#### ロールアウトを定義
<!-- #### Define Rollout -->

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
  <!-- * The following variables and functions must be implemented -->

  * ローカル変数`DataContext`
    <!-- * Local variable `DataContext` -->

    * ビューモデルの指定および格納。
      <!-- * Specify and store ViewModel. -->

  * ローカル関数`EventNotify`
    <!-- * Local function `EventNotify` -->

    * イベントを受け取り`DataContext`（ViewModel）に通知する。
      <!-- * Receives events and notifies the `DataContext` (ViewModel). -->

  * ローカル関数`Initialize`
    <!-- * Local function `Initialize` -->

    * `DataContext`を初期化する。
      <!-- * Initialize `DataContext`. -->

    * データバインディングを設定する。
      <!-- * Set up data binding. -->

    * `Open`イベントを通知する。
      <!-- * Notify of `Open` events. -->

#### データバインディング
<!-- #### Data Binding -->

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
  <!-- * Converters can be implemented on your own. -->

  ```maxscript
  countBinding.SetConverter (
    ::mwm.CreateConverter \
        (fn integerAsString input = input as String) \
        (fn stringToInteger input = input as Integer)
  )
  ```

### ビューインスタンスを作成
<!-- ### Create View Instance -->

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
<!-- ### Create Model Instance -->

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
  <!-- * Global variable for directly manipulating Model property values to see if they are reflected in the UI. -->

### ビューモデルを構築
<!-- ### Build ViewModel -->

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
<!-- ### Build Application -->

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
<!-- ### Start Application -->

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
<!-- #### Operation check -->

* `+`ボタンと`-`ボタンで数値が変化するか。
  <!-- * Do the `+` and `-` buttons change the value? -->

* `EditTextControl`に入力した値がModelに反映されるか。
  <!-- * Are the values entered into `EditTextControl` reflected in the Model? -->

  ```maxscript
  ::simpleCounterModel.GetCount()
  ```

* モデルのプロパティ値を直接変更した場合にUIに反映されるか。
  <!-- * Is it reflected in the UI when Model property values are changed directly? -->

  ```maxscript
  ::simpleCounterModel.SetCount 99
  ```

<!-- ## 制限 -->
<!-- ## Limitations -->

<!-- * 制限 -->
<!-- * Limitations -->

<!-- ## 既知の問題 -->
<!-- ## Known Issues -->

<!-- * 問題 -->
<!-- * Issue -->

## 追加情報
<!-- ## Additional Information -->

### 設定ファイルの使用
<!-- ### Using configuration files -->

#### モデルの実装
<!-- #### Model Implementation -->

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
  <!-- * Implement the `Load` and `Save` methods that take a configuration object ([`<Struct:ConfigStruct>`](https://imaoki.github.io/mxskb/mxsdoc/standard-config.html)) as an argument. -->

#### アプリケーションの構築オプション
<!-- #### Application Build Option -->

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
  <!-- * Specify the filename of the application definition source in the keyword argument `applicationFile`. -->

* アプリケーションファイルの拡張子を`.mxsconfig`に変えたものが設定ファイルのパスとなる。
  <!-- * The configuration file path is the one with the application file extension changed to `.mxsconfig`. -->

### 共通コンバータの実装
<!-- ### Common converter implementation -->

#### 追加
<!-- #### Add -->

```maxscript
::mwm.AddConverter #IntegerToString (
  ::mwm.CreateConverter \
      (fn toTarget input = input as String) \
      (fn toSource input = input as Integer)
)
```

#### 取得
<!-- #### Get -->

```maxscript
::mwm.GetConverter #IntegerToString
```
