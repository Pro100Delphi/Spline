program Project1;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Geometry in 'Geometry.pas',
  Component in 'Component.pas',
  Polygon in 'Polygon.pas',
  Core in 'Core.pas',
  Spline in 'Spline.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
