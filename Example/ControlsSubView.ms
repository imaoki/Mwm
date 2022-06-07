/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of controlling the sub view.
*/
/* Mwm's domain */
(
  /* Create Condition */
  local followMainCondition = ::mwm.CreateCondition()
  local toggleSubCondition = ::mwm.CreateCondition()

  /* Create ViewModel Property */
  local followPositionProperty = ::mwm.CreateProperty #FollowPosition 1
  followMainCondition.AddProperty followPositionProperty
  local mainPositionProperty = ::mwm.CreateProperty #MainPosition [0, 0] \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #ControlsSubViewRltMain \
            propertyName:#InitPosition \
            getterName:#GetInitPosition \
            setterName:#SetInitPosition
      )
  followMainCondition.AddProperty mainPositionProperty
  local mainSizeProperty = ::mwm.CreateProperty #MainSize [0, 0] \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #ControlsSubViewRltMain \
            propertyName:#InitSize \
            getterName:#GetInitSize \
            setterName:#SetInitSize
      )
  followMainCondition.AddProperty mainSizeProperty
  local subIsDisplayedProperty = ::mwm.CreateProperty #SubIsDisplayed false \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #ControlsSubViewRltSub \
            propertyName:#IsDisplayed \
            getterName:#IsDisplayed
      )
  toggleSubCondition.AddProperty subIsDisplayedProperty

  /* Create ViewModel Command */
  local applicationAttribute = ::mwm.CreateModelAttribute #ControlsSubViewApplication
  local subViewAttribute = ::mwm.CreateModelAttribute #ControlsSubViewRltSub
  local followMainCommand = ::mwm.CreateCommand #FollowMain \
      executeFunction: (
        fn executeFollow model params event = (
          if model.IsDisplayed() do (
            local mainPosition = params[2].Value
            if classOf mainPosition == Point2 do (
              local newPosition = undefined
              local offset = params[3].Value * [1, 0]
              case params[1].Value of (
                (2): newPosition = mainPosition - offset
                (3): newPosition = mainPosition + offset
                default: ()
              )
              if classOf newPosition == Point2 do (
                model.SetPosition newPosition
              )
            )
          )
        )
      ) \
      modelAttribute:subViewAttribute
  local toggleSubCommand = ::mwm.CreateCommand #ToggleSub \
      executeFunction: (
        fn executeToggleSub model params event = (
          if params[1].Value then (
            model.CloseView #RltSub
          )
          else (
            model.OpenView #RltSub
          )
        )
      ) \
      modelAttribute:applicationAttribute
  local openSubCommand = ::mwm.CreateCommand #OpenSub \
      executeFunction: (
        fn executeOpenSub model params event = (
          model.OpenView #RltSub
        )
      ) \
      modelAttribute:applicationAttribute
  local closeSubCommand = ::mwm.CreateCommand #CloseSub \
      executeFunction: (
        fn executeCloseSub model params event = (
          model.CloseView #RltSub
        )
      ) \
      modelAttribute:applicationAttribute
  local closeMainCommand = ::mwm.CreateCommand #CloseMain \
      executeFunction: (
        fn executeCloseMain model params event = (
          model.Shutdown()
        )
      ) \
      modelAttribute:applicationAttribute

  /* Set Condition */
  followMainCommand.SetExecuteCondition followMainCondition
  toggleSubCommand.SetExecuteCondition toggleSubCondition

  /* Define Main View */
  rollout RltMain "ControlsSubView-Main" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #ControlsSubViewMainViewModel

    radioButtons RdbtnFollow "Follow" columns:3 default:1 labels:#("Free", "Left", "Right")
    checkButton CkbtnToggleSub "Toggle Sub"
    button BtnOpenSub "Open Sub" across:2
    button BtnCloseSub "Close Sub"
    button BtnCloseMain "Close This"

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
        local followPositionBinding = ::mwm.CreatePropertyBinding 1 #FollowPosition RdbtnFollow #State #Changed
        local subIsDisplayedBinding = ::mwm.CreatePropertyBinding 2 #SubIsDisplayed CkbtnToggleSub #Checked undefined
        local toggleSubBinding = ::mwm.CreateCommandBinding #ToggleSub CkbtnToggleSub #Changed
        local openSubBinding = ::mwm.CreateCommandBinding #OpenSub BtnOpenSub #Pressed
        local closeSubBinding = ::mwm.CreateCommandBinding #CloseSub BtnCloseSub #Pressed
        local closeMainBinding = ::mwm.CreateCommandBinding #CloseMain BtnCloseMain #Pressed
        local okToCloseMainBinding = ::mwm.CreateCommandBinding #CloseSub RltMain #Close
        local followMainBinding = ::mwm.CreateCommandBinding #FollowMain RltMain #Moved
        local followChangeBinding = ::mwm.CreateCommandBinding #FollowMain RdbtnFollow #Changed
        local followToggleBinding = ::mwm.CreateCommandBinding #FollowMain CkbtnToggleSub #Changed
        local followOpenBinding = ::mwm.CreateCommandBinding #FollowMain BtnOpenSub #Pressed
        DataContext.SetBinding followPositionBinding
        DataContext.SetBinding subIsDisplayedBinding
        DataContext.SetBinding toggleSubBinding
        DataContext.SetBinding openSubBinding
        DataContext.SetBinding closeSubBinding
        DataContext.SetBinding closeMainBinding
        DataContext.SetBinding okToCloseMainBinding
        DataContext.SetBinding followMainBinding
        DataContext.SetBinding followChangeBinding
        DataContext.SetBinding followToggleBinding
        DataContext.SetBinding followOpenBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on RdbtnFollow Changed v do EventNotify RdbtnFollow #Changed #(v)
    on CkbtnToggleSub Changed v do EventNotify CkbtnToggleSub #Changed #(v)
    on BtnOpenSub Pressed do EventNotify BtnOpenSub #Pressed #()
    on BtnCloseSub Pressed do EventNotify BtnCloseSub #Pressed #()
    on BtnCloseMain Pressed do EventNotify BtnCloseMain #Pressed #()
  )

  /* Define Sub View */
  rollout RltSub "ControlsSubView-Sub" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #ControlsSubViewSubViewModel

    radioButtons RdbtnFollow "Follow" columns:3 default:1 labels:#("Free", "Left", "Right")
    button BtnCloseSub "Close This"

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
        local followPositionBinding = ::mwm.CreatePropertyBinding 1 #FollowPosition RdbtnFollow #State #Changed
        local closeSubBinding = ::mwm.CreateCommandBinding #CloseSub BtnCloseSub #Pressed
        local followChangeBinding = ::mwm.CreateCommandBinding #FollowMain RdbtnFollow #Changed
        DataContext.SetBinding followPositionBinding
        DataContext.SetBinding closeSubBinding
        DataContext.SetBinding followChangeBinding
      )
      EventNotify RltSub #Open #()
      ok
    )

    on RltSub Close do EventNotify RltSub #Close #()
    on RltSub Moved v do EventNotify RltSub #Moved #(v)
    on RltSub Resized v do EventNotify RltSub #Resized #(v)

    on RdbtnFollow Changed v do EventNotify RdbtnFollow #Changed #(v)
    on BtnCloseSub Pressed do EventNotify BtnCloseSub #Pressed #()
  )

  /* Create View Instance */
  local mainView = ::std.DialogStruct RltMain [160, 160]
  local subView = ::std.DialogStruct RltSub [160, 160]

  /* Build ViewModel */
  local mainViewModel = ::mwm.CreateViewModel #ControlsSubViewMainViewModel
  mainViewModel.AddModel #ControlsSubViewRltMain mainView
  mainViewModel.AddModel #ControlsSubViewRltSub subView
  mainViewModel.AddProperty followPositionProperty
  mainViewModel.AddProperty mainPositionProperty
  mainViewModel.AddProperty mainSizeProperty
  mainViewModel.AddProperty subIsDisplayedProperty
  mainViewModel.AddCommand followMainCommand
  mainViewModel.AddCommand toggleSubCommand
  mainViewModel.AddCommand openSubCommand
  mainViewModel.AddCommand closeSubCommand
  mainViewModel.AddCommand closeMainCommand

  local subViewModel = ::mwm.CreateViewModel #ControlsSubViewSubViewModel
  mainViewModel.AddModel #ControlsSubViewRltMain mainView
  subViewModel.AddModel #ControlsSubViewRltSub subView
  subViewModel.AddProperty followPositionProperty
  subViewModel.AddProperty mainPositionProperty
  subViewModel.AddProperty mainSizeProperty
  subViewModel.AddProperty subIsDisplayedProperty
  subViewModel.AddCommand followMainCommand
  subViewModel.AddCommand closeSubCommand

  /* Build Application */
  /*
  Specifying applicationFile will save to the configuration file.
  */
  global controlsSubViewApplication = ::mwm.CreateApplication \
      #ControlsSubViewApplication #RltMain /* applicationFile:(getSourceFileName()) */
  ::controlsSubViewApplication.AddModel #ControlsSubViewRltMain mainView
  ::controlsSubViewApplication.AddModel #ControlsSubViewRltSub subView
  ::controlsSubViewApplication.AddView mainView
  ::controlsSubViewApplication.AddView subView
  ::controlsSubViewApplication.AddViewModel mainViewModel
  ::controlsSubViewApplication.AddViewModel subViewModel

  mainViewModel.AddModel #ControlsSubViewApplication controlsSubViewApplication
  subViewModel.AddModel #ControlsSubViewApplication controlsSubViewApplication

  /* Running Application */
  ::controlsSubViewApplication.Run()

  /* Direct operation */
  /*
  (::controlsSubViewApplication.GetView #RltMain).GetInitPosition()
  (::controlsSubViewApplication.GetView #RltMain).GetInitSize()
  (::controlsSubViewApplication.GetView #RltSub).GetInitPosition()
  (::controlsSubViewApplication.GetView #RltSub).GetInitSize()
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).GetPropertyValue #FollowPosition
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).GetPropertyValue #MainPosition
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).GetPropertyValue #MainSize
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).GetPropertyValue #SubIsDisplayed
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).ExecuteCommand #FollowMain
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).ExecuteCommand #ToggleSub
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).ExecuteCommand #OpenSub
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).ExecuteCommand #CloseSub
  (::controlsSubViewApplication.GetViewModel #ControlsSubViewMainViewModel).ExecuteCommand #CloseMain
  */

  /* Shutdown Application */
  /*
  ::controlsSubViewApplication.Shutdown()
  */
  ok
)
