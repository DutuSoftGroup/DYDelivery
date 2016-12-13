inherited fFormWeixinBind: TfFormWeixinBind
  Left = 628
  Top = 406
  Caption = #21333#20215
  ClientHeight = 91
  ClientWidth = 326
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 326
    Height = 91
    inherited BtnOK: TButton
      Left = 180
      Top = 58
      Caption = #30830#23450
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 250
      Top = 58
      TabOrder = 2
    end
    object EditMobileNo: TcxTextEdit [2]
      Left = 81
      Top = 18
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      TabOrder = 0
      OnKeyPress = EditMobileNoKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = ''
        object dxLayout1Item3: TdxLayoutItem
          CaptionOptions.Text = #25163#26426#21495#30721':'
          Control = EditMobileNo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
