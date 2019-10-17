unit dRegistros;

interface

uses
  System.SysUtils, System.Classes, cxGrid, Data.DB, Datasnap.DBClient, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, cxDataControllerConditionalFormattingRulesManagerDialog,
  cxDBData, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxSpinEdit, cxImageComboBox, uAtividade;

type
  TInfoRegistro = record
    inicio: TDateTime;
    chamado: Integer;
    atividade: TAtividades;
    comentario: string;

  end;

  TDmRegistros = class(TDataModule)
    cxGridViewRepository1: TcxGridViewRepository;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    cxGridViewRepository1DBTableView1: TcxGridDBTableView;
    cxGridViewRepository1DBTableView1tempo: TcxGridDBColumn;
    cxGridViewRepository1DBTableView1tarefa: TcxGridDBColumn;
    cxGridViewRepository1DBTableView1atividade: TcxGridDBColumn;
    cxGridViewRepository1DBTableView1comentario: TcxGridDBColumn;
    ClientDataSet1tempo: TCurrencyField;
    ClientDataSet1tarefa: TIntegerField;
    ClientDataSet1atividade: TIntegerField;
    ClientDataSet1comentario: TWideStringField;
    ClientDataSet1projeto: TIntegerField;
    ClientDataSet1data: TDateField;
    cxGridViewRepository1DBTableView1projeto: TcxGridDBColumn;
    cxGridViewRepository1DBTableView1data: TcxGridDBColumn;

    procedure DataModuleCreate(Sender: TObject);
    procedure cxGridViewRepository1DBTableView1TcxGridDBDataControllerTcxDataSummaryFooterSummaryItems0GetText
      (Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean; var AText: string);

  private const
    FILE_INI = 'Horas.grd';
    procedure Rodar;

  private
    FRegistroAtual: TInfoRegistro;
    FRodando: Boolean;

    procedure SetRegistroAtual(const Value: TInfoRegistro);

    function GetTempo: Currency;
    procedure AddRegistro;
    procedure TranslateGrid;

  public
    procedure Parar;
    procedure SaveGrid;
    procedure ContinuarSelecionado;

    property RegistroAtual: TInfoRegistro read FRegistroAtual write SetRegistroAtual;

  end;

var
  DmRegistros: TDmRegistros;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{ TDataModule3 }

uses
  dxCore, cxGridStrs, System.DateUtils, System.Math, Vcl.Dialogs, System.Variants, fHoras, dOpcoes;


procedure TDmRegistros.SaveGrid;
begin
  cxGridViewRepository1DBTableView1.StoreToIniFile(FILE_INI, False);
end;


procedure TDmRegistros.Rodar;
begin
  FRodando := True;
  FrmHoras.Timer1.Enabled := True;
  DmOpcoes.Parar1.Enabled := True;
end;


procedure TDmRegistros.TranslateGrid;
begin
  cxSetResourceString(@scxGridNoDataInfoText, 'Sem horas registradas');
  cxSetResourceString(@scxGridGroupByBoxCaption, 'Arraste para agrupar');
  cxSetResourceString(@scxGridDeletingFocusedConfirmationText, 'Remover registro?');
end;


procedure TDmRegistros.SetRegistroAtual(const Value: TInfoRegistro);
begin
  if FRodando then
    AddRegistro;
  FRegistroAtual := Value;
  Rodar;
end;


procedure TDmRegistros.ContinuarSelecionado;
var
  info: TInfoRegistro;
begin
  info := default (TInfoRegistro);

  info.inicio := IncMinute(now, - Trunc((ClientDataSet1tempo.Value * 60)));
  info.chamado := ClientDataSet1tarefa.Value;
  info.atividade := TAtividades(ClientDataSet1atividade.Value);
  info.comentario := ClientDataSet1comentario.Value;

  ClientDataSet1.Delete;

  DmOpcoes.SetHints(info.atividade.ToString + ': ' + info.chamado.ToString);
  SetRegistroAtual(info);
end;


procedure TDmRegistros.cxGridViewRepository1DBTableView1TcxGridDBDataControllerTcxDataSummaryFooterSummaryItems0GetText
  (Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean; var AText: string);
begin
  case VarType(AValue) of
    varCurrency, varDouble, varSmallint, varInteger, varShortInt, varWord, varInt64:
      AText := FormatFloat('0.00', AValue);
  else
    AText := '';
  end;
end;


procedure TDmRegistros.DataModuleCreate(Sender: TObject);
begin
  TranslateGrid;
  cxGridViewRepository1DBTableView1.RestoreFromIniFile(FILE_INI);
end;


function TDmRegistros.GetTempo: Currency;
begin
  Result := RoundTo(MinutesBetween(now, FRegistroAtual.inicio) / 60, - 2);
end;


procedure TDmRegistros.Parar;
begin
  if FRodando then
    AddRegistro;
  FRodando := False;
  FRegistroAtual := default (TInfoRegistro);
  FrmHoras.Timer1.Enabled := False;
  DmOpcoes.SetHints('Parado');
  DmOpcoes.Parar1.Enabled := False;
  if Assigned(DmOpcoes.ItemSelecionado) then
  begin
    DmOpcoes.ItemSelecionado.Parent.Checked := False;
    DmOpcoes.ItemSelecionado.Checked := False;
  end;
  FrmHoras.dxRibbonStatusBar1.Panels[1].Text := '00:00:00';
end;


procedure TDmRegistros.AddRegistro;
begin
  ClientDataSet1.Append;
  ClientDataSet1tempo.Value := GetTempo;
  ClientDataSet1tarefa.Value := FRegistroAtual.chamado;
  ClientDataSet1atividade.Value := Ord(FRegistroAtual.atividade);
  ClientDataSet1comentario.Value := FRegistroAtual.comentario.Replace('&', '');
  ClientDataSet1data.Value := Today;
  ClientDataSet1projeto.Value := FrmHoras.edtRedmineProjeto.EditValue;
  ClientDataSet1.Post;
end;

end.