unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.ImageList, Vcl.ImgList,
  Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, D2D1, Direct2D, Winapi.DxgiFormat, pngimage,

  Core, Geometry, Component, Polygon, Spline, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private

    FRender: ID2D1HwndRenderTarget;
    FBrush: ID2D1SolidColorBrush;
    FLineStyle: ID2D1StrokeStyle;

    FImages: TList<ID2D1Bitmap>;

    FBitmap: ID2D1Bitmap;

    FComp: TComponent;

    FSpline: TSpline;

    FVal: Single;

    FOldPos: TPoint;

    function CreateBitmap(ARender: ID2D1RenderTarget; Bitmap: TBitmap): ID2D1Bitmap;

    procedure DrawSpline;
  public

    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
var P1: TPolygon;
    P2: TPolygon;
    P3: TPolygon;

    P: TD2D1Point2F;

    i: Integer;
    X, Y: Single;
    N: Integer;
    R1, R2: Single;
    A: Single;

    AP: Array of D2D_POINT_2F;

    BMP: TBitmap;
    PNG: TPngImage;
    SR: TSearchRec;

    Q: D2D_SIZE_F;

    BRT: ID2D1BitmapRenderTarget;
    B: ID2D1SolidColorBrush;

    M: TD2DMatrix3x2F;
begin
  FFactory.CreateHwndRenderTarget(D2D1RenderTargetProperties, D2D1HwndRenderTargetProperties(Handle), FRender);
  FRender.CreateSolidColorBrush(D2D1ColorF(0, 0, 1, 1), nil, FBrush);

  FFactory.CreateStrokeStyle(D2D1StrokeStyleProperties(
    D2D1_CAP_STYLE_FLAT,
    D2D1_CAP_STYLE_ROUND,
    D2D1_CAP_STYLE_ROUND,
    D2D1_LINE_JOIN_BEVEL,
    0,
    D2D1_DASH_STYLE_SOLID,
    0), nil, 0, FLineStyle);

  FComp := TComponent.Create;

  P1 := TPolygon.Create;
  P1.AddPoint([
  	D2D1PointF(0, 0),
    D2D1PointF(20, 50),
    D2D1PointF(50, 30),
    D2D1PointF(30, 10)
    ], True);

  P1.LineColor := D2D1ColorF(1, 0.5, 0, 1);

  P1.Move(D2D1PointF(50, -10));
  FComp.Add(P1);


  P2 := TPolygon.Create;

  R1 := 30;
  R2 := 30;

  N := 6;
  A := 0;

  SetLength(AP, N);

  for i := 0 to N - 1 do
  	begin
      X := 0 + R1 * Cos(A * Pi / 180);
      Y := 0 + R2 * Sin(A * Pi / 180);

      AP[i] := D2D1PointF(X, Y);

      A := A + (360 / N);
    end;

  P2.AddPoint(AP, True);
  P2.LineColor := D2D1ColorF(1, 0, 0.5, 1);
  P2.Move(D2D1PointF(-50, 50));

  FComp.Add(P2);

  FComp.Move(D2D1PointF(100, 0));

  P3 := TPolygon.Create;
  P3.AddPoint([
  	D2D1PointF(-10, 10),
    D2D1PointF(10, 50),
    D2D1PointF(30, 50),
    D2D1PointF(50, 30),
    D2D1PointF(25, -10)], False);

  P3.LineColor := D2D1ColorF(0, 0, 0, 1);

  FComp.Add(P3);

	FComp.Reset;

  FImages := TList<ID2D1Bitmap>.Create;

//  for i := 1 to 10 do
//  	begin
//      if FindFirst('E:\Bilder\Free Icons\iconfinden 32x32\*.png', faAnyFile, SR) = 0 then
//        begin
//          repeat
//            PNG := TPngImage.Create;
//            PNG.LoadFromFile('E:\Bilder\Free Icons\iconfinden 32x32\' + SR.Name);
//
//            BMP := TBitmap.Create;
//            BMP.Assign(PNG);
//            FBitmap := CreateBitmap(FRender, BMP);
//            FImages.Add(FBitmap);
//            FreeAndNil(PNG);
//            FreeAndNil(BMP);
//
//          until FindNext(SR) <> 0;
//        end;
//    end;
//
//  Caption := IntToStr(FImages.Count);

  Q := D2D1SizeF(30, 50);
  FRender.CreateCompatibleRenderTarget(@Q, nil, nil, 0, BRT);
  FRender.CreateSolidColorBrush(D2D1ColorF(1, 0, 0, 1), nil, B);
  BRT.GetTransform(M);

  Caption := FloatToStr(M._11) + '; ' + FloatToStr(M._12) + '; ' + FloatToStr(M._21) + '; ' +FloatToStr(M._22) + '; ' + FloatToStr(M._31) + '; ' +FloatToStr(M._32);
//  BRT.SetTransform(M);
  BRT.BeginDraw;
//  BRT.Clear(D2D1ColorF(1, 1, 1, 1));

  BRT.DrawRectangle(D2D1RectF(5, 5, 25, 25), B);

  BRT.GetBitmap(FBitmap);
  BRT.EndDraw;

  FSpline := TSpline.Create;
  FSpline.Degree := 3;

  FSpline.AddKnots([0, 0, 0, 0, 0.25, 0.5, 0.75, 1, 1, 1, 1]);
  FSpline.AddPoints([
    D2D1PointF(-10, 10),
    D2D1PointF(20, 40),
    D2D1PointF(40, 35),
    D2D1PointF(60, 5),
    D2D1PointF(30, -5),
    D2D1PointF(0, -5),
    D2D1PointF(10, -10),
    D2D1PointF(-10, -15),
    D2D1PointF(-50, -15),
    D2D1PointF(-40, 15)
    ]);

//  FSpline.AddKnots([
//  	0, 0, 0, 0,
//  	0.083333333, 0.166666667, 0.25, 0.333333333,
//    0.416666667, 0.5, 0.583333333, 0.666666667,
//    0.75, 0.833333333, 0.916666667,
//    1, 1, 1, 1]);
//
//	FSpline.AddPoints([
//    D2D1PointF(0.6345779249372754, 1.664763651844623),
//		D2D1PointF(1.455042609596148, 2.80070050017),
//    D2D1PointF(1.593434688423258, 1.2388439713142),
//    D2D1PointF(2.542407023370742, 2.138893947949554),
//    D2D1PointF(2.14700037787, 3.58399238026),
//    D2D1PointF(0.7334289298473778, 3.462508036273447),
//    D2D1PointF(0.0513563240156145, 2.148771489936507),
//    D2D1PointF(0.4368759151175255, 0.8152798596256616),
//    D2D1PointF(-0.6900295725740762, 1.763540451835751),
//    D2D1PointF(-0.116692400190459, 4.144069474347361),
//    D2D1PointF(2.4929815915691, 4.32186799035594),
//    D2D1PointF(3.481494929780637, 2.26733739086),
//    D2D1PointF(2.44355601846064, 0.8449138657092589),
//    D2D1PointF(1.02187501142, 0.8449138657092591),
//    D2D1PointF(2.374361658929956, 0.352755074554)]);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSpline);

  FreeAndNil(FImages);
  FreeAndNil(FComp);
end;

procedure TForm1.DrawSpline;
var P: TD2DPoint2f;
    Q: TPointRec;
    i: Integer;

    LP: TObjectList<TPointRec>;
    LL: TObjectList<TLineRec>;

    L: TLineRec;
    S: Single;

    A: Integer;

  	Colors: Array[0..3] of D3DCOLORVALUE;
begin
  LP := TObjectList<TPointRec>.Create;
  LL := TObjectList<TLineRec>.Create;

  FBrush.SetColor(D2D1ColorF(0, 0, 0, 1));
//
//  for i := 0 to FSpline.ControlPoints.Count - 2 do
//  	begin
//      FRender.DrawLine(FSpline.ControlPoints[i], FSpline.ControlPoints[i + 1], FBrush, 0.2);
//    end;

  S := 1;
  for P in FSpline.ControlPoints do
  	begin
  		FRender.FillEllipse(D2D1Ellipse(P, S, S), FBrush);
    end;

//  FSpline.CalculateSplinePoint(0, 0.33, LP, LL);
//  FSpline.CalculateSplinePoint(1, 0.5, LP, LL);
//  FSpline.CalculateSplinePoint(2, 0.83, LP, LL);

	A := FSpline.SegmentFromT(FVal);
	Caption := IntToStr(A) + ' - ' + FloatToStr(FVal);

//  if A > 2 then
//  	A := 2;
    
  FSpline.CalculateSplinePoint(A, FVal, LP, LL);
  
  for L in LL do
    begin
      FBrush.SetColor(D2D1ColorF(L.Color));
      FRender.DrawLine(L.BegPos, L.EndPos, FBrush, L.LineWidth);
    end;
    
  for Q in LP do
  	begin
      FBrush.SetColor(D2D1ColorF(Q.Color));
      S := Q.Diameter / 2;
      FRender.FillEllipse(D2D1Ellipse(Q.Pos, S, S), FBrush);
    end;

  FBrush.SetColor(D2D1ColorF(1, 0, 1, 1));
  for i := 0 to FSpline.Points.Count - 2 do
  	begin
    	FRender.DrawLine(FSpline.Points[i], FSpline.Points[i + 1], FBrush, 0.2);
    end;

  FreeAndNil(LP);
  FreeAndNil(LL);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var K: Integer;
begin
//  Caption := IntToStr(Key)

  K := Key - 49;

  if (K < 0) or (K >= FComp.List.Count) then Exit;

  FComp.Reset;
  FComp.ExplosionOnce(K, 50);

	InvalidateRect(Handle, nil, False);

end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  if Button = TMouseButton.mbLeft then
//  	FComp.Explosion(50)
//
//  else if Button = TMouseButton.mbRight then
//    FComp.Reset;

  FOldPos := Point(X, Y);
  FVal := 0.5;

  InvalidateRect(Handle, nil, False);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var K: Integer;
begin

  if ssLeft in Shift then
  	begin

      K := X - FOldPos.X;

      FVal := K / 600 + 0.5;

      if FVal <= 0 then
        FVal := 0

      else if FVal >= 1 then
        FVal := 1;

      InvalidateRect(Handle, nil, False);
    end;
end;

procedure TForm1.FormPaint(Sender: TObject);
var G: TGeometry;
		M: D2D_MATRIX_3X2_F;
    C: D2D_POINT_2F;
    U: Cardinal;
    i: Integer;
    B: ID2D1Bitmap;

    x, y: Single;

    S: Single;
    L: Single;
begin

  S := 8;
  L := 30 / S;

  FRender.BeginDraw;
  FRender.Clear(D2D1ColorF(1, 1, 1, 1));

  C := D2D1PointF(ClientWidth / 2, ClientHeight / 2);
  M :=
  	TD2D1Matrix3x2F.Translation(C) *
    TD2DMatrix3x2F.Scale(S, -S, C);

  FRender.SetTransform(M);

//  FRender.DrawLine(D2D1PointF(-70, 0), D2D1PointF(-20, 0), FBrush, 3, FLineStyle);
//
//  x := -C.x;
//  y := C.y - 32;
//  for B in FImages do
//  	begin
//
//      FRender.SetTransform(TD2DMatrix3x2F.Translation(x, y) * M);
//      FRender.DrawBitmap(B);
//      x := x + 34;
//      if x >= C.x then
//      	begin
//          x := -C.x;
//          y := y - 34;
//        end;
//
//    end;

//  U := GetTickCount;
//  for i := 1 to 1000 do
//  	begin

//    end;
//  Caption := IntToStr(GetTickCount - U);

  DrawSpline;

  FBrush.SetColor(D2D1ColorF(0, 0, 1, 1));
  FRender.DrawLine(D2D1PointF(-L , 0), D2D1PointF(L, 0), FBrush, 1 / S);
  FRender.DrawLine(D2D1PointF(0, -L), D2D1PointF(0, L), FBrush, 1 / S);



//      if FBitmap <> nil then
//        begin
//          FRender.SetTransform(TD2DMatrix3x2F.Translation(-10, 0) * M);
//          FRender.DrawBitmap(FBitmap);
//        end;
//
//  FRender.SetTransform(FComp.Transform * M);
//  FRender.GetTransform(M);
//
//  FBrush.SetColor(D2D1ColorF(0, 1, 0.5, 1));
//  FRender.DrawLine(D2D1PointF(-5, 0), D2D1PointF(5, 0), FBrush);
//  FRender.DrawLine(D2D1PointF(0, -5), D2D1PointF(0, 5), FBrush);

//  U := GetTickCount;
//  for i := 1 to 1000 do
//  	begin
//
//      for G in FComp.List do
//        begin
//          FBrush.SetColor(G.LineColor);
//          FRender.SetTransform(G.Transform * M);
//          FRender.DrawGeometry(G.Geometry, FBrush, 1);
//
//          FBrush.SetColor(D2D1ColorF(0, 0, 0.5, 1));
//          FRender.DrawLine(D2D1PointF(-2, 0), D2D1PointF(2, 0), FBrush);
//          FRender.DrawLine(D2D1PointF(0, -2), D2D1PointF(0, 2), FBrush);
//
//          Break;
//        end;
//    end;
//
//  Caption := IntToStr(GetTickCount - U);



//  FRender.SetTransform(M);



  FRender.EndDraw;
end;

procedure TForm1.FormResize(Sender: TObject);
var U: D2D_SIZE_U;
begin

  U := D2D1SizeU(ClientWidth, ClientHeight);
  FRender.Resize(U);

end;

function TForm1.CreateBitmap(ARender: ID2D1RenderTarget; Bitmap: TBitmap): ID2D1Bitmap;
var
  BitmapInfo: TBitmapInfo;
  buf: array of Byte;
  BitmapProperties: TD2D1BitmapProperties;
  Hbmp: HBitmap;
  R: ID2D1HwndRenderTarget;
begin
  FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
  BitmapInfo.bmiHeader.biSize := Sizeof(BitmapInfo.bmiHeader);
  BitmapInfo.bmiHeader.biHeight := -Bitmap.Height;
  BitmapInfo.bmiHeader.biWidth := Bitmap.Width;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;

  SetLength(buf, Bitmap.Height * Bitmap.Width * 4);
  // Forces evaluation of Bitmap.Handle before Bitmap.Canvas.Handle
  Hbmp := Bitmap.Handle;
  GetDIBits(Bitmap.Canvas.Handle, Hbmp, 0, Bitmap.Height, @buf[0], BitmapInfo, DIB_RGB_COLORS);

  BitmapProperties.dpiX := 0;
  BitmapProperties.dpiY := 0;
  BitmapProperties.pixelFormat.format := DXGI_FORMAT_B8G8R8A8_UNORM;

  if (Bitmap.PixelFormat <> pf32bit) or (Bitmap.AlphaFormat = afIgnored) then
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_IGNORE
  else
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_PREMULTIPLIED;

  FRender.CreateBitmap(D2D1SizeU(Bitmap.Width, Bitmap.Height), @buf[0], 4 * Bitmap.Width, BitmapProperties, Result);
end;

end.
