object GLCube: TGLCube
  Left = 0
  Top = 0
  Caption = 'GLCube'
  ClientHeight = 478
  ClientWidth = 597
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PInfo: TPanel
    Left = 432
    Top = 0
    Width = 165
    Height = 478
    Align = alRight
    TabOrder = 0
    object PLive: TPanel
      Left = 1
      Top = 1
      Width = 163
      Height = 48
      Align = alTop
      TabOrder = 0
      object leTJ: TLabeledEdit
        Left = 16
        Top = 20
        Width = 121
        Height = 21
        EditLabel.Width = 110
        EditLabel.Height = 13
        EditLabel.Caption = #1042#1074#1077#1076#1080#1090#1077' '#1074#1088#1077#1084#1103' '#1078#1080#1079#1085#1080
        NumbersOnly = True
        TabOrder = 0
        Text = '20'
        OnChange = leTJChange
      end
    end
    object PQuad: TPanel
      Left = 1
      Top = 49
      Width = 163
      Height = 428
      Align = alClient
      TabOrder = 1
      object lblCountQuads: TLabel
        Left = 1
        Top = 1
        Width = 161
        Height = 13
        Align = alTop
        ExplicitWidth = 3
      end
      object lblSled: TLabel
        Left = 1
        Top = 14
        Width = 161
        Height = 13
        Align = alTop
        ExplicitWidth = 3
      end
      object mCubes: TMemo
        Left = 1
        Top = 27
        Width = 161
        Height = 400
        Align = alClient
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object TCub: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TCubTimer
    Left = 296
    Top = 248
  end
  object TTim: TTimer
    Enabled = False
    OnTimer = TTimTimer
    Left = 352
    Top = 248
  end
  object TCir: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TCirTimer
    Left = 408
    Top = 248
  end
end
