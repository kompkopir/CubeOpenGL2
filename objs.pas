unit objs;

interface

uses dglOpenGL, math;

type Tobj = class

   x : real;      //���������� X �������
   y : real;      //���������� Y �������
   z : real;      //���������� Z �������
   angle : real;  //���� �������
   ci : real;     //������� ����
   sc : real;     //�������� ����������� �� ���������� RANDOM
   rc : real;     //������ ���������� �� ������� ������������ ������ RANDOM
   tj : real;     //����� ����� ������� (�������� �������������)
   sl : real;     //������ ����� �������
   el : real;     //����� ����� �������
   pnts : boolean;//���������
   procedure intopar(ci0,sc0,rc0,tj0,sl0,el0 : real);//���� �������� ����������
   procedure addcir(ci0 : real);                 //��������� ��������
   procedure paints(pnts0 : boolean);            //���� ���������
   function currad(cx,cy,r: real): boolean;      //�������� x=radius, y=0
   function circle(a,r: real): TArray<real>;     //�������� �� ����������
   procedure move(x0,y0,z0: real);               //����������� �� ����
   procedure movecir(x0,y0,z0: real);            //����������� �� ���� �������
   procedure rotate(angle0: real);               //��������� ���� �������

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
