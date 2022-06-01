# Mwm

<!-- [![GitHub release (latest by date)](https://img.shields.io/github/v/release/imaoki/Mwm)](https://github.com/imaoki/Mwm/releases/latest) -->
[![GitHub](https://img.shields.io/github/license/imaoki/Mwm)](https://github.com/imaoki/Mwm/blob/main/LICENSE)

MVVM framework.
<!-- MVVMフレームワーク。 -->

## Features
<!-- 特徴 -->

* ViewModel that can be constructed by commands and properties.
<!-- コマンドとプロパティによって構築可能なViewModel。 -->

* Two-way data binding mechanism.
<!-- 双方向データバインディング機構。 -->

* Supports configuration files (.mxsconfig).
<!-- 設定ファイル（.mxsconfig）をサポート。 -->

## Examples
<!-- 例 -->

## Requirements
<!-- 要件 -->

* [imaoki/Standard](https://github.com/imaoki/Standard)

## Development Environment
<!-- 開発環境 -->

`3ds Max 2022.3 Update`

## Install
<!-- インストールする -->

01. Dependent scripts should be installed beforehand.
    <!-- 依存スクリプトは予めインストールしておく。 -->

02. Execute `install.ms`.
    <!-- `install.ms`を実行する。 -->

## Uninstall
<!-- アンインストールする -->

Execute `uninstall.ms`.
<!-- `uninstall.ms`を実行する。 -->

## Standalone version
<!-- スタンドアローン版 -->

### Install
<!-- インストールする -->

01. Dependent scripts should be installed beforehand.
    <!-- 依存スクリプトは予めインストールしておく。 -->

02. Execute `Distribution\Mwm.min.ms`.
    <!-- `Distribution\Mwm.min.ms`を実行する。 -->

### Uninstall
<!-- アンインストールする -->

```maxscript
::mwm.Uninstall()
```

## Usage
<!-- 使い方 -->

See `Example`.
<!-- `Example`を参照。 -->
The following is a step-by-step explanation using a simple counter application as an example.
<!-- ここではシンプルなカウンターアプリケーションを例に順を追って解説する。 -->

01. [Define Model](#define-model)
    <!-- モデルを定義 -->

02. [Create Condition](#create-condition)
    <!-- 条件を作成 -->

03. [Create ViewModel Property](#create-viewmodel-property)
    <!-- ビューモデルのプロパティを作成 -->

04. [Create ViewModel Command](#create-viewmodel-command)
    <!-- ビューモデルのコマンドを作成 -->

05. [Set Condition](#set-condition)
    <!-- 条件を設定 -->

06. [Define View](#define-view)
    <!-- ビューを定義 -->

    01. [Define Rollout](#define-rollout)
        <!-- ロールアウトを定義 -->

    02. [Data Binding](#data-binding)
        <!-- データバインディング -->

07. [Create View Instance](#create-view-instance)
    <!-- ビューインスタンスを作成 -->

08. [Create Model Instance](#create-model-instance)
    <!-- モデルインスタンスを作成 -->

09. [Build ViewModel](#build-viewmodel)
    <!-- ビューモデルを構築 -->

10. [Build Application](#build-application)
    <!-- アプリケーションを構築 -->

11. [Start Application](#start-application)
    <!-- アプリケーションを開始 -->

### Define Model
<!-- モデルを定義 -->

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

* The property needs a getter and a setter.
  <!-- プロパティにはゲッターとセッターが必要。 -->

* The setter takes one argument.
  <!-- セッターは引数を一つ取る。 -->

* Notify state changes with `StateChanged` observable object.
  <!-- `StateChanged`観察可能オブジェクトで状態変更を通知する。 -->

  `StateChanged` is the default name and can be specified arbitrarily.
  If a non-default name is used, specify it in `ModelAttribute`.
  <!-- `StateChanged`は既定の名前で任意に指定可能。 -->
  <!-- 既定以外の名前を使用する場合は`ModelAttribute`にて指定する。 -->

### Create Condition
<!-- 条件を作成 -->

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

* Defines the conditions under which a property or command becomes available.
  <!-- プロパティまたはコマンドが使用可能になる条件を定義する。 -->

### Create ViewModel Property
<!-- ビューモデルのプロパティを作成 -->

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

* Specify `ModelAttribute` when referring to Model properties.
  <!-- モデルのプロパティを参照する場合は`ModelAttribute`を指定する。 -->

* To change the property name of an observable object from the default
  <!-- 観察可能オブジェクトのプロパティ名を既定から変更する場合 -->

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

### Create ViewModel Command
<!-- ビューモデルのコマンドを作成 -->

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

* The `ModelAttribute` for the command only needs to specify the model name.
  <!-- コマンド用の`ModelAttribute`はモデル名だけ指定すればよい。 -->

### Set Condition
<!-- 条件を設定 -->

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

### Define View
<!-- ビューを定義 -->

#### Define Rollout
<!-- ロールアウトを定義 -->

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

* The following variables and functions must be implemented
  <!-- 次の変数と関数を必ず実装する。 -->

  * Local variable `DataContext`
    <!-- ローカル変数`DataContext` -->

    * Specify and store ViewModel.
      <!-- ビューモデルの指定および格納。 -->

  * Local function `EventNotify`
    <!-- ローカル関数`EventNotify` -->

    * Receives events and notifies the `DataContext` (ViewModel).
      <!-- イベントを受け取り`DataContext`（ViewModel）に通知する。 -->

  * Local function `Initialize`
    <!-- ローカル関数`Initialize` -->

    * Initialize `DataContext`.
      <!-- `DataContext`を初期化する。 -->

    * Set up data binding.
      <!-- データバインディングを設定する。 -->

    * Notify of `Open` events.
      <!-- `Open`イベントを通知する。 -->

#### Data Binding
<!-- データバインディング -->

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

### Create View Instance
<!-- ビューインスタンスを作成 -->

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

### Create Model Instance
<!-- モデルインスタンスを作成 -->

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

* Global variable for directly manipulating Model property values to see if they are reflected in the UI.
  <!-- モデルのプロパティ値を直接操作してUIに反映されるか確認するためのグローバル変数。 -->

### Build ViewModel
<!-- ビューモデルを構築 -->

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

### Build Application
<!-- アプリケーションを構築 -->

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

### Start Application
<!-- アプリケーションを開始 -->

```maxscript
struct SimpleCounterStruct (
  -- ...
)
(
  -- ...
  ::simpleCounterApplication.Run()
)
```

#### Operation check
<!-- 動作確認 -->

* Do the `+` and `-` buttons change the value?
  <!-- `+`ボタンと`-`ボタンで数値が変化するか。 -->

* Are the values entered into `EditTextControl` reflected in the Model?
  <!-- `EditTextControl`に入力した値がModelに反映されるか。 -->

  ```maxscript
  ::simpleCounterModel.GetCount()
  ```

* Is it reflected in the UI when Model property values are changed directly?
  <!-- モデルのプロパティ値を直接変更した場合にUIに反映されるか。 -->

  ```maxscript
  ::simpleCounterModel.SetCount 99
  ```

<!-- ## Limitations -->
<!-- 制限 -->

<!-- * Limitations -->
<!-- 制限 -->

<!-- ## Known Issues -->
<!-- 既知の問題 -->

<!-- * Issue -->
<!-- 問題 -->

## Additional Information
<!-- 追加情報 -->

### Using configuration files
<!-- 設定ファイルの使用 -->

#### Model Implementation
<!-- モデルの実装 -->

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

* Implement the `Load` and `Save` methods that take a configuration object ([`<Struct:ConfigStruct>`](https://imaoki.github.io/mxskb/mxsdoc/standard-config.html)) as an argument.
  <!-- 設定オブジェクト（`<Struct:ConfigStruct>`）を引数に取る`Load`メソッドと`Save`メソッドを実装する。 -->

#### Application Build Option
<!-- アプリケーションの構築オプション -->

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

* Specify the filename of the application definition source in the keyword argument `applicationFile`.
  <!-- キーワード引数`applicationFile`にアプリケーション定義元のファイル名を指定する。 -->

* The configuration file path is the one with the application file extension changed to `.mxsconfig`.
  <!-- アプリケーションファイルの拡張子を`.mxsconfig`に変えたものが設定ファイルのパスとなる。 -->

## License
<!-- ライセンス -->

[MIT License](https://github.com/imaoki/Mwm/blob/main/LICENSE)
