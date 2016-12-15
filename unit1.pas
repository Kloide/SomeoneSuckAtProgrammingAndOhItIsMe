unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm1 }
   TForm1=class(TForm)
     Button1: TButton;
     Button2: TButton;
     Ellipse: TButton;
    PaintBox1: TPaintBox;
    Panel2: TPanel;
    Rectangle: TButton;

    procedure EllipseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure RectangleClick(Sender: TObject);
   end;
 TFigure=class
    public
    tl,br: Tpoint;
    procedure Draw(canvas :TCanvas); virtual;abstract;
    procedure CreateFigure(nowdot:TPoint); virtual;abstract;
    procedure ChangePoint(nowdot: TPoint); virtual;abstract;
 end;
 TEllipse=class(TFigure)
  public
    procedure Draw(canvas :TCanvas); override;
    procedure CreateFigure(nowdot:TPoint); override;
    procedure ChangePoint(nowdot: TPoint); override;
 end;

 TRectangle=class(TFigure)
   procedure Draw(canvas :TCanvas); override;
   procedure CreateFigure(nowdot:TPoint);override;
   procedure ChangePoint(nowdot: TPoint);override;
  end;
var
  Form1: TForm1;
  CurrentTool: TFigure;
  f: array of TFigure;
  ButtDown: boolean;


implementation
{$R *.lfm}
{ TForm1 }

procedure TRectangle.CreateFigure(nowdot: TPoint);
begin
  setlength(f, length(f)+1);
  f[High(f)]:=TRectangle.Create;
  f[High(f)].tl:=nowdot;
  f[High(f)].br:=nowdot;
end;

procedure TEllipse.CreateFigure(nowdot: TPoint);
begin
  setlength(f, length(f)+1);
  f[High(f)]:=TEllipse.Create;
  f[High(f)].tl:=nowdot;
  f[High(f)].br:=nowdot;
end;

procedure TRectangle.ChangePoint(nowdot: TPoint);
begin
  f[High(f)].br:=nowdot;
end;

procedure TEllipse.ChangePoint(nowdot: TPoint);
begin
  f[High(f)].br:=nowdot;
end;

procedure TRectangle.Draw(canvas :TCanvas);
begin
  canvas.Rectangle(tl.x,tl.y,br.x,br.y);
end;
procedure TEllipse.Draw(canvas :TCanvas);
begin
  canvas.Ellipse(tl.x,tl.y,br.x,br.y);
end;
procedure TForm1.EllipseClick(Sender: TObject);
begin
  CurrentTool :=TEllipse.Create;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CurrentTool := TRectangle.Create;
end;

procedure TForm1.RectangleClick(Sender: TObject);
begin
  CurrentTool := TRectangle.Create;
end;
procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   nowdot: TPoint;
begin
  ButtDown := true;
  nowdot := Point(x,y);
  CurrentTool.CreateFigure(nowdot);
  Refresh;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   nowdot: TPoint;
begin
  if ButtDown = true  then begin
    nowdot := Point(x,y);
    CurrentTool.ChangePoint(nowdot);
    Refresh;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ButtDown := false;
  Refresh;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
   i:Integer;
begin
  for i:=0 to High(f) do
   f[i].Draw(canvas);

end;

end.

