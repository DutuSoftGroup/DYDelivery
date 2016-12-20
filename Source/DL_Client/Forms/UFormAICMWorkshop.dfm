inherited fFormAICMWorkshop: TfFormAICMWorkshop
  Left = 628
  Top = 406
  Caption = #21333#20215
  ClientHeight = 134
  ClientWidth = 326
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 326
    Height = 134
    inherited BtnOK: TButton
      Left = 180
      Top = 101
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 250
      Top = 101
      TabOrder = 4
    end
    object cbbStockNo: TcxComboBox [2]
      Left = 81
      Top = 18
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 121
    end
    object cbbStockName: TcxComboBox [3]
      Left = 81
      Top = 43
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Width = 121
    end
    object cbbWorkshop: TcxComboBox [4]
      Left = 81
      Top = 68
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        CaptionOptions.Text = ''
        object dxLayout1Item7: TdxLayoutItem
          CaptionOptions.Text = #20135#21697#32534#21495':'
          Control = cbbStockNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          CaptionOptions.Text = #20135#21697#21517#31216':'
          Control = cbbStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          CaptionOptions.Text = #21457#36135#36710#38388':'
          Control = cbbWorkshop
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
