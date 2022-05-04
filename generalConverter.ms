/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/* 整数を文字列に変換 */
::mwm.AddConverter #IntegerToString (
  ::mwm.CreateConverter \
      (fn toTarget input = input as String) \
      (fn toSource input = input as Integer)
)
