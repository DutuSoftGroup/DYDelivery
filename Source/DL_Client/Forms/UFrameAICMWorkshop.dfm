inherited fFrameAICMWorkshop: TfFrameAICMWorkshop
  Width = 686
  inherited ToolBar1: TToolBar
    Width = 686
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
    inherited BtnRefresh: TToolButton
      Caption = '   '#21047#26032'   '
    end
    inherited S2: TToolButton
      Left = 0
      Wrap = True
    end
    inherited BtnPrint: TToolButton
      Left = 0
      Top = 43
    end
    inherited BtnPreview: TToolButton
      Left = 79
      Top = 43
    end
    inherited BtnExport: TToolButton
      Left = 158
      Top = 43
    end
    inherited S3: TToolButton
      Left = 237
      Top = 43
    end
    inherited BtnExit: TToolButton
      Left = 245
      Top = 43
      Caption = #20851#38381
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 686
    Height = 165
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 686
    Height = 135
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 686
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 686
    inherited TitleBar: TcxLabel
      Caption = #33258#21161#21150#21345#31995#32479'-'#21457#36135#36710#38388#31649#29702
      Style.IsFontAssigned = True
      Width = 686
      AnchorX = 343
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 234
  end
  inherited DataSource1: TDataSource
    Top = 234
  end
end
