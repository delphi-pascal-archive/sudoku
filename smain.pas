unit smain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,ShellAPI;

type
  TField = record
    InLevel  : Boolean;
    Placed   : Integer;
  end;
  TForm4 = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Image2: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure SetMaxLev;
    procedure LoadLevel(Number : Integer);
    procedure DrawGrid;
    procedure FormCreate(Sender: TObject);
    procedure Draw;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetDigit(Digit : Integer);
    procedure Button1Click(Sender: TObject);
    function CheckResult : Boolean;
    procedure SetWin;
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  maxlev, selx, sely : integer;
  fields : array [0..8,0..8] of tfield;
  win : boolean = false;
implementation

{$R *.dfm}

{ TForm4 }

procedure TForm4.Button1Click(Sender: TObject);
var i : integer;
begin
  i := StrToInt((Sender as TButton).Caption);
  SetDigit(i);
  if checkresult() then setwin;

end;

function TForm4.CheckResult: Boolean;
type SDig = 1..9;
var Digs : set of SDig;
    x, y, k, j, ax, ay : integer;
begin
  result := true;
  //Есть ли пустые клетки?
  for x := 0 to 8 do
    for y := 0 to 8 do
      if fields[x,y].Placed = -1 then begin
        result := false;
        exit;
      end;

  //Проверяем вертикальные ряды
  for x := 0 to 8 do begin
    Digs := [];
    for y := 0 to 8 do begin
      if fields[x,y].Placed in Digs then begin
        result := false;
        Exit;
      end;
      Include(Digs, fields[x,y].Placed);
    end;
  end;

  //Также проверяем горизонтальные ряды
  for x := 0 to 8 do begin
    Digs := [];
    for y := 0 to 8 do begin
      if fields[y,x].Placed in Digs then begin
        result := false;
        Exit;
      end;
      Include(Digs, fields[y,x].Placed);
    end;
  end;

  for k := 0 to 2 do
    for j := 0 to 2 do begin
      Digs := [];
      for x := 0 to 2 do
        for y := 0 to 2 do begin
          ax := k*3 + x;
          ay := j*3 + y;
          if fields[ax,ay].Placed in digs then begin
            result := false;
            exit;
          end;
          Include(Digs, fields[ax,ay].Placed);
        end;
    end;



end;

procedure TForm4.Draw;
var x,y,ax,ay : integer;
begin
  DrawGrid;
  Image1.Canvas.DrawFocusRect(Rect(20*selx+1, 20*sely+1, 20*(selx+1), 20*(sely+1)));
  Image1.Canvas.Font.Style := [fsBold];
  for x := 0 to 8 do
    for y := 0 to 8 do begin
      ax := 20*x + 6;
      ay := 20*y + 3;
      if fields[x,y].InLevel then Image1.Canvas.Font.Color := clMaroon
                             else Image1.Canvas.Font.Color := clGreen;
      if win then
        Image1.Canvas.Font.Color := clOlive;
      if fields[x,y].Placed <> -1 then
        Image1.Canvas.TextOut(ax,ay,inttostr(fields[x,y].Placed));
    end;
end;

procedure TForm4.DrawGrid;
var i : integer;
begin
  //Clear
  Image1.Canvas.Brush.Color := clSilver;
  Image1.Canvas.FillRect(Rect(0,0,280,280));

  //Bold lines
  Image1.Canvas.Pen.Color := 0;
  Image1.Canvas.Pen.Width := 3;

  Image1.Canvas.MoveTo(60, 0);
  Image1.Canvas.LineTo(60,180);
  Image1.Canvas.MoveTo(120,0);
  Image1.Canvas.LineTo(120,180);

  Image1.Canvas.MoveTo(0, 60);
  Image1.Canvas.LineTo(180,60);
  Image1.Canvas.MoveTo(0,120);
  Image1.Canvas.LineTo(180,120);

  //Thin lines
  Image1.Canvas.Pen.Width := 0;

  for i := 1 to 8 do begin
    Image1.Canvas.MoveTo(i*20,0);
    Image1.Canvas.LineTo(i*20,180);

    Image1.Canvas.MoveTo(0,i*20);
    Image1.Canvas.LineTo(180,i*20);
  end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  selx := -1;
  sely := -1;
  SetMaxLev;
  LoadLevel(1);
end;

procedure TForm4.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if win then
    Exit;
  selx := X div 21;
  sely := Y div 21;
  Draw;
end;

procedure TForm4.Label2Click(Sender: TObject);
begin
  Panel1.Hide;
end;

procedure TForm4.Label3Click(Sender: TObject);
begin
  win := false;
  LoadLevel(Random(maxlev)+1);
  Panel1.Hide;
end;

procedure TForm4.Label4Click(Sender: TObject);
begin
  Panel2.Show;
end;

procedure TForm4.Label7Click(Sender: TObject);
begin
  ShellExecute(0,'open', 'mailto:mak-karpov@yandex.ru', '', '', SW_SHOWNORMAL);
end;

procedure TForm4.Label8Click(Sender: TObject);
begin
  Panel2.Hide;
end;

procedure TForm4.LoadLevel(Number: Integer);
var LevelName, s : String;
    sl    : TStringList;
    i : integer;
  j: Integer;
begin
  if Number >= maxlev then Exit;
  LevelName := 'lev'+IntToStr(Number)+'.txt';
  sl := TStringList.Create;
  try
    sl.LoadFromFile(LevelName);
  except
    ShowMessage('Cannot load level file '''+LevelName+'''!');
    Exit;
  end;
  for i := 0 to 8 do begin
    s := sl[i];
    for j := 1 to 9 do
      if s[j] <> '#' then begin
        fields[j-1,i].InLevel := true;
        fields[j-1,i].Placed := StrToInt(s[j]);
      end else begin
        fields[j-1,i].InLevel := false; //Поле можно изменять
        fields[j-1,i].Placed := -1; //Пустая клетка
      end;
  end;
  Draw;
end;

procedure TForm4.SetDigit(Digit: Integer);
begin
  if (selx = -1) or (sely = -1) then Exit;
  if fields[selx,sely].InLevel  then Exit;
  if fields[selx,sely].Placed <> Digit then fields[selx,sely].Placed := Digit
                                       else fields[selx,sely].Placed := -1;
  Draw;
end;

procedure TForm4.SetMaxLev;
var i : integer;
begin
  for i := 1 to 9999 do
    if not FileExists('lev'+inttostr(i)+'.txt') then begin
      maxlev := i;
      break;
    end;
end;

procedure TForm4.SetWin;
begin
  win := true;
  Panel1.Show;
  selx := -1;
  sely := -1;
  Draw;
end;

end.
