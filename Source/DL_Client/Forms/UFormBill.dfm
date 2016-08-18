inherited fFormBill: TfFormBill
  Left = 501
  Top = 85
  ClientHeight = 509
  ClientWidth = 443
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 443
    Height = 509
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 297
      Top = 476
      Caption = #24320#21333
      TabOrder = 14
    end
    inherited BtnExit: TButton
      Left = 367
      Top = 476
      TabOrder = 16
    end
    object EditValue: TcxTextEdit [2]
      Left = 282
      Top = 419
      ParentFont = False
      TabOrder = 13
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditCard: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditID: TcxTextEdit [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditCus: TcxTextEdit [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCName: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditMan: TcxTextEdit [7]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditDate: TcxTextEdit [8]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditFirm: TcxTextEdit [9]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditArea: TcxTextEdit [10]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 7
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [11]
      Left = 81
      Top = 319
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 8
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditSName: TcxTextEdit [12]
      Left = 81
      Top = 344
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 9
      OnKeyPress = EditLadingKeyPress
      Width = 336
    end
    object EditMax: TcxTextEdit [13]
      Left = 282
      Top = 394
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 10
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [14]
      Left = 81
      Top = 419
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 12
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditType: TcxComboBox [15]
      Left = 81
      Top = 369
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 11
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditTrans: TcxTextEdit [16]
      Left = 81
      Top = 261
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 19
      Width = 121
    end
    object EditMemo: TcxTextEdit [17]
      Left = 81
      Top = 444
      ParentFont = False
      TabOrder = 20
      Width = 121
    end
    object EditWorkAddr: TcxTextEdit [18]
      Left = 81
      Top = 236
      ParentFont = False
      TabOrder = 21
      Width = 121
    end
    object PrintFH: TcxCheckBox [19]
      Left = 11
      Top = 476
      Caption = #25171#21360#29289#36164#21457#36135#21333
      ParentFont = False
      TabOrder = 22
      Transparent = True
      Width = 121
    end
    object PrintHGZ: TcxCheckBox [20]
      Left = 137
      Top = 476
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      TabOrder = 23
      Transparent = True
      Width = 121
    end
    object EditFQ: TcxButtonEdit [21]
      Left = 81
      Top = 394
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditFQPropertiesButtonClick
      TabOrder = 24
      OnKeyPress = EditLadingKeyPress
      Width = 138
    end
    object EditGroup: TcxComboBox [22]
      Left = 282
      Top = 369
      ParentFont = False
      Properties.OnEditValueChanged = EditGroupPropertiesEditValueChanged
      TabOrder = 25
      Width = 135
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxGroupLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #35760#24405#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21345#29255#32534#21495':'
            Control = EditCard
            ControlOptions.ShowBorder = False
          end
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCName
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item5: TdxLayoutItem
          Caption = #24320' '#21333' '#20154':'
          Control = EditMan
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item6: TdxLayoutItem
          Caption = #24320#21333#26102#38388':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item7: TdxLayoutItem
          Caption = #21457#36135#24037#21378':'
          Control = EditFirm
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item8: TdxLayoutItem
          Caption = #38144#21806#29255#21306':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #24037#31243#24037#22320':'
          Control = EditWorkAddr
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36816#36755#21333#20301':'
          Control = EditTrans
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxlytmLayout1Item9: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #27700#27877#21517#31216':'
          Control = EditSName
          ControlOptions.ShowBorder = False
        end
        object dxGroupLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item13: TdxLayoutItem
              Caption = #25552#36135#36890#36947':'
              Control = EditType
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item12: TdxLayoutItem
              Caption = #36890#36947#20998#32452':'
              Control = EditGroup
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item11: TdxLayoutItem
              Caption = #20986#21378#32534#21495':'
              Control = EditFQ
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item11: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21487#25552#36135#37327':'
              Control = EditMax
              ControlOptions.ShowBorder = False
            end
          end
          object dxGroupLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group2: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxlytmLayout1Item12: TdxLayoutItem
                Caption = #25552#36135#36710#36742':'
                Control = EditTruck
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item8: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #21150#29702#21544#25968':'
                Control = EditValue
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Item4: TdxLayoutItem
              Caption = #22791'    '#27880':'
              Control = EditMemo
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = PrintFH
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem [1]
          Caption = 'cxCheckBox2'
          ShowCaption = False
          Control = PrintHGZ
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
