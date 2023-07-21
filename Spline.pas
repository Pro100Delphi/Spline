unit Spline;

interface

uses
	SysUtils, Generics.Collections, D2D1, Graphics, Direct2D, Dialogs;

type
  TPointRec = class
  	Name: String;
    Color: TColor;
    Pos: TD2DPoint2f;
    Diameter: Single;
  end;

  TLineRec = class
    Color: TColor;
    LineWidth: Single;
    BegPos: TD2DPoint2f;
    EndPos: TD2DPoint2f;
  end;

  TControlPoints = TList<TD2DPoint2f>;
  TKnotList = TList<Single>;

  TSpline = class
  	private
    	FPoints: TControlPoints;
      FControlPoints: TControlPoints;

      FKnots: TKnotList;

      FDegree: Integer;

      function PointAtSegment(AP1, AP2: TD2D1Point2F; AT: Single): TD2D1Point2F;

    public
      constructor Create;
      destructor Destroy; override;

      procedure AddPoints(APoints: Array of TD2DPoint2f);
      procedure AddKnots(AKnots: Array of Single);

      function CalculateSplinePoint(ASegment: Integer; AT: Single; APoints: TList<TPointRec>; ALines: TList<TLineRec>): TD2DPoint2f;

      property Points: TControlPoints read FPoints;
      property ControlPoints: TControlPoints read FControlPoints write FControlPoints;

      property Degree: Integer read FDegree write FDegree;
  end;

implementation

{ TSpline }

function ToPointRec(APos: TD2DPoint2f; AColor: TColor; ADiameter: Single; AName: String): TPointRec;
begin
  Result := TPointRec.Create;
  Result.Name := AName;
  Result.Color := AColor;
  Result.Pos := APos;
  Result.Diameter := ADiameter;
end;

function ToLineRec(ABegPos, AEndPos: TD2DPoint2f; AColor: TColor; ALineWidth: Single): TLineRec;
begin
  Result := TLineRec.Create;
  Result.Color := AColor;
  Result.LineWidth := ALineWidth;
  Result.BegPos := ABegPos;
  Result.EndPos := AEndPos;
end;

constructor TSpline.Create;
begin
	FPoints := TControlPoints.Create;
  FControlPoints := TControlPoints.Create;
  FKnots := TKnotList.Create;

  FDegree := 3;
end;

destructor TSpline.Destroy;
begin
  FreeAndNil(FPoints);
  FreeAndNil(FControlPoints);
  FreeAndNil(FKnots);
  inherited;
end;

procedure TSpline.AddKnots(AKnots: array of Single);
begin
  FKnots.AddRange(AKnots);
end;

procedure TSpline.AddPoints(APoints: Array of TD2DPoint2f);
var i: Single;
    k: Integer;
    S: Integer;
    P: TD2D1Point2F;
begin

	FControlPoints.AddRange(APoints);

//  for k := 0 to FControlPoints.Count - 1 do
//  	begin
//    	P := FControlPoints[k];
//      P := D2D1PointF(P.x * 12, P.y * 12);
//      FControlPoints[k] := P;
//    end;

  S := 0;
  for k := FDegree to FKnots.Count - FDegree - 2 do
  	begin

      i := FKnots[k];
      while i <= FKnots[k + 1] do
        begin
          FPoints.Add(CalculateSplinePoint(S, i, nil, nil));
          i := i + 0.01;
        end;

      S := S + 1;
    end;
end;

function TSpline.PointAtSegment(AP1, AP2: TD2D1Point2F; AT: Single): TD2D1Point2F;
begin
  Result.x := AP1.x + (AP2.x - AP1.x) * AT;
  Result.y := AP1.y + (AP2.y - AP1.y) * AT;
end;

function TSpline.CalculateSplinePoint(ASegment: Integer; AT: Single; APoints: TList<TPointRec>; ALines: TList<TLineRec>): TD2DPoint2f;
var T: Single;
    i, j: Integer;
    S: Integer;

    PArr: Array of TD2DPoint2f;

    D: Single;
const
  Cols: Array[0..9] of TColor = (clGreen, clBlue, clRed, clFuchsia, clOlive, clPurple, clYellow, clAqua, clTeal, clNavy);
begin

  ASegment := ASegment + FDegree;

  // ASegment         - текущий сегмент, точка для которого будет тут расчитана
  // AKnots           - узлы
  // AControlPoints   - контрольные точки
  // ADegree          - степень функции

	{                I                II              III              IV
    --------------------------------------------------------------------------------
    A[0] = 		A[0] + A[1]    = A[0] + A[1]    = A[0] + A[1]			= A[0] + A[1]
    A[1] =    		---				 = A[1] + A[2]    = A[1] + A[2]    	= A[1] + A[2]
    A[2] = 				---							 ---				=	A[2] + A[3]    	= A[2] + A[3]
    A[3] =				---							 ---							---					= A[3] + A[4]   	<= Result Point
    A[4] = 				---              ---              ---             ---
    A[5] = 				---              ---              ---             ---
    ...       		...              ...              ...             ...
    A[N] = 				---              ---              ---             ---
  }

  // дополнительный массив
	// точек всегда на 1 больше чем степень функции
  SetLength(PArr, FDegree + 1);

  // скопировать точки для расчета, чтобы не портить оригинальный массив
  // количество точек у нас ADegree + 1, считать от 0 до ADegree, чтобы не заводить дополнительную переменную
  for i := 0 to FDegree do
    begin
      PArr[i] := FControlPoints[i + ASegment - FDegree];
    end;

  for i := 0 to FDegree - 1 do
    begin
      if ALines <> nil then
      	ALines.Add(ToLineRec(PArr[i], PArr[i + 1], 0, 0.3));
    end;

  D := 1.5;

  if FDegree = 1 then
    begin
      T := AT;
      PArr[FDegree] := PointAtSegment(PArr[FDegree - 1], PArr[FDegree], T);

      if APoints <> nil then
      	APoints.Add(ToPointRec(PArr[FDegree], Cols[0], D, 'A'));
    end

  else if FDegree > 1 then
    begin

    	// тут расчет промежуточных опорных точек
      // чтобы вычислить ту, которая будет следующей лежашей на сплайне
			for i := 0 to FDegree do
      	begin

        	for j := FDegree downto i + 1 do
          	begin
              // смещение с учетом номера сегмента
              S := j + ASegment;

              // новый параметр T
              T := (AT - FKnots[S - FDegree]) / (FKnots[S - i] - FKnots[S - FDegree]);

              PArr[j] := PointAtSegment(PArr[j - 1], PArr[j], T);

              if APoints <> nil then
              	APoints.Add(ToPointRec(PArr[j], Cols[i + ASegment - FDegree], D, 'A'));
            end;
          D := D - 0.25;
        end;
    end;

  Result := PArr[FDegree];
end;

end.
