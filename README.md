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

A simple counter application will be used as an example and explained step by step.
<!-- シンプルなカウンターアプリケーションを例に、順を追って解説する。 -->

01. [Define Model](#define-model)
    <!-- Modelを定義 -->

02. [Create ViewModel Property](#create-viewmodel-property)
    <!-- ViewModelのプロパティを作成 -->

03. [Create ViewModel Command](#create-viewmodel-command)
    <!-- ViewModelのコマンドを作成 -->

04. [Define View](#define-view)
    <!-- Viewを定義 -->

    01. [Define Rollout](#define-rollout)
        <!-- ロールアウトを定義 -->

    02. [Data Binding](#data-binding)
        <!-- データバインディング -->

05. [Create View Instance](#create-view-instance)
    <!-- Viewインスタンスを作成 -->

06. [Create Model Instance](#create-model-instance)
    <!-- Modelインスタンスを作成 -->

07. [Build ViewModel](#build-viewmodel)
    <!-- ViewModelを構築 -->

08. [Build Application](#build-application)
    <!-- アプリケーションを構築 -->

09. [Start Application](#start-application)
    <!-- アプリケーションを開始 -->

### Define Model
<!-- Modelを定義 -->

```maxscript
/* Define Model */
struct ExampleCounterModelStruct (
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

### Create ViewModel Property
<!-- ViewModelのプロパティを作成 -->

```maxscript
(
  /* Create ViewModel Property */
  local countProperty = ::mwm.CreateProperty #Count 0 \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #CounterModel \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      )
)
```

* To change the property name of an observable object from the default
  <!-- 観察可能オブジェクトのプロパティ名を既定から変更する場合 -->

  ```maxscript
    local countAttribute = ::mwm.CreateModelAttribute \
        #CounterModel \
        propertyName:#Count \
        getterName:#GetCount \
        setterName:#SetCount
    countAttribute.SetObservableName #AnyName

    local countProperty = ::mwm.CreateProperty #Count 0 \
        modelAttribute:countAttribute
  ```

### Create ViewModel Command
<!-- ViewModelのコマンドを作成 -->

```maxscript
(
  /* Create ViewModel Command */
  local commandAttribute = ::mwm.CreateModelAttribute #CounterModel
  local incrementCommand = ::mwm.CreateCommand #Increment \
      executeFunction:(
        fn executeIncrement model params event = (
          model.SetCount (params[1].Value + 1)
        )
      ) \
      modelAttribute:commandAttribute
  incrementCommand.AddExecuteProperty countProperty

  local decrementCommand = ::mwm.CreateCommand #Decrement \
      executeFunction:(
        fn executeDecrement model params event = (
          model.SetCount (params[1].Value - 1)
        )
      ) \
      modelAttribute:commandAttribute
  decrementCommand.AddExecuteProperty countProperty
)
```

* The `ModelAttribute` for the command only needs to specify the model name.
  <!-- コマンド用の`ModelAttribute`はモデル名だけ指定すればよい。 -->

### Define View
<!-- Viewを定義 -->

#### Define Rollout
<!-- ロールアウトを定義 -->

```maxscript
(
  /* Define View */
  rollout RltCounterView "Counter" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #CounterViewModel

    editText EdtCounter "Counter"
    button BtnIncrement "+"
    button BtnDecrement "-"

    /*-
    @param control <RolloutClass|RolloutControl>
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
      )
      EventNotify RltCounterView #Open #()
      ok
    )

    on RltCounterView Close do EventNotify RltCounterView #Close #()
    on RltCounterView Moved v do EventNotify RltCounterView #Moved #(v)
    on RltCounterView Resized v do EventNotify RltCounterView #Resized #(v)

    on EdtCounter Entered v do EventNotify EdtCounter #Entered #(v)
    on BtnIncrement Pressed do EventNotify BtnIncrement #Pressed #()
    on BtnDecrement Pressed do EventNotify BtnDecrement #Pressed #()
  )
)
```

* The following variables and functions must be implemented
  <!-- 次の変数と関数を必ず実装する。 -->

  * Local variable `DataContext`
    <!-- ローカル変数`DataContext` -->

    * Specify and store ViewModel.
      <!-- ViewModelの指定および格納。 -->

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
(
  /* Define View */
  rollout RltCounterView "Counter" (
    -- ...
    /*-
    @param obj <Struct:MwmViewModelStruct>
    @returns <OkClass>
    */
    fn Initialize obj = (
      if ::mwm.IsValidViewModel obj do (
        DataContext = obj

        /* Data Binding */
        local countBinding = ::mwm.CreatePropertyBinding #Count EdtCounter #Entered #Text
        countBinding.SetConverter (
          ::mwm.CreateConverter \
              (fn integerAsString input = input as String) \
              (fn stringToInteger input = input as Integer)
        )
        local incrementBinding = ::mwm.CreateCommandBinding #Increment BtnIncrement #Pressed
        local decrementBinding = ::mwm.CreateCommandBinding #Decrement BtnDecrement #Pressed
        DataContext.SetBinding countBinding
        DataContext.SetBinding incrementBinding
        DataContext.SetBinding decrementBinding
      )
      EventNotify RltCounterView #Open #()
      ok
    )
    -- ...
  )
)
```

### Create View Instance
<!-- Viewインスタンスを作成 -->

```maxscript
(
  /* Create View Instance */
  local view = ::std.DialogStruct RltCounterView [160, 160]
)
```

### Create Model Instance
<!-- Modelインスタンスを作成 -->

```maxscript
(
  /* Create Model Instance */
  global exampleCounterModel = ::ExampleCounterModelStruct()
)
```

* Global variable for directly manipulating Model property values to see if they are reflected in the UI.
  <!-- Modelのプロパティ値を直接操作してUIに反映されるか確認するためのグローバル変数。 -->

### Build ViewModel
<!-- ViewModelを構築 -->

```maxscript
(
  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #CounterViewModel
  viewModel.AddModel #CounterModel ::exampleCounterModel
  viewModel.AddProperty countProperty
  viewModel.AddCommand incrementCommand
  viewModel.AddCommand decrementCommand
)
```

### Build Application
<!-- アプリケーションを構築 -->

```maxscript
(
  /* Build Application */
  global exampleCounterApplication = ::mwm.CreateApplication #CounterApplication #RltCounterView
  ::exampleCounterApplication.AddModel #CounterModel ::exampleCounterModel
  ::exampleCounterApplication.AddView view
  ::exampleCounterApplication.AddViewModel viewModel
)
```

### Start Application
<!-- アプリケーションを開始 -->

```maxscript
(
  /* Running Application */
  ::exampleCounterApplication.Run()
)
```

#### Operation check
<!-- 動作確認 -->

* Do the `+` and `-` buttons change the value?
  <!-- `+`ボタンと`-`ボタンで数値が変化するか。 -->

* Are the values entered into `EditTextControl` reflected in the Model?
  <!-- `EditTextControl`に入力した値がModelに反映されるか。 -->

  ```maxscript
  ::exampleCounterModel.GetCount()
  ```

* Is it reflected in the UI when Model property values are changed directly?
  <!-- Modelのプロパティ値を直接変更した場合にUIに反映されるか。 -->

  ```maxscript
  ::exampleCounterModel.SetCount 99
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
<!-- Modelの実装 -->

```maxscript
(
/* Define Model */
struct ExampleCounterModelStruct (
  -- ...

  /*-
  @param config <Struct:ConfigStruct>
  @returns <BooleanClass>
  */
  public fn Load config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = config.GetValue #CounterModel
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
      config.AddValue #CounterModel table
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

)
```

* Implement the `Load` and `Save` methods that take a configuration object ([`<Struct:ConfigStruct>`](https://imaoki.github.io/mxskb/mxsdoc/standard-config.html)) as an argument.
  <!-- 設定オブジェクト（`<Struct:ConfigStruct>`）を引数に取る`Load`メソッドと`Save`メソッドを実装する。 -->

#### Application Build Option
<!-- アプリケーションの構築オプション -->

```maxscript
(
  /* Build Application */
  global exampleCounterApplication = ::mwm.CreateApplication \
      #CounterApplication #RltCounterView applicationFile:(getSourceFileName())
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
