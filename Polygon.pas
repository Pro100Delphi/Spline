unit Polygon;

interface

uses
  D2D1,
  Core, Geometry;

type
  TPolygon = class(TGeometry)
    private
    public
    	constructor Create; override;
      destructor Destroy; override;

      procedure AddPoint(APoints: Array of D2D_POINT_2F; AClosed: Boolean);
  end;

implementation

{ TPolygon }

procedure TPolygon.AddPoint(APoints: Array of D2D_POINT_2F; AClosed: Boolean);
var PG: ID2D1PathGeometry;
    GS: ID2D1GeometrySink;
    i: Integer;
begin

  if Length(APoints) < 3 then Exit;

  FFactory.CreatePathGeometry(PG);
  PG.Open(GS);

  GS.BeginFigure(APoints[0], D2D1_FIGURE_BEGIN_FILLED);

  for i := 1 to Length(APoints) - 1 do
    begin
      GS.AddLine(APoints[i]);
    end;

  if AClosed then
  	GS.EndFigure(D2D1_FIGURE_END_CLOSED)

  else
  	GS.EndFigure(D2D1_FIGURE_END_OPEN);

  GS.Close;

  Geometry := PG;

end;

constructor TPolygon.Create;
begin
  inherited;

end;

destructor TPolygon.Destroy;
begin

  inherited;
end;

end.
