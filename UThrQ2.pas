unit UThrQ2;

interface

uses
  System.Classes, System.SysUtils, Vcl.StdCtrls;

type
  quads2 = class(TThread)
  public
    procedure flag(fl : boolean);            //флаг завершения
  private
    procedure UpdatePInfo;                   //Synchronize
    procedure IsTerminate(Sender : TObject); //Обработчик события OnTerminate.
  protected
    procedure Execute; override;
  end;

var
  flen : boolean;

implementation

uses UCubeGL2;

{ quads2 }

procedure quads2.Execute;
begin

  NameThreadForDebugging('quad2');
  { Place thread code here }
  flen := false;

  OnTerminate := IsTerminate; //Подключаем обработчик события OnTerminate.

  Synchronize(UpdatePInfo);

end;

procedure quads2.flag(fl : boolean);
begin

  flen := fl;
  OnTerminate(self);

end;

procedure quads2.UpdatePInfo;
begin

  GLCube.TCub.Enabled := true;
  GLCube.TCir.Enabled := true;

end;

procedure quads2.IsTerminate(Sender : TObject);
begin

  with Sender as quads2 do
  begin

    if ((flen = true)) then
    begin

      GLCube.TCir.Enabled := false;
      GLCube.TCub.Enabled := false;

    end;

  end;

end;

end.
