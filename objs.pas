unit objs;

interface

uses dglOpenGL, math;

type Tobj = class

   x : real;      //координата X текущая
   y : real;      //координата Y текущая
   z : real;      //координата Z текущая
   angle : real;  //угол наклона
   ci : real;     //текущий угол
   sc : real;     //скорость перемещения по окружности RANDOM
   rc : real;     //радиус окружности по которой перемещается объект RANDOM
   tj : real;     //время жизни объекта (задается пользователем)
   sl : real;     //начало жизни объекта
   el : real;     //конец жизни объекта
   pnts : boolean;//отрисован
   procedure intopar(ci0,sc0,rc0,tj0,sl0,el0 : real);//ввод числовых параметров
   procedure addcir(ci0 : real);                 //изменение прироста
   procedure paints(pnts0 : boolean);            //флаг отрисовки
   function currad(cx,cy,r: real): boolean;      //проверка x=radius, y=0
   function circle(a,r: real): TArray<real>;     //вращение по окружности
   procedure move(x0,y0,z0: real);               //перемещение по осям
   procedure movecir(x0,y0,z0: real);            //перемещение по осям циркуля
   procedure rotate(angle0: real);               //изменение угла наклона

end;

type Tstatic = class(Tobj)

   tex : GLuint;
   constructor create(x0,y0,z0: real; tex0: GLuint);

end;

implementation

procedure Tobj.intopar(ci0,sc0,rc0,tj0,sl0,el0 : real);
begin

   ci := ci0;
   sc := sc0;
   rc := rc0;
   tj := tj0;
   sl := sl0;
   el := el0;

end;

procedure Tobj.addcir(ci0 : real);
begin

   ci := ci + ci0;

end;

procedure Tobj.paints(pnts0 : boolean);
begin

   pnts := pnts0;

end;

function Tobj.currad(cx,cy,r: real): boolean;
begin

  Result := false;

  if cx = r then
    if cy = 0 then
      Result := true;

end;

function Tobj.circle(a,r: real): TArray<real>;
var
  sina,cosa: real;
begin

  sina := sin(a);
  cosa := cos(a);
  SetLength(Result, 2);
  Result[0] := r * cosa;
  Result[1] := r * sina;

end;

procedure Tobj.move(x0,y0,z0: real);
begin

  x := x + x0;
  y := y + y0;

end;

procedure Tobj.movecir(x0,y0,z0: real);
begin

  x := x0;
  y := y0;

end;

procedure Tobj.rotate(angle0: real);
begin

  angle := angle + angle0;

  if angle < 0 then
    angle := 360;
  if angle > 360 then
    angle := 0;

end;

constructor Tstatic.create(x0,y0,z0: real; tex0: GLuint);
begin

  x := x0;
  y := y0;
  z := z0;
  angle := 0;
  tex := tex0;
  ci := 0;
  sc := 0;
  rc := 0;
  tj := 0;
  sl := 0;
  el := 0;
  pnts := false;

end;

end.
