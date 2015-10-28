unit UMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, Buttons, ColorBox, StdCtrls, LCLtype, ComCtrls, Windows, UAbout,
  UTools, UFigures, UCoordinateSystem;

type

  { TMainForm }

  TMainForm = class(TForm)
    Label1: TLabel;
    PenWidthBox: TComboBox;
    PenColorBox: TColorBox;
    MainMenu: TMainMenu;
    MFile: TMenuItem;
    MAbout: TMenuItem;
    MExit: TMenuItem;
    PaintBox: TPaintBox;
    ScrollBarVertical: TScrollBar;
    ScrollBarHorizontal: TScrollBar;
    ToolsPanel: TPanel;
    PropertiesPanel: TPanel;
    TrackBarZoom: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MAboutClick(Sender: TObject);
    procedure MExitClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PenColorBoxChange(Sender: TObject);
    procedure PenWidthBoxChange(Sender: TObject);
    procedure ScrollBarHorizontalScroll(Sender: TObject;
      ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure ScrollBarVerticalScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure ToolClick(Sender: TObject);
    procedure TrackBarZoomChange(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

const
  Bound = 60;
  Addition = 3;

var
  IndexOfBtn: Integer;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  ToolsPanel.Height:= SizeOfButton + 2 * SpaceBetweenButtons;
  for i:=0 to High(TTool.Tools) do begin
    TTool.Tools[i].ButtonOnForm:= TBitBtn.Create(Self);
    with TTool.Tools[i].ButtonOnForm do begin
      Name:= TTool.Tools[i].ToString + IntToStr(i);
      Caption:= '';
      Parent:= Self;
      Width:= SizeOfButton;
      Height:= SizeOfButton;
      Glyph:= TTool.Tools[i].ImageOfButton;
      BorderStyle:= bsNone;
      Left:= (i+1) * SpaceBetweenButtons + i * SizeOfButton;
      Top:= SpaceBetweenButtons;
      OnClick:= @MainForm.ToolClick;
      Tag:= i;
    end;
  end;
  TTool.Tools[0].ButtonOnForm.Click;
  ScrollBarHorizontal.SetParams(0, 0, PaintBox.Width);
  ScrollBarVertical.SetParams(0, 0, PaintBox.Height);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if GetKeyState(VK_LBUTTON) < 0 then Exit;
  if (Key = VK_Z) and (Shift = [ssCtrl]) then
     TFigure.DeleteLastFigure();
  PaintBox.Invalidate;
  if (Key = VK_C) and (Shift = [ssCtrl]) then begin
    while TFigure.GetLastFigure() <> nil do
      TFigure.DeleteLastFigure();
  end;
end;

procedure TMainForm.MAboutClick(Sender: TObject);
begin
  AboutForm.Show;
end;

procedure TMainForm.MExitClick(Sender: TObject);
begin
  MainForm.Close;
end;

procedure TMainForm.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IsMouseDown:= True;
  TTool.Tools[IndexOfBtn].OnMouseDown(Sender, Button, Shift, TWorldPoint.WorldPoint(X, Y));
end;

procedure TMainForm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if IsMouseDown then begin
    if X > (PaintBox.Width - Bound) then
      Dx+= Addition
    else if X < Bound then
      Dx-= Addition;
    if Y > (PaintBox.Height - Bound) then
      Dy+= Addition
    else if Y < Bound then
      Dy-= Addition;
    //ScrollBarHorizontal.SetParams(TWorldPoint.ToWorldPoint(X), );
    TTool.Tools[IndexOfBtn].OnMouseMove(Sender, Shift, TWorldPoint.WorldPoint(X, Y));
  end;
  Label1.Caption:= IntToStr(X) + ' ' + IntToStr(Y);
  PaintBox.Invalidate;
end;

procedure TMainForm.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IsMouseDown:= False;
  TTool.Tools[IndexOfBtn].OnMouseUp(Sender, Button, Shift, TWorldPoint.WorldPoint(X, Y));
end;

procedure TMainForm.PaintBoxPaint(Sender: TObject);
var
  Figure: TFigure;
begin
  for Figure in FFigures do
      Figure.Draw(PaintBox.Canvas);
end;

procedure TMainForm.PenColorBoxChange(Sender: TObject);
begin
  TTool.SetPenColor(PenColorBox.Selected);
end;

procedure TMainForm.PenWidthBoxChange(Sender: TObject);
begin
  TTool.SetPenWidth(StrToInt(PenWidthBox.Text));
end;

procedure TMainForm.ScrollBarHorizontalScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  PaintBox.Left:= Round(-ScrollPos * Zoom / 100);
  PaintBox.Invalidate;
end;

procedure TMainForm.ScrollBarVerticalScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  PaintBox.Top:= Round(-ScrollPos * Zoom / 100);
  PaintBox.Invalidate;
end;

procedure TMainForm.ToolClick(Sender: TObject);
begin
  IndexOfBtn:= (Sender as TBitBtn).Tag;
end;

procedure TMainForm.TrackBarZoomChange(Sender: TObject);
begin
  Zoom:= TrackBarZoom.Position;
  PaintBox.Invalidate;
end;

end.

