object fFormNewCard: TfFormNewCard
  Left = 203
  Top = 70
  BorderStyle = bsNone
  Caption = #29992#25143#33258#21161#21150#21345
  ClientHeight = 542
  ClientWidth = 1147
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 1147
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 256
      Top = 56
      Width = 297
      Height = 29
      AutoSize = False
      Caption = '('#21487#24405#20837#25110#25195#25551#20108#32500#30721')'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object labelIdCard: TcxLabel
      Left = 0
      Top = 8
      Caption = #21830#22478#35746#21333#21495#65306
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -32
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object editWebOrderNo: TcxTextEdit
      Left = 176
      Top = 8
      AutoSize = False
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -32
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      OnKeyDown = editWebOrderNoKeyDown
      OnKeyPress = editWebOrderNoKeyPress
      Height = 41
      Width = 377
    end
    object btnQuery: TcxButton
      Left = 576
      Top = 8
      Width = 209
      Height = 73
      Caption = #26174#31034#32593#19978#35746#21333#35814#24773
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnQueryClick
    end
    object btnClear: TcxButton
      Left = 792
      Top = 8
      Width = 113
      Height = 73
      Caption = #28165#38500#36755#20837
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnClearClick
    end
  end
  object PanelBody: TPanel
    Left = 0
    Top = 193
    Width = 1147
    Height = 349
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object dxLayout1: TdxLayoutControl
      Left = 0
      Top = 0
      Width = 1147
      Height = 349
      Align = alClient
      TabOrder = 0
      TabStop = False
      OptionsItem.AutoControlTabOrders = False
      object BtnOK: TButton
        Left = 757
        Top = 544
        Width = 250
        Height = 41
        Caption = #30830#35748#26080#35823#24182#21150#21345
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 14
        OnClick = BtnOKClick
      end
      object BtnExit: TButton
        Left = 1013
        Top = 544
        Width = 107
        Height = 41
        Caption = #21462#28040
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 15
        OnClick = BtnExitClick
      end
      object EditValue: TcxTextEdit
        Left = 367
        Top = 489
        ParentFont = False
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 13
        OnKeyPress = EditValueKeyPress
        Width = 120
      end
      object EditCard: TcxTextEdit
        Left = 78
        Top = 55
        ParentFont = False
        Properties.MaxLength = 15
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 1
        Width = 125
      end
      object EditID: TcxTextEdit
        Left = 78
        Top = 28
        ParentFont = False
        Properties.MaxLength = 100
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 0
        Width = 125
      end
      object EditCus: TcxTextEdit
        Left = 78
        Top = 82
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 2
        Width = 121
      end
      object EditCName: TcxTextEdit
        Left = 78
        Top = 125
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 3
        Width = 121
      end
      object EditMan: TcxTextEdit
        Left = 78
        Top = 168
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 4
        Width = 121
      end
      object EditDate: TcxTextEdit
        Left = 78
        Top = 195
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 5
        Width = 121
      end
      object EditFirm: TcxTextEdit
        Left = 78
        Top = 222
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 6
        Width = 121
      end
      object EditArea: TcxTextEdit
        Left = 78
        Top = 249
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 7
        Width = 121
      end
      object EditStock: TcxTextEdit
        Left = 78
        Top = 360
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 8
        Width = 227
      end
      object EditSName: TcxTextEdit
        Left = 367
        Top = 360
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 9
        Width = 336
      end
      object EditMax: TcxTextEdit
        Left = 367
        Top = 446
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 10
        Width = 121
      end
      object EditTruck: TcxButtonEdit
        Left = 78
        Top = 489
        ParentFont = False
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.ButtonStyle = bts3D
        Style.IsFontAssigned = True
        TabOrder = 12
        Width = 227
      end
      object EditType: TcxComboBox
        Left = 78
        Top = 403
        ParentFont = False
        Properties.DropDownListStyle = lsEditFixedList
        Properties.ItemHeight = 18
        Properties.Items.Strings = (
          'C=C'#12289#26222#36890
          'Z=Z'#12289#26632#21488
          'V=V'#12289'VIP'
          'S=S'#12289#33337#36816)
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.ButtonStyle = bts3D
        Style.PopupBorderStyle = epbsFrame3D
        Style.IsFontAssigned = True
        TabOrder = 11
        Width = 227
      end
      object EditTrans: TcxTextEdit
        Left = 78
        Top = 303
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 16
        Width = 121
      end
      object EditWorkAddr: TcxTextEdit
        Left = 78
        Top = 276
        ParentFont = False
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        TabOrder = 18
        Width = 121
      end
      object PrintFH: TcxCheckBox
        Left = 10
        Top = 544
        Caption = #20986#21378#25171#21360#29289#36164#21457#36135#21333#65288#21363#25910#36153#21333#65289
        ParentFont = False
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 20
        Transparent = True
        Width = 471
      end
      object EditFQ: TcxButtonEdit
        Left = 78
        Top = 446
        ParentFont = False
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.OnButtonClick = EditFQPropertiesButtonClick
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.ButtonStyle = bts3D
        Style.IsFontAssigned = True
        TabOrder = 17
        Width = 227
      end
      object EditGroup: TcxComboBox
        Left = 367
        Top = 403
        ParentFont = False
        Style.BorderColor = clWindowFrame
        Style.BorderStyle = ebs3D
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -24
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = []
        Style.ButtonStyle = bts3D
        Style.PopupBorderStyle = epbsFrame3D
        Style.IsFontAssigned = True
        TabOrder = 19
        Width = 135
      end
      object dxLayoutGroup1: TdxLayoutGroup
        AlignHorz = ahParentManaged
        AlignVert = avParentManaged
        CaptionOptions.Visible = False
        ButtonOptions.Buttons = <>
        Hidden = True
        ShowBorder = False
        object dxGroup1: TdxLayoutGroup
          AlignVert = avTop
          CaptionOptions.Text = #22522#26412#20449#24687
          ButtonOptions.Buttons = <>
          object dxGroupLayout1Group2: TdxLayoutGroup
            CaptionOptions.Visible = False
            ButtonOptions.Buttons = <>
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutGroup2: TdxLayoutGroup
              AlignHorz = ahClient
              ButtonOptions.Buttons = <>
              Hidden = True
              ShowBorder = False
              object dxLayout1Item5: TdxLayoutItem
                AlignHorz = ahClient
                CaptionOptions.Text = #35760#24405#32534#21495':'
                Control = EditID
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item9: TdxLayoutItem
                AlignHorz = ahClient
                CaptionOptions.Text = #21345#29255#32534#21495':'
                Control = EditCard
                ControlOptions.ShowBorder = False
              end
            end
          end
          object dxlytmLayout1Item3: TdxLayoutItem
            CaptionOptions.Text = #23458#25143#32534#21495':'
            Control = EditCus
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item4: TdxLayoutItem
            CaptionOptions.Text = #23458#25143#21517#31216':'
            Control = EditCName
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item5: TdxLayoutItem
            CaptionOptions.Text = #24320' '#21333' '#20154':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item6: TdxLayoutItem
            CaptionOptions.Text = #24320#21333#26102#38388':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item7: TdxLayoutItem
            CaptionOptions.Text = #21457#36135#24037#21378':'
            Control = EditFirm
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item8: TdxLayoutItem
            CaptionOptions.Text = #38144#21806#29255#21306':'
            Control = EditArea
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            CaptionOptions.Text = #24037#31243#24037#22320':'
            Control = EditWorkAddr
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            CaptionOptions.Text = #36816#36755#21333#20301':'
            Control = EditTrans
            ControlOptions.ShowBorder = False
          end
        end
        object dxGroup2: TdxLayoutGroup
          AlignVert = avTop
          CaptionOptions.Text = #25552#21333#20449#24687
          ButtonOptions.Buttons = <>
          object dxLayout1Group1: TdxLayoutGroup
            ButtonOptions.Buttons = <>
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxlytmLayout1Item9: TdxLayoutItem
              CaptionOptions.Text = #27700#27877#32534#21495':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item10: TdxLayoutItem
              AlignHorz = ahLeft
              CaptionOptions.Text = #27700#27877#21517#31216':'
              Control = EditSName
              ControlOptions.ShowBorder = False
            end
          end
          object dxGroupLayout1Group5: TdxLayoutGroup
            CaptionOptions.Visible = False
            ButtonOptions.Buttons = <>
            Hidden = True
            ShowBorder = False
            object dxLayout1Group4: TdxLayoutGroup
              CaptionOptions.Visible = False
              ButtonOptions.Buttons = <>
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxlytmLayout1Item13: TdxLayoutItem
                CaptionOptions.Text = #25552#36135#36890#36947':'
                Control = EditType
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item12: TdxLayoutItem
                CaptionOptions.Text = #36890#36947#20998#32452':'
                Control = EditGroup
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group3: TdxLayoutGroup
              CaptionOptions.Visible = False
              ButtonOptions.Buttons = <>
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item11: TdxLayoutItem
                CaptionOptions.Text = #20986#21378#32534#21495':'
                Control = EditFQ
                ControlOptions.ShowBorder = False
              end
              object dxlytmLayout1Item11: TdxLayoutItem
                AlignHorz = ahClient
                CaptionOptions.Text = #21487#25552#36135#37327':'
                Control = EditMax
                ControlOptions.ShowBorder = False
              end
            end
            object dxGroupLayout1Group6: TdxLayoutGroup
              CaptionOptions.Visible = False
              ButtonOptions.Buttons = <>
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxlytmLayout1Item12: TdxLayoutItem
                CaptionOptions.Text = #25552#36135#36710#36742':'
                Control = EditTruck
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item8: TdxLayoutItem
                AlignHorz = ahClient
                CaptionOptions.Text = #21150#29702#21544#25968':'
                Control = EditValue
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
        object dxLayoutGroup3: TdxLayoutGroup
          AlignVert = avTop
          CaptionOptions.Visible = False
          ButtonOptions.Buttons = <>
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            CaptionOptions.Text = 'cxCheckBox1'
            CaptionOptions.Visible = False
            Control = PrintFH
            ControlOptions.ShowBorder = False
          end
          object dxLayoutItem1: TdxLayoutItem
            AlignHorz = ahRight
            CaptionOptions.Text = 'Button1'
            CaptionOptions.Visible = False
            Control = BtnOK
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item2: TdxLayoutItem
            AlignHorz = ahRight
            CaptionOptions.Text = 'Button2'
            CaptionOptions.Visible = False
            Control = BtnExit
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
  object pnlMiddle: TPanel
    Left = 0
    Top = 89
    Width = 1147
    Height = 104
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlMiddle'
    TabOrder = 2
    object cxLabel1: TcxLabel
      Left = 0
      Top = 0
      Align = alTop
      Caption = #35746#21333#21015#34920
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = 'MS Sans Serif'
      Style.Font.Style = []
      Style.IsFontAssigned = True
    end
    object lvOrders: TListView
      Left = 0
      Top = 28
      Width = 1147
      Height = 76
      Align = alClient
      Columns = <>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      RowSelect = True
      ParentFont = False
      TabOrder = 1
      OnClick = lvOrdersClick
    end
  end
  object TimerAutoClose: TTimer
    Enabled = False
    OnTimer = TimerAutoCloseTimer
    Left = 528
    Top = 89
  end
end
