program AnalisadorXML;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'Forms\uPrincipal.pas' {frmPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
