  unit Main;

  {$mode objfpc}{$H+}

  interface

  uses
    Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
    StdCtrls, ColorBox, ValEdit, Spin;

  type

    { TVectorEditor }
     TVectorEditor=class(TForm)
       PolyG: TButton;
       ScrollBar1: TScrollBar;
       Zoom: TButton;
       PenChangeColor: TColorBox;
       Line: TButton;
       PolyLine: TButton;
       Button2: TButton;
       Palette: TColorBox;
       Ellipse: TButton;
       Editor: TPaintBox;
       PenWidth: TSpinEdit;
       ToolPanel: TPanel;
       Rectangle: TButton;


      procedure EditorClick(Sender: TObject);
      procedure EditorDblClick(Sender: TObject);
      procedure LineClick(Sender: TObject);
      procedure EllipseClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure EditorMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      procedure EditorMouseMove(Sender: TObject; Shift: TShiftState; X,
        Y: Integer);
      procedure EditorMouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
      procedure PolyGClick(Sender: TObject);
      procedure PolyLineClick(Sender: TObject);
      procedure PaintBox1Paint(Sender: TObject);
      procedure RectangleClick(Sender: TObject);
     end;
   TFigure=class
      public
      BrushCol:TColor;
      PenW: integer;
      tl,br: TPoint;
      PenCol: TColor;
      Points: array of TPoint;
      x0,y0,x1,y1: integer;
      procedure Draw(canvas :TCanvas); virtual;abstract;
      procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer); virtual;abstract;
      procedure ChangePoint(nextc: TPoint); virtual;abstract;
   end;
   TEllipse=class(TFigure)
    public
      procedure Draw(canvas :TCanvas); override;
      procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer); override;
      procedure ChangePoint(nextc: TPoint); override;
   end;

   TRectangle=class(TFigure)
     procedure Draw(canvas :TCanvas); override;
     procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer);override;
     procedure ChangePoint(nextc: TPoint);override;
    end;
   TPolyLine=class(TFigure)
    procedure Draw(canvas :TCanvas); override;
    procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer);override;
    procedure ChangePoint(nextc: TPoint);override;
   end;
   TLine=class(TFigure)
    procedure Draw(canvas :TCanvas); override;
    procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer);override;
    procedure ChangePoint(nextc: TPoint);override;
   end;
   TPolyG=class(TFigure)
    procedure Draw(canvas :TCanvas); override;
    procedure CreateFigure(nextc:TPoint;col, PenCh:TColor; width: integer);override;
    procedure ChangePoint(nextc: TPoint);override;
   end;
  var
    VectorEditor: TVectorEditor;
    CurrentTool: TFigure;
    arrF: array of TFigure;
    ButtDown: boolean;
    PenW, width: integer;
    x0,y0,x1,y1, CurT, cc: integer;
    offset, zoom: integer;
    nextc: TPOINT;
    prevc: TPoint;
    PGPoints, Points: array of TPoint;
  implementation
  {$R *.lfm}
  { TVectorEditor }

  procedure TRectangle.CreateFigure(nextc: TPoint;col, PenCh:TColor; width: integer);
  begin
    setlength(arrF, length(arrF)+1);
    arrF[High(arrF)]:=TRectangle.Create;
    setlength(arrF[High(arrF)].Points,length(Points)+2);
    arrF[High(arrF)].Points[0]:=nextc;
    arrF[High(arrF)].Points[1]:=nextc;
    arrF[High(arrF)].BrushCol:=col;
    arrF[High(arrF)].PenW:=width;
    arrF[High(arrF)].PenCol:=PenCh;
  end;

  procedure TEllipse.CreateFigure(nextc: TPoint;col, PenCh:TColor; width:integer);
  begin
    setlength(arrF, length(arrF)+1);
    arrF[High(arrF)]:=TEllipse.Create;
    setlength(arrF[High(arrF)].Points,length(Points)+2);
    arrF[High(arrF)].Points[0]:=nextc;
    arrF[High(arrF)].Points[1]:=nextc;
    arrF[High(arrF)].BrushCol:=col;
    arrF[High(arrF)].PenW:=width;
    arrF[High(arrF)].PenCol:=PenCh;
  end;
  procedure TPolyLine.CreateFigure(nextc: TPoint;col, PenCh:TColor; width: integer);
  begin
    setlength(arrF, length(arrF)+1);
    arrF[High(arrF)]:=TPolyLine.Create;
    setlength(arrF[High(arrF)].Points,length(arrF[High(arrF)].Points)+1);
    arrF[High(arrF)].Points[high(arrF[High(arrF)].Points)]:=nextc;
    arrF[High(arrF)].BrushCol:=col;
    arrF[High(arrF)].PenW:=width;
    arrF[High(arrF)].PenCol:=PenCh;
  end;
    procedure TLine.CreateFigure(nextc: TPoint;col, PenCh:TColor; width:integer);
  begin
    setlength(arrF, length(arrF)+1);
    arrF[High(arrF)]:=TLine.Create;
    setlength(arrF[High(arrF)].Points,length(Points)+2);
    arrF[High(arrF)].Points[0]:=nextc;
    arrF[High(arrF)].Points[1]:=prevc;
    arrF[High(arrF)].BrushCol:=col;
    arrF[High(arrF)].PenW:=width;
    arrF[High(arrF)].PenCol:=PenCh;
       if cc=1 then begin
     arrF[High(arrF)].Points[1]:=prevc;
     end;
  end;
     procedure TPolyG.CreateFigure(nextc: TPoint;col, PenCh:TColor; width: integer);
  begin
       setlength(arrF, length(arrF)+1);
       arrF[High(arrF)]:=TLine.Create;
       setlength(arrF[High(arrF)].Points,length(Points)+2);
       arrF[High(arrF)].Points[0]:=nextc;
       arrF[High(arrF)].Points[1]:=nextc;
       arrF[High(arrF)].BrushCol:=col;
       arrF[High(arrF)].PenW:=width;
       arrF[High(arrF)].PenCol:=PenCh;
  end;
  procedure TRectangle.ChangePoint(nextc: TPoint);
  begin
    arrF[High(arrF)].Points[1]:=nextc;
  end;
  procedure TEllipse.ChangePoint(nextc: TPoint);
  begin
    arrF[High(arrF)].Points[1]:=nextc;
  end;
    procedure TPolyLine.ChangePoint(nextc: TPoint);
  begin
    setlength(arrF[High(arrF)].Points,length(arrF[High(arrF)].Points)+1);
    arrF[High(arrF)].Points[high(arrF[High(arrF)].Points)]:=nextc;
  end;
     procedure TPolyG.ChangePoint(nextc: TPoint);
  begin
    arrF[High(arrF)].Points[1]:=nextc;
  {  setlength(arrF[High(arrF)].Points,length(arrF[High(arrF)].Points)+1);
    arrF[High(arrF)].Points[high(arrF[High(arrF)].Points)]:=nextc; }
  end;
    procedure TLine.ChangePoint(nextc: TPoint);
  begin
    arrF[High(arrF)].Points[1]:=nextc;
  end;
  procedure TRectangle.Draw(canvas: TCanvas);
  begin
    Canvas.Brush.Color:=BrushCol;
    Canvas.Pen.Width:=PenW;
    canvas.Pen.Color:=PenCol;
    canvas.Rectangle(Points[0].x,Points[0].y,Points[1].x,Points[1].y);
  end;
  procedure TEllipse.Draw(canvas: TCanvas);
  begin
    canvas.Brush.Color:=BrushCol;
    Canvas.Pen.Width:=PenW;
    canvas.Pen.Color:=PenCol;
    canvas.Ellipse(Points[0].x,Points[0].y,Points[1].x,Points[1].y);
  end;
   procedure TPolyLine.Draw(canvas: TCanvas);
  begin
    Canvas.Brush.Color:=BrushCol;
    Canvas.Pen.Width:=PenW;
    canvas.Pen.Color:=PenCol;
    canvas.PolyLine(Points);
  end;
     procedure TLine.Draw(canvas: TCanvas);
  begin
    canvas.Brush.Color:=BrushCol;
    Canvas.Pen.Width:=PenW;
    canvas.Pen.Color:=PenCol;
    canvas.MoveTo(Points[0].x,Points[0].y);
    canvas.LineTo(Points[1].x,Points[1].y);
  end;
     procedure TPolyG.Draw(canvas: TCanvas);
  begin

    canvas.Brush.Color:=BrushCol;
    Canvas.Pen.Width:=PenW;
    canvas.Pen.Color:=PenCol;
  end;

  procedure TVectorEditor.EllipseClick(Sender: TObject);
  begin
    CurrentTool := TEllipse.Create;
  end;
procedure TVectorEditor.LineClick(Sender: TObject);
begin
    CurrentTool := TLine.Create;
    curT:=1;
end;

procedure TVectorEditor.EditorClick(Sender: TObject);
begin
  if CurT=1 then begin
   if cc=1 then begin

   end;
  end;
  end;


procedure TVectorEditor.EditorDblClick(Sender: TObject);
begin
  CurrentTool:=TRectangle.Create;
end;

  procedure TVectorEditor.PolyLineClick(Sender: TObject);
  begin
     CurrentTool := TPolyLine.Create;
  end;
  procedure TVectorEditor.FormCreate(Sender: TObject);
  begin
    CurrentTool := TRectangle.Create;
  end;

  procedure TVectorEditor.RectangleClick(Sender: TObject);
  begin
    CurrentTool := TRectangle.Create;
  end;

procedure TVectorEditor.PolyGClick(Sender: TObject);
begin
    CurrentTool := TPolyG.Create;
end;
  procedure TVectorEditor.EditorMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  var
    nextc: TPoint;
  begin
    cc:=1;
    ButtDown := true;
 //   x0:=x;
 //   y0:=y;
    nextc := Point(x,y);
    prevc:=Point(x,y);
    CurrentTool.CreateFigure(nextc, Palette.Selected,PenChangeColor.Selected, PenWidth.Value);
    Refresh;
    end;
  procedure TVectorEditor.EditorMouseMove(Sender: TObject; Shift: TShiftState; X,
    Y: Integer);
  var
     nextc: TPoint;
  begin
      cc:=1;
      x1:=x;
      y1:=y;
    if ButtDown = true  then begin
      nextc := Point(x,y);
      prevc:=Point(x,y);
      CurrentTool.ChangePoint(nextc);
    end;
    Refresh;
  end;

  procedure TVectorEditor.EditorMouseUp(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
  begin
    ButtDown := false;
  if (CurT=1) and (cc=1) then begin
    end;
    Refresh;
  end;

  procedure TVectorEditor.PaintBox1Paint(Sender: TObject);
  var
     i: integer;
  begin
    for i:=0 to High(arrF) do
     arrF[i].Draw(canvas);
  end;
  end.

