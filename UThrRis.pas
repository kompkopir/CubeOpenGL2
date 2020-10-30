unit UThrRis;

interface

uses
  System.Classes;

type
  otrisovka = class(TThread)
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

{ otrisovka }

procedure otrisovka.Execute;
begin

  NameThreadForDebugging('risuem');
  { Place thread code here }
  flen := false;

  OnTerminate := IsTerminate; //Подключаем обработчик события OnTerminate.

  Synchronize(UpdatePInfo);

end;

procedure otrisovka.flag(fl : boolean);
begin

  flen := fl;
  OnTerminate(self);

end;

procedure otrisovka.UpdatePInfo;
begin

    if (load = false) then
    begin
      GLCube.LoadResources; {если не запускалась загрузка тестуры, =>
                                                                запустить (2.2)}
    end;

end;

procedure otrisovka.IsTerminate(Sender : TObject);
begin

  with Sender as otrisovka do
  begin

    if ((flen = true)) then
    begin

      Sleep(0);

    end;

  end;

end;

end.
