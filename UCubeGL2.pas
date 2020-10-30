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
  NearClipping = 0.1;       //������� ��������� ���������
  FarClipping  = 100;       //������� ��������� ���������
  StartX = 0.00;            //��������� ���������� X
  StartY = 0.00;            //��������� ���������� Y
  LEN  = -50.00;            //��������� ���������� Z

var
  GLCube: TGLCube;
  zoom: Real = 1;           //����������� ��������� ������
  tex1 : GLuint = 0;        //�������� 1
  tex2 : GLuint = 0;        //�������� 2
  tex3 : GLuint = 0;        //�������� 3
  tex4 : GLuint = 0;        //�������� 4
  tex5 : GLuint = 0;        //�������� 5
  tex6 : GLuint = 0;        //�������� 6
  intqs : integer;          //������������ ���������� quads
  sledq : integer;          //������ �� ����������� quads
  quads : Array [1..10] of Tstatic; //������ ��������

  cir  : real = 0;          //������� �������
  cirS : real = 0;          //�������� �������� �������
  cirX : real = 0;          //���������� X �������
  cirY : real = 0;          //���������� Y �������
  radius : real = 0;        //������
  startlive : real = 0;     //������ �����
  timelive  : real = 0;     //����� �����
  timeprog  : real = 0;     //����� ������ ���������
  startlast : real = 0;     //������ ����� ����
  onetime   : real = 1;     //������ ��������

  load : boolean = false;   //���� �������� �������
  firstz : boolean = false; //���� ��������� �� ������ ������
  radboo : boolean = false; //���� ��������� �� ������
  stlibo : boolean = false; //���� ������ ����� �������
  tilibo : boolean = true;  //���� ��������� ����� �������
  izmtli : boolean = false; //���� ��������� timelive

implementation

{$R *.dfm}

uses UThrQ1, UThrQ2, UThrRis;

var
  ThrQ1 : quads1;           //������� �����
  ThrQ2 : quads2;           //����� ���������� ���������
  Ris   : otrisovka;        //����� �������� ��������

//----------------------------------------------------------------------------
{�������� �����}
procedure TGLCube.FormCreate(Sender: TObject);
begin
  dc := GetDC(Handle); //�������� �������� ���������� �� ����� GLCube

  {� InitOpenGL ���������������� OpenGL, ���� ��� �� ������� �� ����������
                                                              �����������}
  if  not InitOpenGL then Application.Terminate;

  //�������� ��������� ����������
  hrc := CreateRenderingContext(dc,[opDoubleBuffered],32,24,0,0,0,0);

  ActivateRenderingContext(dc,hrc);   //�������� ��������� ����������
  SetupGL;                            {������ ������/����������� ����������
                                                                  ����� (1.0)}
end;

{��� ��������� ������� �����}
procedure TGLCube.FormResize(Sender: TObject);
var
  tmpBool : Boolean;
begin
  idleHandler(Sender,tmpBool);
end;

{��� ��������� ������� �����}
procedure TGLCube.leTJChange(Sender: TObject);
begin

  if(Length(leTJ.Text) <= 0) then leTJ.Text := '0';

  timelive  := StrToInt(leTJ.Text);  {����}     //��������� ����� �����
  izmtli := true; //���� ��������� timelive

end;

{key and mouse �����}
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

  zoom := zoom + 3; //��������

end;

procedure TGLCube.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

  if zoom > 1 then     //���������
     zoom := zoom - 3
  else zoom := 1;

end;

{�������� �����}
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
{�������� ��� ��������}

{1.0 ������ ������/����������� ���������� �����}
procedure TGLCube.SetupGL;
begin

  ThrQ1 := quads1.Create(false);
  ThrQ1.Priority := tpHigher;

  onetime := 1;     //������ ��������

  load := false;   //���� �������� �������
  firstz := false; //���� ��������� �� ������ ������
  radboo := false; //���� ��������� �� ������
  stlibo := false; //���� ������ ����� �������
  tilibo := true;  //���� ��������� ����� �������
  izmtli := false; //���� ��������� timelive

  intqs := 2 + Random(8);
  sledq := intqs;

  mCubes.Lines.Clear;

  Application.OnIdle := IdleHandler;  {��������� ���������� � ������� ��������
                                      ���������� � ������������ ������� (2.0)}
end;

{2.0 ��������� ���������� � ������� �������� ���������� � ������������ ����}
procedure TGLCube.IdleHandler(Sender : TObject; var Done : Boolean);
begin

    RenderFon;  //��������� �������, ������ ��������� ����, ������ ������� (2.1)
    Sleep(1);
    Done := false;

end;

{2.1 ��������� �������, ������ ���������, ������ �������}
procedure TGLCube.RenderFon;
var
  i: integer;
begin

  if (sledq > 0) then
  begin

    glClearColor(0.5, 0.5, 0.8, 0); //��������� ����� �����
    glEnable(GL_DEPTH_TEST);        //�������� ����� ���� �������
    glEnable(GL_CULL_FACE);         {�������� ����� ����������� ������ ��������
                                                                   ������������}

    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);  {������� ������ �
                                                ����������� ��� �������� ������}

    glViewport(0,0,ClientWidth,ClientHeight); //��������� ������� ���������

    glMatrixMode(GL_PROJECTION);              //���������� ������� � �������
    glLoadIdentity;                           //�������� �������
    gluPerspective(45.0,ClientWidth/ClientHeight,NearClipping,FarClipping);

    {������ ������ ��� ��������� ����� ������}
    glMatrixMode(GL_MODELVIEW);            //���������� ������� � �������
    glLoadIdentity;                        //�������� �������
    gluLookAt(0, 0, zoom, //x y z ������� ������ z
              0, 0, 0, //x y z ������ ������� �� 0
              0, 1, 0  {x y z ������ ����� �� y (+z ������ �� ������,
                                                 -z �����;
                                                 +y �����, -y ����;
                                                 +x ������, -x �����}
             );
    glPointSize(5);                         //������ �����
    glBegin(GL_POINTS);                     //������ ���������
      glColor3d(1,1,1);  glVertex3d(0,0,0); // �����
    glEnd;
    {����� ������ ��� ��������� ����� ������}

    glEnable(GL_TEXTURE_2D);                 //��������� 2� �������

  //  ��� ���������� ����� ����� ����� UThrQ2 �� ���������� intqs
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
          {������ ������ ��� ��������� ����, �� ������ ���}
          glMatrixMode(GL_MODELVIEW);            //���������� ������� � �������
          glLoadIdentity;                        //�������� �������
          gluLookAt(0, 0, zoom, //x y z ������� ������ z
                    0, 0, 0, //x y z ������ ������� �� 0
                    0, 1, 0  {x y z ������ ����� �� y (+z ������ �� ������,
                                                       -z �����;
                                                       +y �����, -y ����;
                                                       +x ������, -x �����}
                   );
          {����� ������ ��� ��������� ����, �� ������ ���}

          DrawObjStatic(quads[i],i);           //��������� ���� ��� ������ (2.3)
        end;

        if ((quads[i] <> nil) and (timeprog >= quads[i].el)) then
        begin
          bedcube(i);                          //���������� ���
        end;

      end;
    end;

    SwapBuffers(dc);                          {�������� ������� ����� ������� �
                                                                  ����� ������}
  end;
end;

{2.2 �������� ��������}
procedure TGLCube.LoadResources;
var
  i: Integer;
begin

  tex1  := LoadGLTextureFromFile('1.jpg'); //�������� �������� 1
  tex2  := LoadGLTextureFromFile('2.jpg'); //�������� �������� 2
  tex3  := LoadGLTextureFromFile('3.jpg'); //�������� �������� 3
  tex4  := LoadGLTextureFromFile('4.jpg'); //�������� �������� 4
  tex5  := LoadGLTextureFromFile('5.jpg'); //�������� �������� 5
  tex6  := LoadGLTextureFromFile('6.jpg'); //�������� �������� 6

  glEnable(GL_TEXTURE_2D);                 //��������� 2� �������

  load := true;                            //���� �������� �����������

//  ��� ���������� ����� ����� ����� UThrQ2 �� ���������� intqs
  for i := 1 to intqs do
  begin

    quads[i] := Tstatic.create(StartX,StartY,LEN,0); //�������� �������
    updpara(timeprog);                               //�������� ����������
    quads[i].intopar(cir,cirS,radius,timelive,startlive,(startlive+timelive));

    mCubes.Lines.Add('��� �: '  + IntToStr(i));
    mCubes.Lines.Add('cir: '  + FloatToStr(quads[i].ci));
    mCubes.Lines.Add('cirS: '  + FloatToStr(quads[i].sc));
    mCubes.Lines.Add('radius: '  + FloatToStr(quads[i].rc));
    mCubes.Lines.Add('timelive: '  + FloatToStr(quads[i].tj));
    mCubes.Lines.Add('startlive: '  + FloatToStr(quads[i].sl));
    mCubes.Lines.Add('startlive+timelive: '  + FloatToStr(quads[i].el));
    mCubes.Lines.Add('=========: ');

  end;

end;

{2.3 ��������� ���� ��� ������}
procedure TGLCube.DrawObjStatic (obj: Tstatic; pan: integer);
var
  i: integer;
begin

  glTranslatef(obj.x, obj.y, obj.z);  //��������� �� ����������� X Y Z
  glRotatef(obj.angle,1,1,0);         //��������� � ����� �������

  glBindTexture(GL_TEXTURE_2D, tex1); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // �������� �����
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// ��� ����
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// ��� �����
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);	// ���� �����
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);	// ���� ����
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex2); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // ������ �����
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);	// ��� �����
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// ���� �����
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// ���� ����
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);	// ��� ����
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex3); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // ������� �����
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// ���� ����
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,  1.0,  1.0);	// ��� ����
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,  1.0,  1.0);	// ��� �����
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// ���� �����
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex4); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // ������ �����
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);	// ���� �����
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0, -1.0, -1.0);	// ���� ����
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// ��� ����
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// ��� �����
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex5); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // ������ �����
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0, -1.0, -1.0);	// ��� �����
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0,  1.0, -1.0);	// ���� �����
    glTexCoord2f(0.0, 1.0); glVertex3f( 1.0,  1.0,  1.0);	// ���� ����
    glTexCoord2f(0.0, 0.0); glVertex3f( 1.0, -1.0,  1.0);	// ��� ����
  glEnd;
  glBindTexture(GL_TEXTURE_2D, tex6); //��������� ���������� �������� � 2� ����.
  glBegin(GL_QUADS);                  //������ ���������
          // ����� �����
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);	// ��� ����
    glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0,  1.0);	// ��� �����
    glTexCoord2f(1.0, 1.0); glVertex3f(-1.0,  1.0,  1.0);	// ���� �����
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0,  1.0, -1.0);	// ���� ����
  glEnd;

  quads[pan].paints(true);                //������ ��������� � ������� �� �����

end;

{��������� ���}
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

{���������� ���������� ����� �������� ���������� ���}
procedure TGLCube.updpara(timepro : real);
begin

//  ��� ���������� ����� ����� ����� UThrQ2 �� ���������� intqs
  if(firstz = true) then startlast := timeprog + 5 + Random(40) - Random(25);
  if((firstz = true) and (timeprog < onetime) and (startlast < timeprog)) then
                           startlast := onetime +
                              Random(StrToInt(FloatToStr(timeprog)));
  if((firstz = true) and (timeprog >= onetime) and (startlast < timeprog)) then
                           startlast := timeprog +
                              Random(StrToInt(FloatToStr(onetime)));
  if(firstz = false) then startlast := timeprog + 4 + Random(10);

  cir  := 0.01;                            //������� �������
  cirX := 0;                               //��������� ���������� X �������
  cirY := 0;                               //��������� ���������� Y �������

  cirS := 0.02 + Random(15)/100;{random}   //��������� �������� ����������� ����
  radius := 5 + Random(ClientWidth - 5)/200;{random}//��������� ���. �����/����
  startlive := startlast;                  //������ �����

end;
//============================================================================

//----------------------------------------------------------------------------
{�������� ��� ���������}

{������ ������� ������}
procedure TGLCube.TTimTimer(Sender: TObject);
var
  rars : real;
  i: Integer;
begin

  timeprog := timeprog + 1;                //��������� ������� ������ ���������
  timelive  := StrToInt(leTJ.Text);{����}  //��������� ����� �����
  lblCountQuads.Caption := '������ ��� �����: ' + IntToStr(intqs);
  lblSled.Caption := '���������� �����: ' + IntToStr(sledq);

  with GLCube do
  begin
    Caption := '����� ������ ���������: ' + FloatToStr(timeprog);
    Caption := Caption + ' (�) / C���� ������������ � : ' + FloatToStr(onetime);
  end;

  if ((firstz = false) and (timeprog = onetime * timeprog)) then
  begin
    updpara(timeprog);                       //������������ �������� ����������
    onetime := startlast;                    //��������� ������� ������������
    firstz := true;                          //���� ������ ������������
  end;

  if ((firstz = true) and (stlibo = false) and (timeprog = onetime) and
                                                              (sledq > 0)) then
  begin
    stlibo := true;                          //����� �����
    tilibo := false;                         //��� �� ����� �����
    Ris := otrisovka.Create(false);
    Ris.Priority := tpNormal;
    ThrQ2 := quads2.Create(false);
    ThrQ2.Priority := tpLower;
  end;

  if ((stlibo = true) and (tilibo = false) and (timeprog > onetime) and
                                                              (sledq <= 0)) then
  begin
    tilibo := true;                          //����� �����
    stlibo := false;                         //����� ��� �� ��������
    ThrQ2.flag(true);
    FreeAndNil(ThrQ2);
  end;

end;

{������ ����������� �� ���������� �������� 100}
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

      //���� ����� ����� �������� �������������, �������� ��� � ��������������
      if ((quads[i] <> nil) and (izmtli = true) and (quads[i].pnts = false))then
      begin

        quads[i].intopar(quads[i].ci,quads[i].sc,quads[i].rc,timelive,
                                        quads[i].sl,(quads[i].sl + timelive));

        mCubes.Lines.Add('��� �: '  + IntToStr(i));
        mCubes.Lines.Add('cir: '  + FloatToStr(quads[i].ci));
        mCubes.Lines.Add('cirS: '  + FloatToStr(quads[i].sc));
        mCubes.Lines.Add('radius: '  + FloatToStr(quads[i].rc));
        mCubes.Lines.Add('timelive: '  + FloatToStr(quads[i].tj));
        mCubes.Lines.Add('startlive: '  + FloatToStr(quads[i].sl));
        mCubes.Lines.Add('startlive+timelive: '  + FloatToStr(quads[i].el));
        mCubes.Lines.Add('=========: ');

      end;

      //�������� ��� ������������� ���������
      if ((quads[i] <> nil) and (quads[i].pnts = true) and
                  (timeprog >= quads[i].sl) and (timeprog < quads[i].el)) then
      begin
        if ((radboo = false) and
                 not(quads[i].currad(quads[i].x,quads[i].y,quads[i].rc))) then
        begin
          radboo := true;                    //���� ��������� �� ������ � ������
          Sleep(10);
          quads[i].move(quads[i].rc,0,0);    //����������� ������ �� ������
        end;

        cirX := quads[i].circle(quads[i].ci,quads[i].rc)[0];
        cirY := quads[i].circle(quads[i].ci,quads[i].rc)[1];
        quads[i].addcir(quads[i].sc);

        quads[i].movecir(cirX,cirY,0);       //����������� ������ �� X Y
      end;
    end;

    if(izmtli = true) then
    begin
      izmtli := false;
    end;

  end;
end;

{������ �������� ���� ������ ����� ��� �������� 100}
procedure TGLCube.TCubTimer(Sender: TObject);
var
  i: Integer;
begin
  if ((load = true) and (stlibo = true) and (tilibo = false)) then
  begin

    for i := 1 to intqs do
    begin

      //�������� ��� ������������� ���������
      if ((quads[i] <> nil) and (quads[i].pnts = true) and
                  (timeprog >= quads[i].sl) and (timeprog < quads[i].el)) then
      begin
        quads[i].rotate(10);                 //�������� ������� ������ ��� XY
      end;

    end;

  end;
end;

end.
