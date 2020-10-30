program CubeDoublGL2;

uses
  Vcl.Forms,
  UCubeGL2 in 'UCubeGL2.pas' {GLCube},
  objs in 'objs.pas',
  UThrQ1 in 'UThrQ1.pas',
  UThrQ2 in 'UThrQ2.pas',
  UThrRis in 'UThrRis.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGLCube, GLCube);
  Application.Run;
end.
