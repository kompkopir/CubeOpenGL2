unit UCubeGL2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dglOpenGL,
  Vcl.ExtCtrls, ImagingOpenGL, objs, math, Vcl.StdCtrls;

type
  TGLCube = class(TForm)
    TCub: TTimer;
    TTim: TTimer;
    TCir: TTimer;
    PInfo: TPanel;
    leTJ: TLabeledEdit;
    PLive: TPanel;
    PQuad: TPanel;
    lblCountQuads: TLabel;
    mCubes: TMemo;
    lblSled: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure IdleHandler(Sender : TObject; var Done : Boolean);
    procedure DrawObjStatic (obj: Tstatic; pan: integer);
    procedure TCubTimer(Sender: TObject);
    procedure TTimTimer(Sender: TObject);
    procedure TCirTimer(Sender: TObject);
    procedure leTJChange(Sender: TObject);
  private
    dc  : HDC;
    hrc : HGLRC;
  public
    procedure LoadResources;
    procedure SetupGL;
    procedure RenderFon;
    procedure bedcube(mat: integer);
    procedure updpara(timepro : real);
  protected
    { Protected declarations }
  end;

const
  NearClipping = 0.1;       //Ближняя плоскость отсечения
  FarClipping  = 100;       //Дальняя плоскость отсечения
  StartX = 0.00;            //Начальная координата X
  StartY = 0.00;            //Начальная координата Y
  LEN  = -50.00;            //Начальная координата Z

var
  GLCube: TGLCube;
  zoom: Real = 1;           //приближение отдаление камеры
  tex1 : GLuint = 0;        //текстура 1
  tex2 : GLuint = 0;        //текстура 2
  tex3 : GLuint = 0;        //текстура 3
  tex4 : GLuint = 0;        //текстура 4
  tex5 : GLuint = 0;        //текстура 5
  tex6 : GLuint = 0;        //текстура 6
  intqs : integer;          //произвольное количество quads
  sledq : integer;          //следит за количеством quads
  quads : Array [1..10] of Tstatic; //массив объектов

  cir  : real = 0;          //прирост циркуля
  cirS : real = 0;          //скорость прироста циркуля
  cirX : real = 0;          //координата X циркуля
  cirY : real = 0;          //координата Y циркуля
  radius : real = 0;        //радиус
  startlive : real = 0;     //начало жизни
  timelive  : real = 0;     //время жизни
  timeprog  : real = 0;     //время работы программы
  startlast : real = 0;     //начало жизни цикл
  onetime   : real = 1;     //первая задержка

  load : boolean = false;   //флаг загрузки текстур
  firstz : boolean = false; //флаг установки на первый запуск
  radboo : boolean = false; //флаг установки на радиус
  stlibo : boolean = false; //флаг начала жизни объекта
  tilibo : boolean = true;  //флаг окончание жизни объекта
  izmtli : boolean = false; //флаг изменения timelive

implementation

{$R *.dfm}

uses UThrQ1, UThrQ2, UThrRis;

var
  ThrQ1 : quads1;           //главный поток
  ThrQ2 : quads2;           //поток управления объектами
  Ris   : otrisovka;        //поток загрузки ресурсов

//----------------------------------------------------------------------------
{создание формы}
procedure TGLCube.FormCreate(Sender: TObject);
begin
  dc := GetDC(Handle); //получаем контекст устройства по форме GLCube

  {с InitOpenGL инициализирцется OpenGL, если это не удается то приложение
                                                              закрывается}
  if  not InitOpenGL then Application.Terminate;

  //создание контекста рендеринга
  hrc := CreateRenderingContext(dc,[opDoubleBuffered],32,24,0,0,0,0);

  ActivateRenderingContext(dc,hrc);   //активаци контекста рендеринга
  SetupGL;                            {запуск джиэля/определение количества
                                                                  кубов (1.0)}
end;

{при изменении размера формы}
procedure TGLCube.FormResize(Sender: TObject);
var
  tmpBool : Boolean;
begin
  idleHandler(Sender,tmpBool);
end;

{при изменение времени жизни}
procedure TGLCube.leTJChange(Sender: TObject);
begin

  if(Length(leTJ.Text) <= 0) then leTJ.Text := '0';

  timelive  := StrToInt(leTJ.Text);  {юзер}     //установка время жизни
  izmtli := true; //флаг изменения timelive

end;

{key and mouse формы}
procedure TGLCube.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

//  if Key = VK_LEFT then
//    quad1.move(-0.3,0,0);
//  if Key = VK_RIGHT then
//    quad1.move(0.3,0,0);

//  if Key = VK_UP then
//    quad3.move(0,0.3,0);
//  if Key = VK_DOWN then
//    quad3.move(0,-0.3,0);

//  if Key = VK_HOME then
//    quad2.rotate(10);
//  if Key = VK_END then
//    quad2.rotate(-10);

  if Key = VK_ESCAPE then
    Close;

end;

procedure TGLCube.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  zoom := zoom + 3; //отъехать

end;

procedure TGLCube.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  if zoom > 1 then     //подъехать
     zoom := zoom - 3
  else zoom := 1;

end;

{удаление формы}
procedure TGLCube.FormDestroy(Sender: TObject);
begin

  DeactivateRenderingContext;
  DestroyRenderingContext(hrc);
  ReleaseDC(Handle,dc);

  if ThrQ1 <> nil then
  begin
    ThrQ1.Terminate;
    FreeAndNil(ThrQ1);
  end;

  if ThrQ2 <> nil then
  begin
    ThrQ2.Terminate;
    FreeAndNil(ThrQ2);
  end;

  if Ris <> nil then
  begin
    Ris.Terminate;
    FreeAndNil(Ris);
  end;

end;
//============================================================================

//----------------------------------------------------------------------------
{операции над графикой}

{1.0 запуск джиэля/определение количества кубов}
procedure TGLCube.SetupGL;
begin

  ThrQ1 := quads1.Create(false);
  ThrQ1.Priority := tpHigher;

  onetime := 1;     //первая задержка

  load := false;   //флаг загрузки текстур
  firstz := false; //флаг установки на первый запуск
  radboo := false; //флаг установки на радиус
  stlibo := false; //флаг начала жизни объекта
  tilibo := true;  //флаг окончание жизни объекта
  izmtli := false; //флаг изменения timelive

  intqs := 2 + Random(8);
  sledq := intqs;

  mCubes.Lines.Clear;

  Application.OnIdle := IdleHandler;  {разгрузка процессора и запуска процесса
                                      подготовки и формирования графики (2.0)}
end;

{2.0 разгрузка процессора и запуска процесса подготовки и формирования фона}
procedure TGLCube.IdleHandler(Sender : TObject; var Done : Boolean);
begin

    RenderFon;  //установка матрицы, запуск отрисовки фона, замена буферов (2.1)
    Sleep(1);
    Done := false;

end;

{2.1 установка матрицы, запуск отрисовки, замена буферов}
procedure TGLCube.RenderFon;
var
  i: integer;
begin

  if (sledq > 0) then
  begin

    glClearColor(0.5, 0.5, 0.8, 0); //установка цвета формы
    glEnable(GL_DEPTH_TEST);        //включить режим тест глубины
    glEnable(GL_CULL_FACE);         {включить режим отображения только передних
                                                                   поверхностей}

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);  {очистка экрана и
                                                окрашивание его заданным цветом}

    glViewport(0,0,ClientWidth,ClientHeight); //установка области видимости

    glMatrixMode(GL_PROJECTION);              //обозначили матрицу с режимом
    glLoadIdentity;                           //обнулили матрицу
    gluPerspective(45.0,ClientWidth/ClientHeight,NearClipping,FarClipping);

    {НАЧАЛО модель для отрисовки точки центра}
    glMatrixMode(GL_MODELVIEW);            //обозначили матрицу с режимом
    glLoadIdentity;                        //обнулили матрицу
    gluLookAt(0, 0, zoom, //x y z позиция камеры z
              0, 0, 0, //x y z камера смотрит на 0
              0, 1, 0  {x y z вектор вверх на y (+z дальше от экрана,
                                                 -z ближе;
                                                 +y вверх, -y вниз;
                                                 +x вправо, -x влево}
             );
    glPointSize(5);                         //размер точки
    glBegin(GL_POINTS);                     //модуль рисования
      glColor3d(1,1,1);  glVertex3d(0,0,0); // точка
    glEnd;
    {КОНЕЦ модель для отрисовки точки центра}

    glEnable(GL_TEXTURE_2D);                 //активация 2д текстур

  //  для нескольких кубов через поток UThrQ2 по количеству intqs
    if ((load = true) and (stlibo = true) and (tilibo = false)) then
    begin

      if Ris <> nil then
      begin
        Ris.flag(true);
        FreeAndNil(Ris);
      end;

      for i := 1 to intqs do
      begin

        if ((quads[i] <> nil) and (timeprog >= quads[i].sl) and
                                      (timeprog < quads[i].el)) then
        begin
          {НАЧАЛО модель для отрисовки куба, на каждый куб}
          glMatrixMode(GL_MODELVIEW);            //обозначили матрицу с режимом
          glLoadIdentity;                        //обнулили матрицу
          gluLookAt(0, 0, zoom, //x y z позиция камеры z
                    0, 0, 0, //x y z камера смотрит на 0
                    0, 1, 0  {x y z вектор вверх на y (+z дальше от экрана,
                                                       -z ближе;
                                                       +y вверх, -y вниз;
                                                       +x вправо, -x влево}
                   );
          {КОНЕЦ модель для отрисовки куба, на каждый куб}

          DrawObjStatic(quads[i],i);           //отрисовка куба как объект (2.3)
        end;

        if ((quads[i] <> nil) and (timeprog >= quads[i].el)) then
        begin
          bedcube(i);                          //уничтожить куб
        end;

      end;
    end;

    SwapBuffers(dc);                          {поменять местами буфер графики и
                                                                  буфер экрана}
  end;
end;

{2.2 загрузка текстуры}
procedure TGLCube.LoadResources;
var
  i: Integer;
begin

  tex1  := LoadGLTextureFromFile('1.jpg'); //загрузка текстуры 1
  tex2  := LoadGLTextureFromFile('2.jpg'); //загрузка текстуры 2
  tex3  := LoadGLTextureFromFile('3.jpg'); //загрузка текстуры 3
  tex4  := LoadGLTextureFromFile('4.jpg'); //загрузка текстуры 4
  tex5  := LoadGLTextureFromFile('5.jpg'); //загрузка текстуры 5
  tex6  := LoadGLTextureFromFile('6.jpg'); //загрузка текстуры 6

  glEnable(GL_TEXTURE_2D);                 //активация 2д текстур

  load := true;                            //флаг текстуры установлены

//  для нескольких кубов через поток UThrQ2 по количеству intqs
  for i := 1 to intqs do
  begin

    quads[i] := Tstatic.create(StartX,StartY,LEN,0); //создание объекта
    updpara(timeprog);                               //динамика параметров
    quads[i].intopar(cir,cirS,radius,timelive,startlive,(startlive+timelive));

    mCubes.Lines.Add('Куб №: '  + IntToStr(i));
    mCubes.Lines.Add('cir: '  + FloatToStr(quads[i].ci));
    mCubes.Lines.Add('cirS: '  + FloatToStr(quads[i].sc));
    mCubes.Lines.Add('radius: '  + FloatToStr(quads[i].rc));
    mCubes.Lines.Add('timelive: '  + FloatToStr(quads[i].tj));
    mCubes.Lines.Add('startlive: '  + FloatToStr(quads[i].sl));
    mCubes.Lines.Add('startlive+timelive: '  + FloatToStr(quads[i].el));
    mCubes.Lines.Add('=========: ');

  end;

end;

{2.3 отрисовка куба как объект}
procedure TGLCube.DrawObjStatic (obj: Tstatic; pan: integer);
var
  i: integer;
begin

  glTranslatef(obj.x, obj.y, obj.z);  //отрисовка по координатам X Y Z
  glRotatef(obj.angle,1,1,0);         //отрисовка с углом наклона

  glBindTexture(GL_TEXTURE_2D, tex1); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Передняя грань
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// Низ лево
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// Низ право
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);	// Верх право
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);	// Верх лево
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex2); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Задняя грань
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);	// Низ право
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// Верх право
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// Верх лево
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);	// Низ лево
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex3); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Верхняя грань
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// Верх лево
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);	// Низ лево
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);	// Низ право
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// Верх право
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex4); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Нижняя грань
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);	// Верх право
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);	// Верх лево
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// Низ лево
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// Низ право
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex5); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Правая грань
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);	// Низ право
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// Верх право
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);	// Верх лево
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// Низ лево
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex6); //установка загруженой текстуры в 2д текс.
  glBegin(GL_QUADS);                  //модуль рисования
          // Левая грань
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);	// Низ лево
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// Низ право
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);	// Верх право
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// Верх лево
  glEnd;

  quads[pan].paints(true);                //объект отрисован и выведен на экран

end;

{разобрать куб}
procedure TGLCube.bedcube(mat: integer);
begin

  FreeAndNil(quads[mat]);

  if(sledq > 0) then
  begin
    sledq := sledq - 1
  end;
  if(sledq <= 0) then
  begin
    SetupGL;
  end;

end;

{обновление параметром когда создался предыдущий куб}
procedure TGLCube.updpara(timepro : real);
begin

//  для нескольких кубов через поток UThrQ2 по количеству intqs
  if(firstz = true) then startlast := timeprog + 5 + Random(40) - Random(25);
  if((firstz = true) and (timeprog < onetime) and (startlast < timeprog)) then
                           startlast := onetime +
                              Random(StrToInt(FloatToStr(timeprog)));
  if((firstz = true) and (timeprog >= onetime) and (startlast < timeprog)) then
                           startlast := timeprog +
                              Random(StrToInt(FloatToStr(onetime)));
  if(firstz = false) then startlast := timeprog + 4 + Random(10);

  cir  := 0.01;                            //прирост циркуля
  cirX := 0;                               //обнуление координаты X циркуля
  cirY := 0;                               //обнуление координаты Y циркуля

  cirS := 0.02 + Random(15)/100;{random}   //установка скорости перемещения куба
  radius := 5 + Random(ClientWidth - 5)/200;{random}//установка рад. перем/куба
  startlive := startlast;                  //начало жизни

end;
//============================================================================

//----------------------------------------------------------------------------
{операции над таймерами}

{таймер времени работы}
procedure TGLCube.TTimTimer(Sender: TObject);
var
  rars : real;
  i: Integer;
begin

  timeprog := timeprog + 1;                //установка времени работы программы
  timelive  := StrToInt(leTJ.Text);{юзер}  //установка время жизни
  lblCountQuads.Caption := 'Массив для кубов: ' + IntToStr(intqs);
  lblSled.Caption := 'Количество кубов: ' + IntToStr(sledq);

  with GLCube do
  begin
    Caption := 'Время работы программы: ' + FloatToStr(timeprog);
    Caption := Caption + ' (с) / Cтарт формирования в : ' + FloatToStr(onetime);
  end;

  if ((firstz = false) and (timeprog = onetime * timeprog)) then
  begin
    updpara(timeprog);                       //формирование числовых переменных
    onetime := startlast;                    //установки времени формирования
    firstz := true;                          //флаг старта формирования
  end;

  if ((firstz = true) and (stlibo = false) and (timeprog = onetime) and
                                                              (sledq > 0)) then
  begin
    stlibo := true;                          //старт жизни
    tilibo := false;                         //еще не конец жизни
    Ris := otrisovka.Create(false);
    Ris.Priority := tpNormal;
    ThrQ2 := quads2.Create(false);
    ThrQ2.Priority := tpLower;
  end;

  if ((stlibo = true) and (tilibo = false) and (timeprog > onetime) and
                                                              (sledq <= 0)) then
  begin
    tilibo := true;                          //конец жизни
    stlibo := false;                         //старт еще не наступил
    ThrQ2.flag(true);
    FreeAndNil(ThrQ2);
  end;

end;

{таймер перемещения по окружности интервал 100}
procedure TGLCube.TCirTimer(Sender: TObject);
var
  i: Integer;
begin
  if ((load = true) and (stlibo = true) and (tilibo = false)) then
  begin

    if(izmtli = true) then
    begin
      mCubes.Lines.Clear;
    end;

    for i := 1 to intqs do
    begin

      //если время жизни изменено пользователем, поменять еще у неотрисованных
      if ((quads[i] <> nil) and (izmtli = true) and (quads[i].pnts = false))then
      begin

        quads[i].intopar(quads[i].ci,quads[i].sc,quads[i].rc,timelive,
                                        quads[i].sl,(quads[i].sl + timelive));

        mCubes.Lines.Add('Куб №: '  + IntToStr(i));
        mCubes.Lines.Add('cir: '  + FloatToStr(quads[i].ci));
        mCubes.Lines.Add('cirS: '  + FloatToStr(quads[i].sc));
        mCubes.Lines.Add('radius: '  + FloatToStr(quads[i].rc));
        mCubes.Lines.Add('timelive: '  + FloatToStr(quads[i].tj));
        mCubes.Lines.Add('startlive: '  + FloatToStr(quads[i].sl));
        mCubes.Lines.Add('startlive+timelive: '  + FloatToStr(quads[i].el));
        mCubes.Lines.Add('=========: ');

      end;

      //операции над отрисованными объектами
      if ((quads[i] <> nil) and (quads[i].pnts = true) and
                  (timeprog >= quads[i].sl) and (timeprog < quads[i].el)) then
      begin
        if ((radboo = false) and
                 not(quads[i].currad(quads[i].x,quads[i].y,quads[i].rc))) then
        begin
          radboo := true;                    //флаг установки из центра в радиус
          Sleep(10);
          quads[i].move(quads[i].rc,0,0);    //переместить объект на радиус
        end;

        cirX := quads[i].circle(quads[i].ci,quads[i].rc)[0];
        cirY := quads[i].circle(quads[i].ci,quads[i].rc)[1];
        quads[i].addcir(quads[i].sc);

        quads[i].movecir(cirX,cirY,0);       //переместить объект на X Y
      end;
    end;

    if(izmtli = true) then
    begin
      izmtli := false;
    end;

  end;
end;

{таймер вращения куба вокруг своей оси интервал 100}
procedure TGLCube.TCubTimer(Sender: TObject);
var
  i: Integer;
begin
  if ((load = true) and (stlibo = true) and (tilibo = false)) then
  begin

    for i := 1 to intqs do
    begin

      //операции над отрисованными объектами
      if ((quads[i] <> nil) and (quads[i].pnts = true) and
                  (timeprog >= quads[i].sl) and (timeprog < quads[i].el)) then
      begin
        quads[i].rotate(10);                 //кружение объекта вокруг оси XY
      end;

    end;

  end;
end;

end.
