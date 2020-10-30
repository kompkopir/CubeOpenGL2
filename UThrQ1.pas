unit UThrQ1;

interface

uses
  System.Classes, System.SysUtils, Vcl.StdCtrls;

type
  quads1 = class(TThread)
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

{ quads1 }

procedure quads1.Execute;
begin

  NameThreadForDebugging('quad1');
  { Place thread code here }
  flen := false;

  OnTerminate := IsTerminate; //Подключаем обработчик события OnTerminate.

  Synchronize(UpdatePInfo);

end;

procedure quads1.flag(fl : boolean);
begin

  flen := fl;
  OnTerminate(self);

end;

procedure quads1.UpdatePInfo;
begin

  GLCube.TTim.Enabled := true;

end;

procedure quads1.IsTerminate(Sender : TObject);
begin

  with Sender as quads1 do
  begin

    if ((flen = true)) then
    begin

      GLCube.TTim.Enabled := false;

    end;

  end;

end;

end.
