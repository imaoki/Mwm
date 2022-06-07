/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of controlling the main view.
*/
/* Mwm's domain */
(
  /* Create Condition */
  local positionCondition = ::mwm.CreateCondition()
  local sizeCondition = ::mwm.CreateCondition()

  /* Create ViewModel Property */
  local positionProperty = ::mwm.CreateProperty #Position [0, 0] \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #ControlsMainViewRltMain \
            propertyName:#InitPosition \
            getterName:#GetInitPosition \
            setterName:#SetInitPosition
      )
  positionCondition.AddProperty positionProperty
  local sizeProperty = ::mwm.CreateProperty #Size [0, 0] \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #ControlsMainViewRltMain \
            propertyName:#InitSize \
            getterName:#GetInitSize \
            setterName:#SetInitSize
      )
  sizeCondition.AddProperty sizeProperty

  /* Create ViewModel Command */
  local commandAttribute = ::mwm.CreateModelAttribute #ControlsMainViewRltMain
  local setPositionXCommand = ::mwm.CreateCommand #SetPositionX \
      executeFunction: (
        fn executeSetPositionX model params event = (
          local newPosition = if classOf params[1].Value == Point2 then (
            [(event.GetParams())[1], params[1].Value.Y]
          )
          else (
            model.GetPosition()
          )
          model.SetPosition newPosition
          model.SetInitPosition newPosition
        )
      ) \
      modelAttribute:commandAttribute
  local setPositionYCommand = ::mwm.CreateCommand #SetPositionY \
      executeFunction: (
        fn executeSetPositionY model params event = (
          local newPosition = if classOf params[1].Value == Point2 then (
            [params[1].Value.X, (event.GetParams())[1]]
          )
          else (
            model.GetPosition()
          )
          model.SetPosition newPosition
          model.SetInitPosition newPosition
        )
      ) \
      modelAttribute:commandAttribute
  local setSizeXCommand = ::mwm.CreateCommand #SetSizeX \
      executeFunction: (
        fn executeSetSizeX model params event = (
          if classOf params[1].Value == Point2 do (
            local newSize = [(event.GetParams())[1], params[1].Value.Y]
            model.SetSize newSize
            model.SetInitSize newSize
          )
        )
      ) \
      modelAttribute:commandAttribute
  local setSizeYCommand = ::mwm.CreateCommand #SetSizeY \
      executeFunction: (
        fn executeSetSizeY model params event = (
          if classOf params[1].Value == Point2 do (
            local newSize = [params[1].Value.X, (event.GetParams())[1]]
            model.SetSize newSize
            model.SetInitSize newSize
          )
        )
      ) \
      modelAttribute:commandAttribute
  local resetSizeCommand = ::mwm.CreateCommand #ResetSize \
      executeFunction: (
        fn executeResetSize model params event = (
          local newSize = [160, 160]
          model.SetSize newSize
          model.SetInitSize newSize
        )
      ) \
      modelAttribute:commandAttribute
  local closeCommand = ::mwm.CreateCommand #Close \
      executeFunction: (
        fn executeResetSize model params event = (
          model.Destroy()
        )
      ) \
      modelAttribute:commandAttribute

  /* Set Condition */
  setPositionXCommand.SetExecuteCondition positionCondition
  setPositionYCommand.SetExecuteCondition positionCondition
  setSizeXCommand.SetExecuteCondition sizeCondition
  setSizeYCommand.SetExecuteCondition sizeCondition

  /* Define View */
  rollout RltMain "ControlsMainView" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #ControlsMainViewViewModel

    spinner SpnPositionX "X:" align:#Left fieldWidth:60 range:[-10000, 10000, 0] scale:1 type:#Integer
    spinner SpnPositionY "Y:" align:#Left fieldWidth:60 range:[-10000, 10000, 0] scale:1 type:#Integer
    spinner SpnSizeX "W:" align:#Left fieldWidth:60 range:[-10000, 10000, 0] scale:1 type:#Integer
    spinner SpnSizeY "H:" align:#Left fieldWidth:60 range:[-10000, 10000, 0] scale:1 type:#Integer
    button BtnResetSize "Reset Size" align:#Left
    button BtnClose "Close" align:#Left

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

        /* Define converter */
        local xConverter = ::mwm.CreateConverter \
            (fn point2AsInteger input = (if classOf input == Point2 then input.X else -1)) \
            (fn integerAsPoint2 input = [input, input])
        local yConverter = ::mwm.CreateConverter \
            (fn point2AsInteger input = (if classOf input == Point2 then input.Y else -1)) \
            (fn integerAsPoint2 input = [input, input])

        /* Data Binding */
        local positionXBinding = ::mwm.CreatePropertyBinding 2 #Position SpnPositionX #Value undefined
        positionXBinding.SetConverter xConverter
        local positionYBinding = ::mwm.CreatePropertyBinding 2 #Position SpnPositionY #Value undefined
        positionYBinding.SetConverter yConverter
        local sizeXBinding = ::mwm.CreatePropertyBinding 2 #Size SpnSizeX #Value undefined
        sizeXBinding.SetConverter xConverter
        local sizeYBinding = ::mwm.CreatePropertyBinding 2 #Size SpnSizeY #Value undefined
        sizeYBinding.SetConverter yConverter
        local setPositionXBinding = ::mwm.CreateCommandBinding #SetPositionX SpnPositionX #Changed
        local setPositionYBinding = ::mwm.CreateCommandBinding #SetPositionY SpnPositionY #Changed
        local setSizeXBinding = ::mwm.CreateCommandBinding #SetSizeX SpnSizeX #Changed
        local setSizeYBinding = ::mwm.CreateCommandBinding #SetSizeY SpnSizeY #Changed
        local resetSizeBinding = ::mwm.CreateCommandBinding #ResetSize BtnResetSize #Pressed
        local closeBinding = ::mwm.CreateCommandBinding #Close BtnClose #Pressed
        DataContext.SetBinding positionXBinding
        DataContext.SetBinding positionYBinding
        DataContext.SetBinding sizeXBinding
        DataContext.SetBinding sizeYBinding
        DataContext.SetBinding setPositionXBinding
        DataContext.SetBinding setPositionYBinding
        DataContext.SetBinding setSizeXBinding
        DataContext.SetBinding setSizeYBinding
        DataContext.SetBinding resetSizeBinding
        DataContext.SetBinding closeBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on SpnPositionX Changed v do EventNotify SpnPositionX #Changed #(v)
    on SpnPositionY Changed v do EventNotify SpnPositionY #Changed #(v)
    on SpnSizeX Changed v do EventNotify SpnSizeX #Changed #(v)
    on SpnSizeY Changed v do EventNotify SpnSizeY #Changed #(v)
    on BtnResetSize Pressed do EventNotify BtnResetSize #Pressed #()
    on BtnClose Pressed do EventNotify BtnClose #Pressed #()
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]
  view.SetStyleResizing true

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #ControlsMainViewViewModel
  viewModel.AddModel #ControlsMainViewRltMain view
  viewModel.AddProperty positionProperty
  viewModel.AddProperty sizeProperty
  viewModel.AddCommand setPositionXCommand
  viewModel.AddCommand setPositionYCommand
  viewModel.AddCommand setSizeXCommand
  viewModel.AddCommand setSizeYCommand
  viewModel.AddCommand resetSizeCommand
  viewModel.AddCommand closeCommand

  /* Build Application */
  /*
  Specifying applicationFile will save to the configuration file.
  */
  global controlsMainViewApplication = ::mwm.CreateApplication \
      #ControlsMainViewApplication #RltMain /* applicationFile:(getSourceFileName()) */
  ::controlsMainViewApplication.AddModel #ControlsMainViewRltMain view
  ::controlsMainViewApplication.AddView view
  ::controlsMainViewApplication.AddViewModel viewModel

  /* Running Application */
  ::controlsMainViewApplication.Run()

  /* Direct operation */
  /*
  (::controlsMainViewApplication.GetView #RltMain).GetInitPosition()
  (::controlsMainViewApplication.GetView #RltMain).GetInitSize()
  (::controlsMainViewApplication.GetViewModel #ControlsMainViewViewModel).GetPropertyValue #Position
  (::controlsMainViewApplication.GetViewModel #ControlsMainViewViewModel).GetPropertyValue #Size
  */

  /* Shutdown Application */
  /*
  ::controlsMainViewApplication.Shutdown()
  */
  ok
)
