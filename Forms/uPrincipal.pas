unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, System.Rtti, FMX.Layouts,
  FMX.Grid, ACBrBase, ACBrDFe, ACBrNFe;

type
  TfrmPrincipal = class(TForm)
    recAll: TRectangle;
    txtTitulo: TText;
    recBottom: TRectangle;
    recLeft: TRectangle;
    recMenuTopo: TRectangle;
    recRigth: TRectangle;
    recGeral: TRectangle;
    recAnalisar: TRectangle;
    recBtnAnalisar: TRectangle;
    btnAnalisar: TText;
    recEdtDiretorio: TRectangle;
    edtDiretorio: TEdit;
    btnDiretorio: TEdit;
    imgLogo: TImage;
    OpenDialog1: TOpenDialog;
    recOpcoes: TRectangle;
    cbAutorizadas: TCheckBox;
    recOpcoesAutorizadas: TRectangle;
    recEdtAutorizadas: TRectangle;
    edtAutorizadas: TEdit;
    recOpcoesContingencias: TRectangle;
    cbContingencias: TCheckBox;
    recEdtContingencias: TRectangle;
    edtContingencias: TEdit;
    recResultados: TRectangle;
    recOpcoesResultados: TRectangle;
    recAutorizadas: TRectangle;
    txtAutorizadas: TText;
    recContingencias: TRectangle;
    txtContingencias: TText;
    txtValor: TText;
    Grid: TStringGrid;
    scNF: TStringColumn;
    scSerie: TStringColumn;
    scCNPJDest: TStringColumn;
    scNomeDest: TStringColumn;
    scCNPJEmit: TStringColumn;
    scTotal: TStringColumn;
    ACBrNFe1: TACBrNFe;
    recEmitidas: TRectangle;
    txtEmitidas: TText;
    procedure btnDiretorioClick(Sender: TObject);
    procedure cbAutorizadasChange(Sender: TObject);
    procedure cbContingenciasChange(Sender: TObject);
    procedure btnAnalisarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CarregarNota(Caminho : String);
  end;

var
  frmPrincipal: TfrmPrincipal;

  IGrid, Situacao : Integer;
  Emitidas, Autorizadas, Contingencias : Integer;
  ValorSomado : Currency;

implementation

{$R *.fmx}

{$REGION 'Opções'}
procedure TfrmPrincipal.cbAutorizadasChange(Sender: TObject);
begin
  recEdtAutorizadas.Enabled := False;
  if cbAutorizadas.IsChecked = True then
    recEdtAutorizadas.Enabled := True;
end;

procedure TfrmPrincipal.cbContingenciasChange(Sender: TObject);
begin
  recEdtContingencias.Enabled := False;
  if cbContingencias.IsChecked = True then
    recEdtContingencias.Enabled := True;
end;
{$ENDREGION}

{$REGION 'Geral'}
procedure TfrmPrincipal.btnDiretorioClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    edtDiretorio.Text := ExtractFilePath(OpenDialog1.FileName);
end;

procedure TfrmPrincipal.btnAnalisarClick(Sender: TObject);
var
  I : Integer;
  SR : TSearchRec;
begin
  if (cbAutorizadas.IsChecked = False) and (cbContingencias.IsChecked = False) then
  begin
    ShowMessage('Marque pelo menos uma opção!');
    Abort;
  end;

  if edtDiretorio.Text = '' then
  begin
    ShowMessage('Diretório vazio!');
    btnDiretorioClick(Sender);
    Abort;
  end;

  edtDiretorio.ReadOnly  := True;
  btnDiretorio.Enabled   := False;
  recBtnAnalisar.Enabled := False;

  ValorSomado := 0;
  Grid.RowCount := 0;
  IGrid := 0;

  Emitidas := 0;
  Autorizadas := 0;
  Contingencias := 0;

  txtEmitidas.Text      := '0 Emitidas';
  txtAutorizadas.Text   := '0 Autorizadas';
  txtContingencias.Text := '0 Contingências';

  txtValor.Text := 'R$ 0,00';

  I := FindFirst(edtDiretorio.Text+'*.xml', faAnyFile, SR);
  while I = 0 do
  begin
    if cbAutorizadas.IsChecked = True then
    begin
      if Pos(edtAutorizadas.Text, SR.Name) > 0 then
      begin
        Situacao := 4;
        CarregarNota(SR.Name);

        Inc(Autorizadas);
        txtAutorizadas.Text := IntToStr(Autorizadas) + ' Autorizadas';

        Inc(IGrid);
      end;
    end;

    if cbContingencias.IsChecked = True then
    begin
      if Pos(edtContingencias.Text, SR.Name) > 0 then
      begin
        Situacao := 5;
        CarregarNota(SR.Name);

        Inc(Contingencias);
        txtContingencias.Text := IntToStr(Contingencias) + ' Contingências';

        Inc(IGrid);
      end;
    end;

    I := FindNext(SR);
  end;

  edtDiretorio.ReadOnly  := False;
  btnDiretorio.Enabled   := True;
  recBtnAnalisar.Enabled := True;
end;
{$ENDREGION}

procedure TfrmPrincipal.CarregarNota(Caminho: String);
var
  Caminho2 : String;
begin
  Application.ProcessMessages;

  Caminho := edtDiretorio.Text + Caminho;

  Grid.RowCount := Grid.RowCount + 1;

  ACBrNFe1.NotasFiscais.Clear;
  ACBrNFe1.NotasFiscais.LoadFromFile(Caminho);

  if Situacao = 4 then
  begin
    Caminho2 := edtDiretorio.Text + ACBrNFe1.NotasFiscais[0].NFe.procNFe.chNFe + '-caneve.xml';

    if FileExists(Caminho2) = False then
    begin
      ValorSomado := ValorSomado + ACBrNFe1.NotasFiscais[0].NFe.Total.ICMSTot.vNF;
      txtValor.Text := 'R$ ' + FormatFloat('#0.00', ValorSomado);
    end
    else
      Exit;
  end;

  if Situacao = 5 then
  begin
    ValorSomado := ValorSomado + ACBrNFe1.NotasFiscais[0].NFe.Total.ICMSTot.vNF;
    txtValor.Text := 'R$ ' + FormatFloat('#0.00', ValorSomado);
  end;

  Grid.Cells[0, IGrid] := IntToStr(ACBrNFe1.NotasFiscais[0].NFe.Ide.nNF);

  Application.ProcessMessages;

  Grid.Cells[1, IGrid] := IntToStr(ACBrNFe1.NotasFiscais[0].NFe.Ide.serie);

  Application.ProcessMessages;

  Grid.Cells[2, IGrid] := ACBrNFe1.NotasFiscais[0].NFe.Dest.CNPJCPF;

  Application.ProcessMessages;

  Grid.Cells[3, IGrid] := ACBrNFe1.NotasFiscais[0].NFe.Dest.xNome;

  Application.ProcessMessages;

  Grid.Cells[4, IGrid] := ACBrNFe1.NotasFiscais[0].NFe.Emit.CNPJCPF;

  Application.ProcessMessages;

  Grid.Cells[5, IGrid] := CurrToStr(ACBrNFe1.NotasFiscais[0].NFe.Total.ICMSTot.vNF);

  Application.ProcessMessages;

  Inc(Emitidas);
  txtEmitidas.Text := IntToStr(Emitidas) + ' Emitidas';

  Application.ProcessMessages;
end;

end.
